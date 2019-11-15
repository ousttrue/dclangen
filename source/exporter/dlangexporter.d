module exporter.dlangexporter;
import exporter.source;
import clangdecl;
import std.ascii;
import std.stdio;
import std.string;
import std.path;
import std.traits;
import std.file;
import std.algorithm;
import sliceview;

///
/// D言語向けに出力する
///

string DEscapeName(string src)
{
    switch (src)
    {
    case "module":
        return "_module";

    default:
        return src;
    }
}

static bool isInterface(Decl decl)
{
    Typedef typedefDecl = cast(Typedef) decl;
    if (typedefDecl)
    {
        decl = typedefDecl.m_typeref.type;
    }

    Struct structDecl = cast(Struct) decl;
    if (!structDecl)
    {
        return false;
    }

    if (structDecl.m_definition)
    {
        // resolve forward decl
        structDecl = structDecl.m_definition;
    }

    debug
    {
        if (structDecl.m_name == "ID3D11DeviceContext")
        {
            auto methods = makeView(structDecl.m_methods);
            auto a = 0;
        }
    }
    return structDecl.isInterface;
}

string DPointer(Pointer t)
{
    if (isInterface(t.m_typeref.type))
    {
        return format("%s", DType(t.m_typeref.type));
    }
    else
    {
        return format("%s*", DType(t.m_typeref.type));
    }
}

string DArray(Array t)
{
    return format("%s[%d]", DType(t.m_typeref.type), t.m_size);
}

string DType(Decl t)
{
    return castSwitch!((Pointer decl) => DPointer(decl),
            (Array decl) => DArray(decl), (UserDecl decl) => decl.m_name, //
            (Void _) => "void", (Bool _) => "bool", (Int8 _) => "byte",
            (Int16 _) => "short", (Int32 _) => "int", (Int64 _) => "long",
            (UInt8 _) => "ubyte", (UInt16 _) => "ushort", (UInt32 _) => "uint",
            (UInt64 _) => "ulong", (Float _) => "float", (Double _) => "double", //
            () => format("unknown(%s)", t))(t);
}

void DTypedefDecl(File* f, Typedef t)
{
    auto dst = DType(t.m_typeref.type);
    if (dst)
    {
        if (t.m_name == dst)
        {
            // f.writefln("// samename: %s", t.m_name);
            return;
        }

        f.writefln("alias %s = %s;", t.m_name, dst);
        return;
    }

    // nameless
    f.writeln("// typedef target nameless");
}

void DStructDecl(File* f, Struct decl, string typedefName = null)
{
    // assert(!decl.m_forwardDecl);
    auto name = typedefName ? typedefName : decl.m_name;
    if (!name)
    {
        f.writeln("// struct nameless");
        return;
    }

    if (decl.isInterface)
    {
        // interface
        f.writef("interface %s", name);
        if (decl.m_base)
        {
            f.writef(": %s", decl.m_base.m_name);
        }
        f.writeln();
        f.writeln("{");
        if (!decl.m_iid.empty)
        {
            f.writefln("    static const iidof = parseGUID(\"%s\");", decl.m_iid.toString());
        }
        // methods
        foreach (method; decl.m_methods)
        {
            DFucntionDecl(f, method, "    ", true);
        }
        f.writeln("}");
    }
    else
    {
        // struct
        if (decl.m_fields.empty())
        {
            return;
        }

        f.writefln("struct %s", name);
        f.writeln("{");
        foreach (field; decl.m_fields)
        {
            auto typeName = DType(field.type);
            if (!typeName)
            {
                auto structDecl = cast(Struct) field.type;
                if (structDecl)
                {
                    if (structDecl.m_isUnion)
                    {
                        // typedef struct D3D11_VIDEO_COLOR
                        // {
                        // union 
                        //     {
                        //     int YCbCr;
                        //     float RGBA;
                        //     } 	;
                        // }                        
                        f.writefln("    union {");
                        foreach (unionField; structDecl.m_fields)
                        {
                            auto unionFieldTypeName = DType(unionField.type);
                            f.writefln("        %s %s;", unionFieldTypeName,
                                    DEscapeName(unionField.name));
                        }
                        f.writefln("    }");
                    }
                    else
                    {
                        f.writefln("   // anonymous struct %s;", DEscapeName(field.name));
                    }
                }
                else
                {
                    throw new Exception("unknown");
                }
            }
            else
            {
                f.writefln("    %s %s;", typeName, DEscapeName(field.name));
            }
        }
        f.writeln("}");
    }
}

