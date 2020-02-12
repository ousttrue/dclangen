local HEADLINE = "// This source code was generated by regenerator"

local DESCAPE_SYMBOLS = {module = true, ref = true, ["in"] = true}

local counter = 1

local function DEscapeName(src, i)
    if DESCAPE_SYMBOLS[src] then
        return "_" .. src
    end
    if #src == 0 then
        src = string.format("__param__%s", counter)
        counter = counter + 1
    end
    return src
end

local DTYPE_MAP = {
    Void = "void",
    Bool = "bool",
    Int8 = "char",
    Int16 = "short",
    Int32 = "int",
    Int64 = "long",
    UInt8 = "ubyte",
    UInt16 = "ushort",
    UInt32 = "uint",
    UInt64 = "ulong",
    Float = "float",
    Double = "double"
}

local function isInterface(decl)
    decl = decl.typedefSource

    if decl.class ~= "Struct" then
        return false
    end

    if decl.definition then
        -- resolve forward decl
        decl = decl.definition
    end

    return decl.isInterface
end

--- functype: TYPEDEF, RETURN, PARAM or FIELD
local function DType(t, funcType)
    local function getFunctionType(t)
        local extern = ""
        if funcType == "PARAM" then
            --
        elseif funcType == "RETURN" then
            --
        elseif funcType == "TYPEDEF" or funcType == "FIELD" then
            extern = "extern(C) "
        else
            error("unknown")
        end

        local params = {}
        for i, p in ipairs(t.params) do
            table.insert(params, string.format("%s %s", DType(p.ref.type), p.name))
        end
        local ret = DType(t.ret.type)
        -- if t.ret.isConst then
        --     ret = string.format("const(%s)", ret)
        -- end
        local ret = string.format("%s%s function(%s)", extern, ret, table.concat(params, ", "))
        return ret
    end

    local name = DTYPE_MAP[t.class]
    if name then
        return name
    end
    if t.class == "Pointer" then
        -- return DPointer(t)
        if t.ref.type.name == "ID3DInclude" then
            return "void*   "
        elseif isInterface(t.ref.type) then
            local typeName = DType(t.ref.type, funcType)
            if t.ref.isConst then
                typeName = string.format("const(%s)", typeName)
            end
            return string.format("%s", typeName)
        elseif t.ref.type.class == "Function" then
            return getFunctionType(t.ref.type)
        else
            local typeName = DType(t.ref.type, funcType)
            if t.ref.isConst then
                typeName = string.format("const(%s)", typeName)
            end
            local result = string.format("%s*", typeName)
            return result
        end
    elseif t.class == "Reference" then
        -- return DPointer(t)
        local typeName = DType(t.ref.type, funcType)
        if t.ref.isConst and funcType=="PARAM" then
            typeName = string.format("in %s", typeName)
        else
            typeName = string.format("ref %s", typeName)
        end
        return typeName
    elseif t.class == "Array" then
        -- return DArray(t)
        local a = t
        return string.format("%s[%d]", DType(a.ref.type, funcType), a.size)
    else
        if #t.name == 0 then
            return nil
        end
        return t.name
    end
end

local function DTypedefDecl(f, t)
    -- print(t, t.ref)
    local dst = DType(t.ref.type, "TYPEDEF")
    if not dst then
        -- nameless
        writeln(f, "// typedef target nameless")
        return
    end

    if t.name == dst then
        -- f.writefln("// samename: %s", t.m_name);
        return
    end

    writefln(f, "alias %s = %s;", t.name, dst)
end

local function DEnumDecl(f, decl, omitEnumPrefix)
    if not decl.name then
        writeln(f, "// enum nameless")
        return
    end

    if omitEnumPrefix then
        decl.omit()
    end

    writefln(f, "enum %s", decl.name)
    writeln(f, "{")
    for i, value in ipairs(decl.values) do
        writefln(f, "    %s = 0x%x,", value.name, value.value)
    end
    writeln(f, "}")
end

