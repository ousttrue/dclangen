module clanghelper;
import std.string;
import std.conv;
import std.file;
import std.array;
import libclang;

struct Source
{
    string path;
    byte[] content;
}

CXTranslationUnitImpl* getTU(void* index, string[] headers, string[] params)
{
    byte*[] c_params;
    foreach (param; params)
    {
        c_params ~= cast(byte*) param.toStringz();
    }
    if (headers.length == 1)
    {
        return clang_createTranslationUnitFromSourceFile(index,
                cast(byte*) headers[0].toStringz(), cast(int) params.length, c_params.ptr, 0, null);
    }
    else
    {
        auto sb=appender!string;
        foreach(header; headers)
        {
            sb.put(format("#include \"%s\"\n", header));
        }

        auto source = Source("__tmp__dclangen__.h", cast(byte[])sb.data);

        // use unsaved files
        CXUnsavedFile[] files;
        files ~= CXUnsavedFile(cast(byte*)source.path.ptr, source.content.ptr, cast(uint)source.content.length);

        return clang_createTranslationUnitFromSourceFile(index, cast(byte*) headers[0].toStringz(),
                cast(int) params.length, c_params.ptr, cast(uint) files.length, files.ptr);
    }
}

string CXStringToString(CXString cxs)
{
    auto p = clang_getCString(cxs);
    return to!string(cast(immutable char*) p);
}

string function(T) cxToString(T)(CXString function(T) func)
{
    return (T _) => {
        auto name = func(T);
        scope (exit)
            clang_disposeString(name);

        return CXStringToString(name);
    };
}

string getCursorKindName(CXCursorKind cursorKind)
{
    auto kindName = clang_getCursorKindSpelling(cursorKind);
    scope (exit)
        clang_disposeString(kindName);

    return CXStringToString(kindName);
}

string getCursorSpelling(CXCursor cursor)
{
    auto cursorSpelling = clang_getCursorSpelling(cursor);
    scope (exit)
        clang_disposeString(cursorSpelling);

    return CXStringToString(cursorSpelling);
}

string getCursorTypeKindName(CXTypeKind typeKind)
{
    auto kindName = clang_getTypeKindSpelling(typeKind);
    scope (exit)
        clang_disposeString(kindName);

    return CXStringToString(kindName);
}

struct Location
{
    string path;
    int line;
}

Location getCursorLocation(CXCursor cursor)
{
    auto location = clang_getCursorLocation(cursor);
    void* file;
    uint line;
    uint column;
    uint offset;
    clang_getInstantiationLocation(location, &file, &line, &column, &offset);
    auto path = CXStringToString(clang_getFileName(file));
    return Location(path, line);
}

CXToken[] getTokens(CXCursor cursor)
{
    auto extent = clang_getCursorExtent(cursor);
    auto begin = clang_getRangeStart(extent);
    auto end = clang_getRangeEnd(extent);
    auto range = clang_getRange(begin, end);

    CXToken* tokens;
    uint num;
    auto tu = clang_Cursor_getTranslationUnit(cursor);
    clang_tokenize(tu, range, &tokens, &num);

    return tokens[0 .. num];
}

string TerminatedString(string src)
{
    auto x = toStringz(src);
    auto y = x[0 .. src.length + 1];
    return to!string(y.ptr);
}
