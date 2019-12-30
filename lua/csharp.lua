local HEADLINE =
    [[
// This source code was generated by regenerator"
using System;
using System.Runtime.InteropServices;
]]

local INT_MAX = 2147483647
local TYPE_MAP = {
    Void = "void",
    Bool = "bool",
    Int8 = "sbyte",
    Int16 = "short",
    Int32 = "int",
    Int64 = "long",
    UInt8 = "byte",
    UInt16 = "ushort",
    UInt32 = "uint",
    UInt64 = "ulong",
    Float = "float",
    Double = "double",
    --
    IID = "Guid"
}

local ESCAPE_SYMBOLS = {ref = true, ["in"] = true}

local function CSEscapeName(src)
    if ESCAPE_SYMBOLS[src] then
        return "_" .. src
    end
    return src
end

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

local function CSType(t, isParam)
    local name = TYPE_MAP[t.class]
    if name then
        return {name, {}}
    end
    if t.class == "Typedef" or t.class == "Struct" then
        local name = TYPE_MAP[t.name]
        if name then
            return {name, {}}
        end
    end

    if t.class == "Pointer" then
        local option = {isConst = t.ref.isConst, isRef = true}
        if t.ref.type.name == "ID3DInclude" then
            return {"IntPtr", option}
        elseif t.ref.type.class == "Void" then
            return {"IntPtr", option}
        elseif isInterface(t.ref.type) then
            option.isCom = true
            local typeName = CSType(t.ref.type, isParam)[1]
            if typeName == "ID3DBlob" then
                typeName = "ID3D10Blob"
            end
            return {typeName, option}
        elseif t.ref.type.class == "Int8" then
            return {"string", option}
        elseif t.ref.type.name == "HDC__" then
            return {"IntPtr", option}
        elseif t.ref.type.name == "HWND__" then
            return {"IntPtr", option}
        elseif t.ref.type.name == "HINSTANCE__" then
            return {"IntPtr", option}
        else
            local typeName, refOption = table.unpack(CSType(t.ref.type, isParam))
            for k, v in pairs(refOption) do
                option[k] = option[k] or v
            end
            if isParam then
                if option.isCom then
                    option.attr =
                        string.format(
                        "[MarshalAs(UnmanagedType.CustomMarshaler, MarshalTypeRef = typeof(CustomMarshaler<%s>))]",
                        typeName
                    )
                end
                local inout = option.isConst and "ref" or "out"
                return {string.format("%s %s", inout, typeName), option}
            else
                return {"IntPtr", option}
            end
        end
    elseif t.class == "Reference" then
        local option = {isConst = t.ref.isConst, isRef = true}
        local typeName, refOption = table.unpack(CSType(t.ref.type, isParam))
        for k, v in pairs(refOption) do
            option[k] = option[k] or v
        end
        local inout = option.isConst and "ref" or "out"
        return {string.format("%s %s", inout, typeName), option}
    elseif t.class == "Array" then
        -- return DArray(t)
        local a = t
        local typeName, option = table.unpack(CSType(a.ref.type, isParam))
        option.isConst = option.isConst or t.ref.isConst
        if isParam then
            option.isRef = true
            return {string.format("ref %s", typeName), option}
        else
            option.attr = string.format("[MarshalAs(UnmanagedType.ByValArray, SizeConst=%d)]", a.size)
            return {string.format("%s[]", typeName), option}
        end
    else
        if #t.name == 0 then
            return {nil, {}}
        end
        return {t.name, {}}
    end
end

local function CSTypedefDecl(f, t)
    -- print(t, t.ref)
    local dst = CSType(t.ref.type)[1]
    if not dst then
        -- nameless
        writeln(f, "// typedef target nameless")
        return
    end

    if t.name == dst then
        -- f.writefln("// samename: %s", t.m_name);
        return
    end

    if string.sub(dst, 1, 4) == "ref " then
        writefln(f, "    public struct %s { public IntPtr Value; } // %s, %d", t.name, dst, t.useCount)
    else
        writefln(f, "    public struct %s { public %s Value; } // %d", t.name, dst, t.useCount)
    end