void DEnumDecl(File* f, Enum decl)
{
    if (!decl.m_name)
    {
        f.writeln("// enum nameless");
        return;
    }

    f.writef("enum %s", decl.m_name);
    auto maxValue = decl.maxValue;
    if (maxValue > uint.max)
    {
        f.write(": ulong");
    }
    f.writeln();
    f.writeln("{");
    foreach (value; decl.m_values)
    {
        f.writefln("    %s = 0x%x,", value.name, value.value);
    }
    f.writeln("}");
}

void DFucntionDecl(File* f, Function decl, string indent, bool isMethod)
{
    if (!isMethod && !decl.m_dllExport)
    {
        auto retType = cast(UserDecl) decl.m_ret;
        if (!retType)
        {
            return;
        }
        if (retType.m_name != "HRESULT")
        {
            return;
        }
        debug auto isCom = true; // D3D11CreateDevice ... etc
    }
    f.write(indent);
    if (decl.m_externC)
    {
        f.write("extern(C) ");
    }
    f.write(DType(decl.m_ret));
    f.write(" ");
    f.write(decl.m_name);
    f.write("(");

    auto isFirst = true;
    foreach (param; decl.m_params)
    {
        if (isFirst)
        {
            isFirst = false;
        }
        else
        {
            f.write(", ");
        }
        if(param.typeRef.isConst)
        {
            f.write("const ");
        }
        f.write(format("%s %s", DType(param.typeRef.type), DEscapeName(param.name)));
    }
    f.writeln(");");
}

void DDecl(File* f, Decl decl)
{
    castSwitch!((Typedef decl) => DTypedefDecl(f, decl),
            (Enum decl) => DEnumDecl(f, decl), (Struct decl) => DStructDecl(f,
                decl), (Function decl) => DFucntionDecl(f, decl, "", false))(decl);
}

void dlangExport(Source[string] sourceMap, string dir)
{
    // clear dir
    if (exists(dir))
    {
        writefln("rmdir %s ...", dir);
        rmdirRecurse(dir);
    }

    // write each source
    // auto sourcemap = makeView(m_sourceMap);
    auto useGuid = false;
    foreach (k, source; sourceMap)
    {
        // source.writeTo(dir);
        if (source.empty)
        {
            continue;
        }

        auto packageName = dir.baseName.stripExtension;

        // open
        auto path = format("%s/%s.d", dir, source.getName());
        // writeln(stem);
        writefln("writeTo: %s(%d)", path, source.m_types.length);
        mkdirRecurse(dir);

        {
            auto f = File(path, "w");
            f.writefln("module %s.%s;", packageName, source.getName());

            // imports
            string[] modules;
            foreach (src; source.m_imports)
            {
                if (!src.empty)
                {
                    f.writefln("import %s.%s;", packageName, src.getName());
                }

                foreach (m; src.m_modules)
                {
                    if (modules.find(m).empty)
                    {
                        f.writefln("import %s;", m);
                        modules ~= m;

                        if (m == moduleName!(core.sys.windows.unknwn))
                        {
                            f.writefln("import %s.guidutil;", packageName);
                            useGuid = true;
                        }
                    }
                }
            }

            // const
            foreach (macroDefinition; source.m_macros)
            {
                if (macroDefinition.value[0].isAlpha)
                {
                    // typedef ?
                    // IID_ID3DBlob = IID_ID3D10Blob;
                    // INTERFACE = ID3DInclude;
                    continue;
                }
                f.writefln("enum %s = %s;", macroDefinition.name, macroDefinition.value);
            }

            // types
            foreach (decl; source.m_types)
            {
                DDecl(&f, decl);
            }
        }
    }

    if (useGuid)
    {
        // write utility
        auto packageName = dir.baseName.stripExtension;
        auto path = format("%s/guidutil.d", dir);
        auto f = File(path, "w");
        f.writefln("module %s.guidutil;", packageName);
        f.writeln("
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
");
    }

    // write package.d
    {
        auto packageName = dir.baseName.stripExtension;
        auto path = format("%s/package.d", dir);
        auto f = File(path, "w");
        f.writefln("module %s;", packageName);
        foreach (k, source; sourceMap)
        {
            if (source.empty())
            {
                continue;
            }
            f.writefln("public import %s.%s;", packageName, source.getName());
        }
    }
}