local function getValue(param, param_map, class)
    local value = ""
    local values = param.values
    if #values > 0 then
        if #values == 1 then
            if values[1] == "NULL" then
                value = "null"
            elseif class == "Pointer" and values[1] == "0" then
                value = "null"
            else
                value = values[1]
            end
        else
            if values[1] == "sizeof" then
                values = {table.unpack(values, 2, #values)}
                table.insert(values, ".sizeof")
            end
            value = table.concat(values, "")
        end
    end
    if param_map then
        local newValue = param_map(param, value)
        if newValue then
            value = newValue
        end
    end

    if #value == 0 then
        return ""
    else
        return "=" .. value
    end
end

local function DFunctionDecl(f, decl, indent, isMethod, option)
    indent = indent or ""

    f:write(indent)
    if not isMethod then
        if decl.isExternC then
            f:write("extern(C) ")
        else
            f:write(string.format("extern(C++) ", ns))
        end
    end

    local retType = DType(decl.ret.type, "RETURN")
    -- printf("%s %s", retType, decl.name)
    f:write(retType)
    f:write(" ")
    f:write(decl.name)
    f:write("(")

    local isFirst = true
    for i, param in ipairs(decl.params) do
        if isFirst then
            isFirst = false
        else
            f:write(", ")
        end

        local dst = DType(param.ref.type, "PARAM")
        if param.ref.isConst then
            dst = string.format("const(%s)", dst)
        end
        f:write(
            string.format(
                "%s %s%s",
                dst,
                DEscapeName(param.name, i),
                getValue(param, option.param_map, param.ref.type.class)
            )
        )
    end
    writeln(f, ");")
end

local SKIP_METHODS = {QueryInterface = true, AddRef = true, Release = true}

local anonymousMap = {}

local function anonymousUnionField(f, fieldType)
    writefln(f, "    union {")
    for j, unionField in ipairs(fieldType.fields) do
        local unionFieldTypeName = DType(unionField.ref.type, "FIELD")
        if not unionFieldTypeName then
            unionFieldTypeName = anonymousMap[unionField.ref.type.hash]
        end
        if not unionFieldTypeName and fieldType.class == "Struct" and fieldType.isUnion then
            -- nested
            anonymousUnionField(f, unionField.ref.type)
        else
            writefln(f, "        %s %s;", unionFieldTypeName, DEscapeName(unionField.name, j))
        end
    end
    writefln(f, "    }")
end

local function DField(f, field)
    local typeName = DType(field.ref.type, "FIELD")
    if not typeName then
        typeName = anonymousMap[field.ref.type.hash]
    end

    local fieldType = field.ref.type
    if not typeName then
        -- anonymous
        if fieldType.class == "Struct" then
            if fieldType.isUnion then
                anonymousUnionField(f, fieldType)
            else
                writefln(f, "   // anonymous struct %s;", DEscapeName(field.name, i))
            end
        else
            error(string.format("unknown: %s", fieldType))
        end
    else
        if field.ref.isConst then
            typeName = "const(" .. typeName .. ")"
        end
        writefln(f, "    %s %s;", typeName, DEscapeName(field.name, i))
    end
end

local function DStructDecl(f, decl, option, i)
    if decl.isForwardDecl then
        -- TODO
        return
    end

    if anonymousMap[decl.hash] then
        -- already processed
        return
    end

    local name = decl.name
    if not name or #name == 0 then
        if decl.isUnion then
            -- allow anonymous union
            return
        end
        -- writeln(f, "    // struct nameless")
        -- return
        name = string.format("%s_anonymous_%d", table.concat(decl.namespace, "_"), i)
        -- print(name)
        anonymousMap[decl.hash] = name
    end

    if decl.isInterface then
        -- com interface
        if decl.isForwardDecl then
            return
        end

        -- interface
        writef(f, "interface %s", name)
        if decl.base then
            writef(f, ": %s", decl.base.name)
        end

        writeln(f)
        writeln(f, "{")
        if decl.iid then
            writefln(f, '    static const iidof = parseGUID("%s");', decl.iid)
        end

        -- methods
        for i, method in ipairs(decl.methods) do
            if SKIP_METHODS[method.name] then
                writefln(f, "    // skip %s", method.name)
            else
                DFunctionDecl(f, method, "    ", true, option)
            end
        end
        writeln(f, "}")
    else
        if decl.isForwardDecl then
            -- forward decl
            if #decl.fields > 0 then
                error("forward decl has fields")
            end
            writefln(f, "struct %s;", name)
        else
            writefln(f, "struct %s", name)
            writeln(f, "{")
            for i, field in ipairs(decl.fields) do
                DField(f, field)
            end

            writeln(f, "}")
        end
    end
end

local function DDecl(f, decl, option, i)
    if decl.class == "TypeDef" then
        DTypedefDecl(f, decl)
    elseif decl.class == "Enum" then
        DEnumDecl(f, decl, option.omitEnumPrefix)
    elseif decl.class == "Struct" then
        DStructDecl(f, decl, option, i)
    elseif decl.class == "Function" then
        DFunctionDecl(f, decl, "", false, option)
    else
        error(string.format("unknown: %s", decl))
    end
end

local function DImport(f, packageName, source)
    writeln(f, HEADLINE)
    local self = string.format("%s.%s", packageName, source.name)
    writefln(f, "module %s;", self)

    local used = {[self] = true}

    local function writeModule(m)
        -- core.sys.windows.windef etc...
        if not used[m] then
            used[m] = true
            writefln(f, "import %s;", m)
        end
        if m == "core.sys.windows.unknwn" then
            writefln(f, "import %s.guidutil;", packageName)
            return true
        end
        return false
    end

    local hasComInterface = false
    for _, m in ipairs(source.modules) do
        if writeModule(m) then
            hasComInterface = true
        end
    end

    for i, src in ipairs(source.imports) do
        if not src.empty then
            -- inner package
            writefln(f, "import %s.%s;", packageName, src.name)
        end

        for _, m in ipairs(src.modules) do
            if writeModule(m) then
                hasComInterface = true
            end
        end
    end
    return hasComInterface
end

local function DConstant(f, macroDefinition, macro_map)
    local tokens = macroDefinition.tokens
    if not isFirstAlpha(tokens[2]) then
        local p = macro_map[macroDefinition.name]
        if p then
            writeln(f, p)
        else
            if macroDefinition.isFunctionLike then
                writefln(f, "// macro function: %s;", table.concat(tokens, " "))
            else
                table.remove(tokens, 1)
                writefln(f, "enum %s = %s;", macroDefinition.name, table.concat(tokens, " "))
            end
        end
    end
end

local function DSource(f, packageName, source, option)
    local macro_map = option["macro_map"] or {}
    local declFilter = option["filter"]
    local omitEnumPrefix = option["omitEnumPrefix"]

    -- imports
    local hasComInterface = DImport(f, packageName, source)

    if option.injection then
        local inejection = option.injection[source.name]
        if inejection then
            writefln(f, inejection)
        end
    end

    -- const
    for _, macroDefinition in ipairs(source.macros) do
        DConstant(f, macroDefinition, macro_map)
    end

    -- first anonymous types
    for i, decl in ipairs(source.types) do
        if not declFilter or declFilter(decl) then
            if decl.class == "Struct" and #decl.name == 0 then
                DDecl(f, decl, option, i)
            end
        end
    end

    -- types
    local funcs = {}
    for i, decl in ipairs(source.types) do
        if not declFilter or declFilter(decl) then
            if decl.class == "Function" then
                table.insert(funcs, decl)
            else
                DDecl(f, decl, option, i)
            end
        end
    end
    local function pred(a, b)
        return table.concat(a.namespace, ",") < table.concat(b.namespace, ".")
    end
    table.sort(funcs, pred)
    local lastNS = ""
    for i, decl in ipairs(funcs) do
        if not option.externC then
            local ns = table.concat(decl.namespace, ".")
            if ns ~= lastNS then
                if #lastNS > 0 then
                    writefln(f, "} // %s", lastNS)
                end
                if string.match(ns, "^%s*$") then
                    writefln(f, "extern(C++) {", ns)
                else
                    writefln(f, "extern(C++, %s) {", ns)
                end
                lastNS = ns
            end
        end
        DDecl(f, decl, option)
    end
    if #lastNS > 0 then
        writefln(f, "} // %s", lastNS)
    end

    return hasComInterface
end

local function DPackage(f, packageName, sourceMap)
    writeln(f, HEADLINE)
    writefln(f, "module %s;", packageName)
    local keys = {}
    for k, source in pairs(sourceMap) do
        table.insert(keys, k)
    end
    table.sort(keys)
    for i, k in ipairs(keys) do
        local source = sourceMap[k]
        if not source.empty then
            writefln(f, "public import %s.%s;", packageName, source.name)
        end
    end
end

local function DGuidUtil(f, packageName)
    writefln(f, "module %s.guidutil;", packageName)
    writeln(
        f,
        [[

import std.uuid;
import core.sys.windows.basetyps;

GUID parseGUID(string guid)
{
    return toGUID(parseUUID(guid));
}
GUID toGUID(immutable std.uuid.UUID uuid)
{
    ubyte[8] data=uuid.data[8..$];
    return GUID(
                uuid.data[0] << 24
                |uuid.data[1] << 16
                |uuid.data[2] << 8
                |uuid.data[3],

                uuid.data[4] << 8
                |uuid.data[5],

                uuid.data[6] << 8
                |uuid.data[7],

                data
                );
}
]]
    )
end

function DGenerate(sourceMap, dir, option)
    -- clear dir
    if file.exists(dir) then
        printf("rmdir %s", dir)
        file.rmdirRecurse(dir)
    end

    local packageName = basename(dir)
    local hasComInterface = false
    for k, source in pairs(sourceMap) do
        -- write each source
        if not source.empty then
            local path = string.format("%s/%s.d", dir, source.name)
            printf("writeTo: %s", path)
            file.mkdirRecurse(dir)

            do
                -- open
                local f = io.open(path, "w")
                if DSource(f, packageName, source, option) then
                    hasComInterface = true
                end
                io.close(f)
            end
        end
    end

    if hasComInterface then
        -- write utility
        local path = string.format("%s/guidutil.d", dir)
        local f = io.open(path, "w")
        DGuidUtil(f, packageName)
        io.close(f)
    end

    do
        -- write package.d
        local path = string.format("%s/package.d", dir)
        printf("writeTo: %s", path)
        file.mkdirRecurse(dir)

        do
            -- open
            local f = io.open(path, "w")
            DPackage(f, packageName, sourceMap)
            io.close(f)
        end
    end
end

return {
    Generate = DGenerate
}
