// This source code was generated by regenerator
module libclang.cxstring;
struct CXString
{
    const(void)* data;
    uint private_flags;
}
struct CXStringSet
{
    CXString* Strings;
    uint Count;
}
extern(C++) {
extern(C) const(char)* clang_getCString(CXString string);
extern(C) void clang_disposeString(CXString string);
extern(C) void clang_disposeStringSet(CXStringSet* set);
} // 