end

local function CSEnumDecl(f, decl, omitEnumPrefix, indent)
    if not decl.name then
        writefln(f, "// enum nameless", indent)
        return
    end

    if omitEnumPrefix then
        decl.omit()
    end

    writefln(f, "%spublic enum %s // %d", indent, decl.name, decl.useCount)
    writefln(f, "%s{", indent)
    for i, value in ipairs(decl.values) do
        if value.value > INT_MAX then
            writefln(f, "%s    %s = unchecked((int)0x%x),", indent, value.name, value.value)
        else
            writefln(f, "%s    %s = 0x%x,", indent, value.name, value.value)
        end
    end
    writefln(f, "%s}", indent)
end

local function CSGlobalFunction(f, decl, indent, option, sourceName)
    if decl.isExternC then
        writefln(f, '%s[DllImport("%s.dll")]', indent, sourceName)
    else
        writefln(f, '%s[DllImport("%s.dll", EntryPoint="mangle")]', indent)
    end
    writefln(f, "%spublic static extern %s %s(", indent, CSType(decl.ret)[1], decl.name)
    local params = decl.params
    for i, param in ipairs(params) do
        local comma = i == #params and "" or ","
        local dst, option = table.unpack(CSType(param.ref.type, true))
        writefln(f, "%s    %s%s %s%s", indent, option.attr or "", dst, CSEscapeName(param.name), comma)
        -- TODO: dfeault value = getValue(param, option.param_map)
    end
    writefln(f, "%s);", indent)
end

local function CSInterfaceMethod(f, decl, indent, option, isMethod, override)
    local ret = CSType(decl.ret)[1]
    local name = decl.name
    if name == "GetType" then
        name = "GetComType"
    end
    writefln(f, "%spublic %s %s %s(", indent, override, ret, name)
    local params = decl.params
    local callbackParams = {"m_ptr"}
    local delegateParams = {}
    local callvariables = {}
    for i, param in ipairs(params) do
        local comma = i == #params and "" or ","
        local dst, option = table.unpack(CSType(param.ref.type, true))
        local name = CSEscapeName(param.name)
        if option.isCom then
            if param.ref.type.class == "Pointer" and param.ref.type.ref.type.class == "Pointer" then
                if not option.isConst then
                    -- out interface
                    writefln(f, "%s    %s %s%s", indent, dst, name, comma)
                    table.insert(
                        callvariables,
                        string.format("%s = new %s();", name, dst:gsub("^ref ", ""):gsub("^out ", ""))
                    )
                    table.insert(callbackParams, string.format("out %s.PtrForNew", name))
                    table.insert(delegateParams, string.format("out IntPtr %s", name))
                else
                    -- may interface array
                    -- printf("## %s %d ##", decl.name, i)
                    -- print_table(option)
                    writefln(f, "%s    ref IntPtr %s%s", indent, name, comma)
                    table.insert(callbackParams, string.format("ref %s", name))
                    table.insert(delegateParams, string.format("ref IntPtr %s", name))
                end
            else
                -- in interface
                writefln(f, "%s    %s %s%s", indent, dst, name, comma)
                table.insert(callbackParams, string.format("%s.Ptr", name))
                table.insert(delegateParams, string.format("IntPtr %s", name))
            end
        elseif option.isRef then
            writefln(f, "%s    %s %s%s", indent, dst, name, comma)
            local isRef = string.sub(dst, 1, 4)
            if isRef == "ref " then
                table.insert(callbackParams, string.format("ref %s", name))
            elseif isRef == "out " then
                table.insert(callbackParams, string.format("out %s", name))
            else
                table.insert(callbackParams, string.format("%s", name))
            end
            table.insert(delegateParams, string.format("%s %s", dst, name))
        else
            writefln(f, "%s    %s %s%s", indent, dst, name, comma)
            table.insert(callbackParams, string.format("%s", name))
            table.insert(delegateParams, string.format("%s %s", dst, name))
        end
        -- TODO: default value = getValue(param, option.param_map)
    end
    local delegateName = decl.name .. "Func"
    writefln(
        f,
        [[
        ){
            var fp = GetFunctionPointer(%s);
            var callback = (%s)Marshal.GetDelegateForFunctionPointer(fp, typeof(%s));
            %s
            %scallback(%s);
        }]],
        isMethod - 1,
        delegateName,
        delegateName,
        table.concat(callvariables, ""),
        ret == "void" and "" or "return ",
        table.concat(callbackParams, ", ")
    )

    -- delegate
    writef(f, "%sdelegate %s %s(IntPtr self", indent, ret, delegateName)
    for i, param in ipairs(delegateParams) do
        writef(f, ", %s", param)
        -- TODO: default value = getValue(param, option.param_map)
    end
    writeln(f, ");")
    writeln(f)
end

local function getStruct(decl)
    if not decl then
        return nil
    end
    if decl.class == "Struct" then
        if decl.isForwardDecl then
            decl = decl.definition
        end
        return decl
    elseif decl.class == "Typedef" then
        return getStruct(decl.ref.type)
    else
        error("XXXXX")
    end
end

local function getIndexBase(decl)
    local indexBase = 0
    local current = decl
    local i = 0
    while true do
        i = i + 1
        current = getStruct(current.base)
        if not current then
            break
        end
        -- print(i, decl.name, current.name, #current.methods)
        indexBase = indexBase + #current.methods
    end
    return indexBase
end

local function hasSameMethod(name, decl)
    local current = decl
    while true do
        current = getStruct(current.base)
        if not current then
            break
        end
        for i, method in ipairs(current.methods) do
            if method.name == name then
                -- print("found", name)
                return true
            end
        end
    end
end

local anonymousMap = {}

local function CSStructDecl(f, decl, option, i)
    -- assert(!decl.m_forwardDecl);
    local name = decl.name
    if not name or #name == 0 then
        -- writeln(f, "    // struct nameless")
        -- return
        name = string.format("%s_anonymous_%d", table.concat(decl.namespace, "_"), i)
        -- print(name)
        anonymousMap[decl.hash] = name
    end

    local hasComInterface = false
    if decl.isInterface then
        hasComInterface = true
        -- com interface
        if decl.isForwardDecl then
            return
        end

        -- interface
        writef(f, "    public class %s", name)
        if not decl.base then
            writef(f, ": ComPtr")
        else
            writef(f, ": %s", decl.base.name)
        end

        writeln(f)
        writeln(f, "    {")
        if decl.iid then
            -- writefln(f, '    [Guid("%s"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]', decl.iid)
            writefln(
                f,
                [[
        static Guid s_uuid = new Guid("%s");
        public static new ref Guid IID => ref s_uuid;
                    ]],
                decl.iid
            )
        end

        -- methods
        local indexBase = getIndexBase(decl)
        -- print(decl.name, indexBase)
        for i, method in ipairs(decl.methods) do
            local override = hasSameMethod(method.name, decl) and "override" or "virtual"
            CSInterfaceMethod(f, method, "        ", option, indexBase + i, override)
        end
        writeln(f, "    }")
    else
        if decl.isForwardDecl then
            -- forward decl
            if #decl.fields > 0 then
                error("forward decl has fields")
            end
            writefln(f, "    public struct %s;", name)
        else
            if decl.isUnion then
                writeln(f, "    [StructLayout(LayoutKind.Explicit)]")
            else
                writeln(f, "    [StructLayout(LayoutKind.Sequential)]")
            end
            writefln(f, "    public struct %s // %d", name, decl.useCount)
            writeln(f, "    {")
            for i, field in ipairs(decl.fields) do
                local typeName, option = table.unpack(CSType(field.ref.type, false))
                if not typeName then
                    typeName = anonymousMap[field.ref.type.hash]
                -- print(field.ref.type.class, typeName, table.concat(field.ref.type.namespace, "_"))
                end
                if not typeName then
                    local fieldType = field.ref.type
                    if fieldType.class == "Struct" then
                        if fieldType.isUnion then
                            -- for i, unionField in ipairs(fieldType.fields) do
                            --     local unionFieldTypeName = CSType(unionField.ref.type)
                            --     writefln(f, "        %s %s;", unionFieldTypeName, CSEscapeName(unionField.name))
                            -- end
                            -- writefln(f, "    }")
                            writefln(f, "        // anonymous union")
                        else
                            writefln(f, "       // anonymous struct %s;", CSEscapeName(field.name))
                        end
                    else
                        error("unknown")
                    end
                else
                    if decl.isUnion then
                        writefln(f, "        [FieldOffset(0)]", field.offset)
                    end
                    local name = CSEscapeName(field.name)
                    if #name == 0 then
                        name = string.format("__anonymous__%d", i)
                    end
                    writefln(f, "        %spublic %s %s;", option.attr or "", typeName, name)
                end
            end

            writeln(f, "    }")
        end
    end

    return hasComInterface
end

local function CSDecl(f, decl, option, i)
    local hasComInterface = false
    if decl.class == "Typedef" then
        CSTypedefDecl(f, decl)
    elseif decl.class == "Enum" then
        CSEnumDecl(f, decl, option.omitEnumPrefix, "    ")
    elseif decl.class == "Function" then
        error("not reach Function")
    elseif decl.class == "Struct" then
        if CSStructDecl(f, decl, option, i) then
            hasComInterface = true
        end
    else
        error("unknown", decl)
    end
    return hasComInterface
end

local function CSConstant(f, macroDefinition, macro_map)
    if not isFirstAlpha(macroDefinition.tokens[1]) then
        local text = macro_map[macroDefinition.name]
        if text then
            writefln(f, "        %s", text)
        else
            local value = table.concat(macroDefinition.tokens, " ")
            local valueType = "int"
            if string.find(value, '%"') then
                valueType = "string"
            elseif string.find(value, "f") then
                valueType = "float"
            elseif string.find(value, "%.") then
                valueType = "double"
            elseif string.find(value, "UL") then
                valueType = "ulong"
            end
            if valueType == "int" then
                local num = tonumber(value)
                if num then
                    if num > INT_MAX then
                        valueType = "uint"
                    end
                else
                    -- fail tonumber
                    -- ex. "( 1 << 0 )"
                end
            end
            writefln(f, "        public const %s %s = %s;", valueType, macroDefinition.name, value)
        end
    end
end

local function CSSource(f, packageName, source, option)
    macro_map = option["macro_map"] or {}
    declFilter = option["filter"]
    omitEnumPrefix = option["omitEnumPrefix"]

    writeln(f, HEADLINE)
    writefln(f, "namespace %s {", packageName)

    if option.injection then
        local inejection = option.injection[source.name]
        if inejection then
            writefln(f, inejection)
        end
    end

    -- const
    if #source.macros > 0 then
        writeln(f, "    public static partial class Constants {")
        for j, macroDefinition in ipairs(source.macros) do
            CSConstant(f, macroDefinition, macro_map)
        end
        writeln(f, "    }")
    end

    -- types
    local hasComInterface = false
    local funcs = {}
    local types = {}
    for j, decl in ipairs(source.types) do
        if not declFilter or declFilter(decl) then
            if decl.class == "Function" then
                table.insert(funcs, decl)
            elseif decl.name and #decl.name > 0 then
                table.insert(types, decl)
            else
                if CSDecl(f, decl, option, j) then
                    hasComInterface = true
                end
            end
        end
    end
    for i, decl in ipairs(types) do
        if CSDecl(f, decl, option) then
            hasComInterface = true
        end
    end

    -- funcs
    if #funcs > 0 then
        writefln(f, "    public static class %s {", source.name)
        for i, decl in ipairs(funcs) do
            CSGlobalFunction(f, decl, "        ", option, source.name)
        end
        writeln(f, "    }")
    end

    writeln(f, "}")

    return hasComInterface
end

local function ComUtil(f, packageName)
    writeln(f, HEADLINE)
    f:write(
        [[
namespace ShrimpDX
{
    /// <summary>
    /// COMの virtual function table を自前で呼び出すヘルパークラス。
    /// </summary>
    public abstract class ComPtr : IDisposable
    {
        static Guid s_uuid;
        public static ref Guid IID => ref s_uuid;
 
        /// <summay>
        /// IUnknown を継承した interface(ID3D11Deviceなど) に対するポインター。
        /// このポインターの指す領域の先頭に virtual function table へのポインタが格納されている。
        /// <summay>
        protected IntPtr m_ptr;

        public ref IntPtr PtrForNew
        {
            get
            {
                if (m_ptr != IntPtr.Zero)
                {
                    Marshal.Release(m_ptr);
                }
                return ref m_ptr;
            }
        }

        public ref IntPtr Ptr => ref m_ptr;

        public static implicit operator bool(ComPtr i)
        {
            return i.m_ptr != IntPtr.Zero;
        }

        IntPtr VTable => Marshal.ReadIntPtr(m_ptr);

        static readonly int IntPtrSize = Marshal.SizeOf(typeof(IntPtr));

        protected IntPtr GetFunctionPointer(int index)
        {
            return Marshal.ReadIntPtr(VTable, index * IntPtrSize);
        }

        #region IDisposable Support
        private bool disposedValue = false; // 重複する呼び出しを検出するには

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    // TODO: マネージ状態を破棄します (マネージ オブジェクト)。
                }

                // TODO: アンマネージ リソース (アンマネージ オブジェクト) を解放し、下のファイナライザーをオーバーライドします。
                // TODO: 大きなフィールドを null に設定します。
                if (m_ptr != IntPtr.Zero)
                {
                    Marshal.Release(m_ptr);
                    m_ptr = IntPtr.Zero;
                }

                disposedValue = true;
            }
        }

        ~ComPtr()
        {
            // このコードを変更しないでください。クリーンアップ コードを上の Dispose(bool disposing) に記述します。
            Dispose(false);
        }

        // このコードは、破棄可能なパターンを正しく実装できるように追加されました。
        public void Dispose()
        {
            // このコードを変更しないでください。クリーンアップ コードを上の Dispose(bool disposing) に記述します。
            Dispose(true);
            // TODO: 上のファイナライザーがオーバーライドされる場合は、次の行のコメントを解除してください。
            // GC.SuppressFinalize(this);
        }
        #endregion
    }

    class CustomMarshaler<T> : ICustomMarshaler
    where T : ComPtr, new()
    {
        public void CleanUpManagedData(object ManagedObj)
        {
            throw new NotImplementedException();
        }

        public void CleanUpNativeData(IntPtr pNativeData)
        {
            throw new NotImplementedException();
        }

        public int GetNativeDataSize()
        {
            throw new NotImplementedException();
        }

        public IntPtr MarshalManagedToNative(object ManagedObj)
        {
            throw new NotImplementedException();
        }

        public object MarshalNativeToManaged(IntPtr pNativeData)
        {
            // var count = Marshal.AddRef(pNativeData);
            // Marshal.Release(pNativeData);
            var t = new T();
            t.PtrForNew = pNativeData;
            return t;
        }

        public static ICustomMarshaler GetInstance(string src)
        {
            return new CustomMarshaler<T>();
        }
    }
}
]]
    )
end

local function CSProj(f)
    f:write(
        [[
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>netstandard2.0</TargetFramework>
  </PropertyGroup>

</Project>
    ]]
    )
end

local function CSGenerate(sourceMap, dir, option)
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
            local path = string.format("%s/%s.cs", dir, source.name)
            printf("writeTo: %s", path)
            file.mkdirRecurse(dir)

            do
                -- open
                local f = io.open(path, "w")
                if CSSource(f, packageName, source, option) then
                    hasComInterface = true
                end
                io.close(f)
            end
        end
    end

    if hasComInterface then
        -- write utility
        local path = string.format("%s/ComUtil.cs", dir)
        local f = io.open(path, "w")
        ComUtil(f, packageName)
        io.close(f)
    end

    do
        -- csproj
        local path = string.format("%s/ShrimpDX.csproj", dir)
        local f = io.open(path, "w")
        CSProj(f)
        io.close(f)
    end
end

return {
    Generate = CSGenerate
}
