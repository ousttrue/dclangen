module libclang.Index;
import libclang.CXString;
import libclang.corecrt;
import libclang.CXErrorCode;
alias CXIndex = void*;
struct CXTargetInfoImpl
{
}
alias CXTargetInfo = CXTargetInfoImpl*;
struct CXTranslationUnitImpl
{
}
alias CXTranslationUnit = CXTranslationUnitImpl*;
alias CXClientData = void*;
struct CXUnsavedFile
{
   byte* Filename;
   byte* Contents;
   uint Length;
}
enum CXAvailabilityKind
{
    CXAvailability_Available = 0x0,
    CXAvailability_Deprecated = 0x1,
    CXAvailability_NotAvailable = 0x2,
    CXAvailability_NotAccessible = 0x3,
}
struct CXVersion
{
   int Major;
   int Minor;
   int Subminor;
}
enum CXCursor_ExceptionSpecificationKind
{
    CXCursor_ExceptionSpecificationKind_None = 0x0,
    CXCursor_ExceptionSpecificationKind_DynamicNone = 0x1,
    CXCursor_ExceptionSpecificationKind_Dynamic = 0x2,
    CXCursor_ExceptionSpecificationKind_MSAny = 0x3,
    CXCursor_ExceptionSpecificationKind_BasicNoexcept = 0x4,
    CXCursor_ExceptionSpecificationKind_ComputedNoexcept = 0x5,
    CXCursor_ExceptionSpecificationKind_Unevaluated = 0x6,
    CXCursor_ExceptionSpecificationKind_Uninstantiated = 0x7,
    CXCursor_ExceptionSpecificationKind_Unparsed = 0x8,
    CXCursor_ExceptionSpecificationKind_NoThrow = 0x9,
}
extern(C) CXIndex clang_createIndex(int excludeDeclarationsFromPCH, int displayDiagnostics);
extern(C) void clang_disposeIndex(CXIndex index);
enum CXGlobalOptFlags
{
    CXGlobalOpt_None = 0x0,
    CXGlobalOpt_ThreadBackgroundPriorityForIndexing = 0x1,
    CXGlobalOpt_ThreadBackgroundPriorityForEditing = 0x2,
    CXGlobalOpt_ThreadBackgroundPriorityForAll = 0x3,
}
extern(C) void clang_CXIndex_setGlobalOptions(CXIndex , uint options);
extern(C) uint clang_CXIndex_getGlobalOptions(CXIndex );
extern(C) void clang_CXIndex_setInvocationEmissionPathOption(CXIndex , byte* Path);
alias CXFile = void*;
extern(C) CXString clang_getFileName(CXFile SFile);
extern(C) time_t clang_getFileTime(CXFile SFile);
struct CXFileUniqueID
{
   ulong[3] data;
}
extern(C) int clang_getFileUniqueID(CXFile file, CXFileUniqueID* outID);
extern(C) uint clang_isFileMultipleIncludeGuarded(CXTranslationUnit tu, CXFile file);
extern(C) CXFile clang_getFile(CXTranslationUnit tu, byte* file_name);
extern(C) byte* clang_getFileContents(CXTranslationUnit tu, CXFile file, size_t* size);
extern(C) int clang_File_isEqual(CXFile file1, CXFile file2);
extern(C) CXString clang_File_tryGetRealPathName(CXFile file);
struct CXSourceLocation
{
   void*[2] ptr_data;
   uint int_data;
}
struct CXSourceRange
{
   void*[2] ptr_data;
   uint begin_int_data;
   uint end_int_data;
}
extern(C) CXSourceLocation clang_getNullLocation();
extern(C) uint clang_equalLocations(CXSourceLocation loc1, CXSourceLocation loc2);
extern(C) CXSourceLocation clang_getLocation(CXTranslationUnit tu, CXFile file, uint line, uint column);
extern(C) CXSourceLocation clang_getLocationForOffset(CXTranslationUnit tu, CXFile file, uint offset);
extern(C) int clang_Location_isInSystemHeader(CXSourceLocation location);
extern(C) int clang_Location_isFromMainFile(CXSourceLocation location);
extern(C) CXSourceRange clang_getNullRange();
extern(C) CXSourceRange clang_getRange(CXSourceLocation begin, CXSourceLocation end);
extern(C) uint clang_equalRanges(CXSourceRange range1, CXSourceRange range2);
extern(C) int clang_Range_isNull(CXSourceRange range);
extern(C) void clang_getExpansionLocation(CXSourceLocation location, CXFile* file, uint* line, uint* column, uint* offset);
extern(C) void clang_getPresumedLocation(CXSourceLocation location, CXString* filename, uint* line, uint* column);
extern(C) void clang_getInstantiationLocation(CXSourceLocation location, CXFile* file, uint* line, uint* column, uint* offset);
extern(C) void clang_getSpellingLocation(CXSourceLocation location, CXFile* file, uint* line, uint* column, uint* offset);
extern(C) void clang_getFileLocation(CXSourceLocation location, CXFile* file, uint* line, uint* column, uint* offset);
extern(C) CXSourceLocation clang_getRangeStart(CXSourceRange range);
extern(C) CXSourceLocation clang_getRangeEnd(CXSourceRange range);
struct CXSourceRangeList
{
   uint count;
   CXSourceRange* ranges;
}
extern(C) CXSourceRangeList* clang_getSkippedRanges(CXTranslationUnit tu, CXFile file);
extern(C) CXSourceRangeList* clang_getAllSkippedRanges(CXTranslationUnit tu);
extern(C) void clang_disposeSourceRangeList(CXSourceRangeList* ranges);
enum CXDiagnosticSeverity
{
    CXDiagnostic_Ignored = 0x0,
    CXDiagnostic_Note = 0x1,
    CXDiagnostic_Warning = 0x2,
    CXDiagnostic_Error = 0x3,
    CXDiagnostic_Fatal = 0x4,
}
alias CXDiagnostic = void*;
alias CXDiagnosticSet = void*;
extern(C) uint clang_getNumDiagnosticsInSet(CXDiagnosticSet Diags);
extern(C) CXDiagnostic clang_getDiagnosticInSet(CXDiagnosticSet Diags, uint Index);
enum CXLoadDiag_Error
{
    CXLoadDiag_None = 0x0,
    CXLoadDiag_Unknown = 0x1,
    CXLoadDiag_CannotLoad = 0x2,
    CXLoadDiag_InvalidFile = 0x3,
}
extern(C) CXDiagnosticSet clang_loadDiagnostics(byte* file, CXLoadDiag_Error* error, CXString* errorString);
extern(C) void clang_disposeDiagnosticSet(CXDiagnosticSet Diags);
extern(C) CXDiagnosticSet clang_getChildDiagnostics(CXDiagnostic D);
extern(C) uint clang_getNumDiagnostics(CXTranslationUnit Unit);
extern(C) CXDiagnostic clang_getDiagnostic(CXTranslationUnit Unit, uint Index);
extern(C) CXDiagnosticSet clang_getDiagnosticSetFromTU(CXTranslationUnit Unit);
extern(C) void clang_disposeDiagnostic(CXDiagnostic Diagnostic);
enum CXDiagnosticDisplayOptions
{
    CXDiagnostic_DisplaySourceLocation = 0x1,
    CXDiagnostic_DisplayColumn = 0x2,
    CXDiagnostic_DisplaySourceRanges = 0x4,
    CXDiagnostic_DisplayOption = 0x8,
    CXDiagnostic_DisplayCategoryId = 0x10,
    CXDiagnostic_DisplayCategoryName = 0x20,
}
extern(C) CXString clang_formatDiagnostic(CXDiagnostic Diagnostic, uint Options);
extern(C) uint clang_defaultDiagnosticDisplayOptions();
extern(C) CXDiagnosticSeverity clang_getDiagnosticSeverity(CXDiagnostic );
extern(C) CXSourceLocation clang_getDiagnosticLocation(CXDiagnostic );
extern(C) CXString clang_getDiagnosticSpelling(CXDiagnostic );
extern(C) CXString clang_getDiagnosticOption(CXDiagnostic Diag, CXString* Disable);
extern(C) uint clang_getDiagnosticCategory(CXDiagnostic );
extern(C) CXString clang_getDiagnosticCategoryName(uint Category);
extern(C) CXString clang_getDiagnosticCategoryText(CXDiagnostic );
extern(C) uint clang_getDiagnosticNumRanges(CXDiagnostic );
extern(C) CXSourceRange clang_getDiagnosticRange(CXDiagnostic Diagnostic, uint Range);
extern(C) uint clang_getDiagnosticNumFixIts(CXDiagnostic Diagnostic);
extern(C) CXString clang_getDiagnosticFixIt(CXDiagnostic Diagnostic, uint FixIt, CXSourceRange* ReplacementRange);
extern(C) CXString clang_getTranslationUnitSpelling(CXTranslationUnit CTUnit);
extern(C) CXTranslationUnit clang_createTranslationUnitFromSourceFile(CXIndex CIdx, byte* source_filename, int num_clang_command_line_args, byte** clang_command_line_args, uint num_unsaved_files, CXUnsavedFile* unsaved_files);
extern(C) CXTranslationUnit clang_createTranslationUnit(CXIndex CIdx, byte* ast_filename);
extern(C) CXErrorCode clang_createTranslationUnit2(CXIndex CIdx, byte* ast_filename, CXTranslationUnit* out_TU);
enum CXTranslationUnit_Flags
{
    CXTranslationUnit_None = 0x0,
    CXTranslationUnit_DetailedPreprocessingRecord = 0x1,
    CXTranslationUnit_Incomplete = 0x2,
    CXTranslationUnit_PrecompiledPreamble = 0x4,
    CXTranslationUnit_CacheCompletionResults = 0x8,
    CXTranslationUnit_ForSerialization = 0x10,
    CXTranslationUnit_CXXChainedPCH = 0x20,
    CXTranslationUnit_SkipFunctionBodies = 0x40,
    CXTranslationUnit_IncludeBriefCommentsInCodeCompletion = 0x80,
    CXTranslationUnit_CreatePreambleOnFirstParse = 0x100,
    CXTranslationUnit_KeepGoing = 0x200,
    CXTranslationUnit_SingleFileParse = 0x400,
    CXTranslationUnit_LimitSkipFunctionBodiesToPreamble = 0x800,
    CXTranslationUnit_IncludeAttributedTypes = 0x1000,
    CXTranslationUnit_VisitImplicitAttributes = 0x2000,
    CXTranslationUnit_IgnoreNonErrorsFromIncludedFiles = 0x4000,
}
extern(C) uint clang_defaultEditingTranslationUnitOptions();
extern(C) CXTranslationUnit clang_parseTranslationUnit(CXIndex CIdx, byte* source_filename, byte** command_line_args, int num_command_line_args, CXUnsavedFile* unsaved_files, uint num_unsaved_files, uint options);
extern(C) CXErrorCode clang_parseTranslationUnit2(CXIndex CIdx, byte* source_filename, byte** command_line_args, int num_command_line_args, CXUnsavedFile* unsaved_files, uint num_unsaved_files, uint options, CXTranslationUnit* out_TU);
extern(C) CXErrorCode clang_parseTranslationUnit2FullArgv(CXIndex CIdx, byte* source_filename, byte** command_line_args, int num_command_line_args, CXUnsavedFile* unsaved_files, uint num_unsaved_files, uint options, CXTranslationUnit* out_TU);
enum CXSaveTranslationUnit_Flags
{
    CXSaveTranslationUnit_None = 0x0,
}
extern(C) uint clang_defaultSaveOptions(CXTranslationUnit TU);
enum CXSaveError
{
    CXSaveError_None = 0x0,
    CXSaveError_Unknown = 0x1,
    CXSaveError_TranslationErrors = 0x2,
    CXSaveError_InvalidTU = 0x3,
}
extern(C) int clang_saveTranslationUnit(CXTranslationUnit TU, byte* FileName, uint options);
extern(C) uint clang_suspendTranslationUnit(CXTranslationUnit );
extern(C) void clang_disposeTranslationUnit(CXTranslationUnit );
enum CXReparse_Flags
{
    CXReparse_None = 0x0,
}
extern(C) uint clang_defaultReparseOptions(CXTranslationUnit TU);
extern(C) int clang_reparseTranslationUnit(CXTranslationUnit TU, uint num_unsaved_files, CXUnsavedFile* unsaved_files, uint options);
enum CXTUResourceUsageKind
{
    CXTUResourceUsage_AST = 0x1,
    CXTUResourceUsage_Identifiers = 0x2,
    CXTUResourceUsage_Selectors = 0x3,
    CXTUResourceUsage_GlobalCompletionResults = 0x4,
    CXTUResourceUsage_SourceManagerContentCache = 0x5,
    CXTUResourceUsage_AST_SideTables = 0x6,
    CXTUResourceUsage_SourceManager_Membuffer_Malloc = 0x7,
    CXTUResourceUsage_SourceManager_Membuffer_MMap = 0x8,
    CXTUResourceUsage_ExternalASTSource_Membuffer_Malloc = 0x9,
    CXTUResourceUsage_ExternalASTSource_Membuffer_MMap = 0xa,
    CXTUResourceUsage_Preprocessor = 0xb,
    CXTUResourceUsage_PreprocessingRecord = 0xc,
    CXTUResourceUsage_SourceManager_DataStructures = 0xd,
    CXTUResourceUsage_Preprocessor_HeaderSearch = 0xe,
    CXTUResourceUsage_MEMORY_IN_BYTES_BEGIN = 0x1,
    CXTUResourceUsage_MEMORY_IN_BYTES_END = 0xe,
    CXTUResourceUsage_First = 0x1,
    CXTUResourceUsage_Last = 0xe,
}
extern(C) byte* clang_getTUResourceUsageName(CXTUResourceUsageKind kind);
struct CXTUResourceUsageEntry
{
   CXTUResourceUsageKind kind;
   uint amount;
}
struct CXTUResourceUsage
{
   void* data;
   uint numEntries;
   CXTUResourceUsageEntry* entries;
}
extern(C) CXTUResourceUsage clang_getCXTUResourceUsage(CXTranslationUnit TU);
extern(C) void clang_disposeCXTUResourceUsage(CXTUResourceUsage usage);
extern(C) CXTargetInfo clang_getTranslationUnitTargetInfo(CXTranslationUnit CTUnit);
extern(C) void clang_TargetInfo_dispose(CXTargetInfo Info);
extern(C) CXString clang_TargetInfo_getTriple(CXTargetInfo Info);
extern(C) int clang_TargetInfo_getPointerWidth(CXTargetInfo Info);
enum CXCursorKind
{
    CXCursor_UnexposedDecl = 0x1,
    CXCursor_StructDecl = 0x2,
    CXCursor_UnionDecl = 0x3,
    CXCursor_ClassDecl = 0x4,
    CXCursor_EnumDecl = 0x5,
    CXCursor_FieldDecl = 0x6,
    CXCursor_EnumConstantDecl = 0x7,
    CXCursor_FunctionDecl = 0x8,
    CXCursor_VarDecl = 0x9,
    CXCursor_ParmDecl = 0xa,
    CXCursor_ObjCInterfaceDecl = 0xb,
    CXCursor_ObjCCategoryDecl = 0xc,
    CXCursor_ObjCProtocolDecl = 0xd,
    CXCursor_ObjCPropertyDecl = 0xe,
    CXCursor_ObjCIvarDecl = 0xf,
    CXCursor_ObjCInstanceMethodDecl = 0x10,
    CXCursor_ObjCClassMethodDecl = 0x11,
    CXCursor_ObjCImplementationDecl = 0x12,
    CXCursor_ObjCCategoryImplDecl = 0x13,
    CXCursor_TypedefDecl = 0x14,
    CXCursor_CXXMethod = 0x15,
    CXCursor_Namespace = 0x16,
    CXCursor_LinkageSpec = 0x17,
    CXCursor_Constructor = 0x18,
    CXCursor_Destructor = 0x19,
    CXCursor_ConversionFunction = 0x1a,
    CXCursor_TemplateTypeParameter = 0x1b,
    CXCursor_NonTypeTemplateParameter = 0x1c,
    CXCursor_TemplateTemplateParameter = 0x1d,
    CXCursor_FunctionTemplate = 0x1e,
    CXCursor_ClassTemplate = 0x1f,
    CXCursor_ClassTemplatePartialSpecialization = 0x20,
    CXCursor_NamespaceAlias = 0x21,
    CXCursor_UsingDirective = 0x22,
    CXCursor_UsingDeclaration = 0x23,
    CXCursor_TypeAliasDecl = 0x24,
    CXCursor_ObjCSynthesizeDecl = 0x25,
    CXCursor_ObjCDynamicDecl = 0x26,
    CXCursor_CXXAccessSpecifier = 0x27,
    CXCursor_FirstDecl = 0x1,
    CXCursor_LastDecl = 0x27,
    CXCursor_FirstRef = 0x28,
    CXCursor_ObjCSuperClassRef = 0x28,
    CXCursor_ObjCProtocolRef = 0x29,
    CXCursor_ObjCClassRef = 0x2a,
    CXCursor_TypeRef = 0x2b,
    CXCursor_CXXBaseSpecifier = 0x2c,
    CXCursor_TemplateRef = 0x2d,
    CXCursor_NamespaceRef = 0x2e,
    CXCursor_MemberRef = 0x2f,
    CXCursor_LabelRef = 0x30,
    CXCursor_OverloadedDeclRef = 0x31,
    CXCursor_VariableRef = 0x32,
    CXCursor_LastRef = 0x32,
    CXCursor_FirstInvalid = 0x46,
    CXCursor_InvalidFile = 0x46,
    CXCursor_NoDeclFound = 0x47,
    CXCursor_NotImplemented = 0x48,
    CXCursor_InvalidCode = 0x49,
    CXCursor_LastInvalid = 0x49,
    CXCursor_FirstExpr = 0x64,
    CXCursor_UnexposedExpr = 0x64,
    CXCursor_DeclRefExpr = 0x65,
    CXCursor_MemberRefExpr = 0x66,
    CXCursor_CallExpr = 0x67,
    CXCursor_ObjCMessageExpr = 0x68,
    CXCursor_BlockExpr = 0x69,
    CXCursor_IntegerLiteral = 0x6a,
    CXCursor_FloatingLiteral = 0x6b,
    CXCursor_ImaginaryLiteral = 0x6c,
    CXCursor_StringLiteral = 0x6d,
    CXCursor_CharacterLiteral = 0x6e,
    CXCursor_ParenExpr = 0x6f,
    CXCursor_UnaryOperator = 0x70,
    CXCursor_ArraySubscriptExpr = 0x71,
    CXCursor_BinaryOperator = 0x72,
    CXCursor_CompoundAssignOperator = 0x73,
    CXCursor_ConditionalOperator = 0x74,
    CXCursor_CStyleCastExpr = 0x75,
    CXCursor_CompoundLiteralExpr = 0x76,
    CXCursor_InitListExpr = 0x77,
    CXCursor_AddrLabelExpr = 0x78,
    CXCursor_StmtExpr = 0x79,
    CXCursor_GenericSelectionExpr = 0x7a,
    CXCursor_GNUNullExpr = 0x7b,
    CXCursor_CXXStaticCastExpr = 0x7c,
    CXCursor_CXXDynamicCastExpr = 0x7d,
    CXCursor_CXXReinterpretCastExpr = 0x7e,
    CXCursor_CXXConstCastExpr = 0x7f,
    CXCursor_CXXFunctionalCastExpr = 0x80,
    CXCursor_CXXTypeidExpr = 0x81,
    CXCursor_CXXBoolLiteralExpr = 0x82,
    CXCursor_CXXNullPtrLiteralExpr = 0x83,
    CXCursor_CXXThisExpr = 0x84,
    CXCursor_CXXThrowExpr = 0x85,
    CXCursor_CXXNewExpr = 0x86,
    CXCursor_CXXDeleteExpr = 0x87,
    CXCursor_UnaryExpr = 0x88,
    CXCursor_ObjCStringLiteral = 0x89,
    CXCursor_ObjCEncodeExpr = 0x8a,
    CXCursor_ObjCSelectorExpr = 0x8b,
    CXCursor_ObjCProtocolExpr = 0x8c,
    CXCursor_ObjCBridgedCastExpr = 0x8d,
    CXCursor_PackExpansionExpr = 0x8e,
    CXCursor_SizeOfPackExpr = 0x8f,
    CXCursor_LambdaExpr = 0x90,
    CXCursor_ObjCBoolLiteralExpr = 0x91,
    CXCursor_ObjCSelfExpr = 0x92,
    CXCursor_OMPArraySectionExpr = 0x93,
    CXCursor_ObjCAvailabilityCheckExpr = 0x94,
    CXCursor_FixedPointLiteral = 0x95,
    CXCursor_LastExpr = 0x95,
    CXCursor_FirstStmt = 0xc8,
    CXCursor_UnexposedStmt = 0xc8,
    CXCursor_LabelStmt = 0xc9,
    CXCursor_CompoundStmt = 0xca,
    CXCursor_CaseStmt = 0xcb,
    CXCursor_DefaultStmt = 0xcc,
    CXCursor_IfStmt = 0xcd,
    CXCursor_SwitchStmt = 0xce,
    CXCursor_WhileStmt = 0xcf,
    CXCursor_DoStmt = 0xd0,
    CXCursor_ForStmt = 0xd1,
    CXCursor_GotoStmt = 0xd2,
    CXCursor_IndirectGotoStmt = 0xd3,
    CXCursor_ContinueStmt = 0xd4,
    CXCursor_BreakStmt = 0xd5,
    CXCursor_ReturnStmt = 0xd6,
    CXCursor_GCCAsmStmt = 0xd7,
    CXCursor_AsmStmt = 0xd7,
    CXCursor_ObjCAtTryStmt = 0xd8,
    CXCursor_ObjCAtCatchStmt = 0xd9,
    CXCursor_ObjCAtFinallyStmt = 0xda,
    CXCursor_ObjCAtThrowStmt = 0xdb,
    CXCursor_ObjCAtSynchronizedStmt = 0xdc,
    CXCursor_ObjCAutoreleasePoolStmt = 0xdd,
    CXCursor_ObjCForCollectionStmt = 0xde,
    CXCursor_CXXCatchStmt = 0xdf,
    CXCursor_CXXTryStmt = 0xe0,
    CXCursor_CXXForRangeStmt = 0xe1,
    CXCursor_SEHTryStmt = 0xe2,
    CXCursor_SEHExceptStmt = 0xe3,
    CXCursor_SEHFinallyStmt = 0xe4,
    CXCursor_MSAsmStmt = 0xe5,
    CXCursor_NullStmt = 0xe6,
    CXCursor_DeclStmt = 0xe7,
    CXCursor_OMPParallelDirective = 0xe8,
    CXCursor_OMPSimdDirective = 0xe9,
    CXCursor_OMPForDirective = 0xea,
    CXCursor_OMPSectionsDirective = 0xeb,
    CXCursor_OMPSectionDirective = 0xec,
    CXCursor_OMPSingleDirective = 0xed,
    CXCursor_OMPParallelForDirective = 0xee,
    CXCursor_OMPParallelSectionsDirective = 0xef,
    CXCursor_OMPTaskDirective = 0xf0,
    CXCursor_OMPMasterDirective = 0xf1,
    CXCursor_OMPCriticalDirective = 0xf2,
    CXCursor_OMPTaskyieldDirective = 0xf3,
    CXCursor_OMPBarrierDirective = 0xf4,
    CXCursor_OMPTaskwaitDirective = 0xf5,
    CXCursor_OMPFlushDirective = 0xf6,
    CXCursor_SEHLeaveStmt = 0xf7,
    CXCursor_OMPOrderedDirective = 0xf8,
    CXCursor_OMPAtomicDirective = 0xf9,
    CXCursor_OMPForSimdDirective = 0xfa,
    CXCursor_OMPParallelForSimdDirective = 0xfb,
    CXCursor_OMPTargetDirective = 0xfc,
    CXCursor_OMPTeamsDirective = 0xfd,
    CXCursor_OMPTaskgroupDirective = 0xfe,
    CXCursor_OMPCancellationPointDirective = 0xff,
    CXCursor_OMPCancelDirective = 0x100,
    CXCursor_OMPTargetDataDirective = 0x101,
    CXCursor_OMPTaskLoopDirective = 0x102,
    CXCursor_OMPTaskLoopSimdDirective = 0x103,
    CXCursor_OMPDistributeDirective = 0x104,
    CXCursor_OMPTargetEnterDataDirective = 0x105,
    CXCursor_OMPTargetExitDataDirective = 0x106,
    CXCursor_OMPTargetParallelDirective = 0x107,
    CXCursor_OMPTargetParallelForDirective = 0x108,
    CXCursor_OMPTargetUpdateDirective = 0x109,
    CXCursor_OMPDistributeParallelForDirective = 0x10a,
    CXCursor_OMPDistributeParallelForSimdDirective = 0x10b,
    CXCursor_OMPDistributeSimdDirective = 0x10c,
    CXCursor_OMPTargetParallelForSimdDirective = 0x10d,
    CXCursor_OMPTargetSimdDirective = 0x10e,
    CXCursor_OMPTeamsDistributeDirective = 0x10f,
    CXCursor_OMPTeamsDistributeSimdDirective = 0x110,
    CXCursor_OMPTeamsDistributeParallelForSimdDirective = 0x111,
    CXCursor_OMPTeamsDistributeParallelForDirective = 0x112,
    CXCursor_OMPTargetTeamsDirective = 0x113,
    CXCursor_OMPTargetTeamsDistributeDirective = 0x114,
    CXCursor_OMPTargetTeamsDistributeParallelForDirective = 0x115,
    CXCursor_OMPTargetTeamsDistributeParallelForSimdDirective = 0x116,
    CXCursor_OMPTargetTeamsDistributeSimdDirective = 0x117,
    CXCursor_BuiltinBitCastExpr = 0x118,
    CXCursor_LastStmt = 0x118,
    CXCursor_TranslationUnit = 0x12c,
    CXCursor_FirstAttr = 0x190,
    CXCursor_UnexposedAttr = 0x190,
    CXCursor_IBActionAttr = 0x191,
    CXCursor_IBOutletAttr = 0x192,
    CXCursor_IBOutletCollectionAttr = 0x193,
    CXCursor_CXXFinalAttr = 0x194,
    CXCursor_CXXOverrideAttr = 0x195,
    CXCursor_AnnotateAttr = 0x196,
    CXCursor_AsmLabelAttr = 0x197,
    CXCursor_PackedAttr = 0x198,
    CXCursor_PureAttr = 0x199,
    CXCursor_ConstAttr = 0x19a,
    CXCursor_NoDuplicateAttr = 0x19b,
    CXCursor_CUDAConstantAttr = 0x19c,
    CXCursor_CUDADeviceAttr = 0x19d,
    CXCursor_CUDAGlobalAttr = 0x19e,
    CXCursor_CUDAHostAttr = 0x19f,
    CXCursor_CUDASharedAttr = 0x1a0,
    CXCursor_VisibilityAttr = 0x1a1,
    CXCursor_DLLExport = 0x1a2,
    CXCursor_DLLImport = 0x1a3,
    CXCursor_NSReturnsRetained = 0x1a4,
    CXCursor_NSReturnsNotRetained = 0x1a5,
    CXCursor_NSReturnsAutoreleased = 0x1a6,
    CXCursor_NSConsumesSelf = 0x1a7,
    CXCursor_NSConsumed = 0x1a8,
    CXCursor_ObjCException = 0x1a9,
    CXCursor_ObjCNSObject = 0x1aa,
    CXCursor_ObjCIndependentClass = 0x1ab,
    CXCursor_ObjCPreciseLifetime = 0x1ac,
    CXCursor_ObjCReturnsInnerPointer = 0x1ad,
    CXCursor_ObjCRequiresSuper = 0x1ae,
    CXCursor_ObjCRootClass = 0x1af,
    CXCursor_ObjCSubclassingRestricted = 0x1b0,
    CXCursor_ObjCExplicitProtocolImpl = 0x1b1,
    CXCursor_ObjCDesignatedInitializer = 0x1b2,
    CXCursor_ObjCRuntimeVisible = 0x1b3,
    CXCursor_ObjCBoxable = 0x1b4,
    CXCursor_FlagEnum = 0x1b5,
    CXCursor_ConvergentAttr = 0x1b6,
    CXCursor_WarnUnusedAttr = 0x1b7,
    CXCursor_WarnUnusedResultAttr = 0x1b8,
    CXCursor_AlignedAttr = 0x1b9,
    CXCursor_LastAttr = 0x1b9,
    CXCursor_PreprocessingDirective = 0x1f4,
    CXCursor_MacroDefinition = 0x1f5,
    CXCursor_MacroExpansion = 0x1f6,
    CXCursor_MacroInstantiation = 0x1f6,
    CXCursor_InclusionDirective = 0x1f7,
    CXCursor_FirstPreprocessing = 0x1f4,
    CXCursor_LastPreprocessing = 0x1f7,
    CXCursor_ModuleImportDecl = 0x258,
    CXCursor_TypeAliasTemplateDecl = 0x259,
    CXCursor_StaticAssert = 0x25a,
    CXCursor_FriendDecl = 0x25b,
    CXCursor_FirstExtraDecl = 0x258,
    CXCursor_LastExtraDecl = 0x25b,
    CXCursor_OverloadCandidate = 0x2bc,
}
struct CXCursor
{
   CXCursorKind kind;
   int xdata;
   void*[3] data;
}
extern(C) CXCursor clang_getNullCursor();
extern(C) CXCursor clang_getTranslationUnitCursor(CXTranslationUnit );
extern(C) uint clang_equalCursors(CXCursor , CXCursor );
extern(C) int clang_Cursor_isNull(CXCursor cursor);
extern(C) uint clang_hashCursor(CXCursor );
extern(C) CXCursorKind clang_getCursorKind(CXCursor );
extern(C) uint clang_isDeclaration(CXCursorKind );
extern(C) uint clang_isInvalidDeclaration(CXCursor );
extern(C) uint clang_isReference(CXCursorKind );
extern(C) uint clang_isExpression(CXCursorKind );
extern(C) uint clang_isStatement(CXCursorKind );
extern(C) uint clang_isAttribute(CXCursorKind );
extern(C) uint clang_Cursor_hasAttrs(CXCursor C);
extern(C) uint clang_isInvalid(CXCursorKind );
extern(C) uint clang_isTranslationUnit(CXCursorKind );
extern(C) uint clang_isPreprocessing(CXCursorKind );
extern(C) uint clang_isUnexposed(CXCursorKind );
enum CXLinkageKind
{
    CXLinkage_Invalid = 0x0,
    CXLinkage_NoLinkage = 0x1,
    CXLinkage_Internal = 0x2,
    CXLinkage_UniqueExternal = 0x3,
    CXLinkage_External = 0x4,
}
extern(C) CXLinkageKind clang_getCursorLinkage(CXCursor cursor);
enum CXVisibilityKind
{
    CXVisibility_Invalid = 0x0,
    CXVisibility_Hidden = 0x1,
    CXVisibility_Protected = 0x2,
    CXVisibility_Default = 0x3,
}
extern(C) CXVisibilityKind clang_getCursorVisibility(CXCursor cursor);
extern(C) CXAvailabilityKind clang_getCursorAvailability(CXCursor cursor);
struct CXPlatformAvailability
{
   CXString Platform;
   CXVersion Introduced;
   CXVersion Deprecated;
   CXVersion Obsoleted;
   int Unavailable;
   CXString Message;
}
extern(C) int clang_getCursorPlatformAvailability(CXCursor cursor, int* always_deprecated, CXString* deprecated_message, int* always_unavailable, CXString* unavailable_message, CXPlatformAvailability* availability, int availability_size);
extern(C) void clang_disposeCXPlatformAvailability(CXPlatformAvailability* availability);
enum CXLanguageKind
{
    CXLanguage_Invalid = 0x0,
    CXLanguage_C = 0x1,
    CXLanguage_ObjC = 0x2,
    CXLanguage_CPlusPlus = 0x3,
}
extern(C) CXLanguageKind clang_getCursorLanguage(CXCursor cursor);
enum CXTLSKind
{
    CXTLS_None = 0x0,
    CXTLS_Dynamic = 0x1,
    CXTLS_Static = 0x2,
}
extern(C) CXTLSKind clang_getCursorTLSKind(CXCursor cursor);
extern(C) CXTranslationUnit clang_Cursor_getTranslationUnit(CXCursor );
struct CXCursorSetImpl
{
}
alias CXCursorSet = CXCursorSetImpl*;
extern(C) CXCursorSet clang_createCXCursorSet();
extern(C) void clang_disposeCXCursorSet(CXCursorSet cset);
extern(C) uint clang_CXCursorSet_contains(CXCursorSet cset, CXCursor cursor);
extern(C) uint clang_CXCursorSet_insert(CXCursorSet cset, CXCursor cursor);
extern(C) CXCursor clang_getCursorSemanticParent(CXCursor cursor);
extern(C) CXCursor clang_getCursorLexicalParent(CXCursor cursor);
extern(C) void clang_getOverriddenCursors(CXCursor cursor, CXCursor** overridden, uint* num_overridden);
extern(C) void clang_disposeOverriddenCursors(CXCursor* overridden);
extern(C) CXFile clang_getIncludedFile(CXCursor cursor);
extern(C) CXCursor clang_getCursor(CXTranslationUnit , CXSourceLocation );
extern(C) CXSourceLocation clang_getCursorLocation(CXCursor );
extern(C) CXSourceRange clang_getCursorExtent(CXCursor );
enum CXTypeKind
{
    CXType_Invalid = 0x0,
    CXType_Unexposed = 0x1,
    CXType_Void = 0x2,
    CXType_Bool = 0x3,
    CXType_Char_U = 0x4,
    CXType_UChar = 0x5,
    CXType_Char16 = 0x6,
    CXType_Char32 = 0x7,
    CXType_UShort = 0x8,
    CXType_UInt = 0x9,
    CXType_ULong = 0xa,
    CXType_ULongLong = 0xb,
    CXType_UInt128 = 0xc,
    CXType_Char_S = 0xd,
    CXType_SChar = 0xe,
    CXType_WChar = 0xf,
    CXType_Short = 0x10,
    CXType_Int = 0x11,
    CXType_Long = 0x12,
    CXType_LongLong = 0x13,
    CXType_Int128 = 0x14,
    CXType_Float = 0x15,
    CXType_Double = 0x16,
    CXType_LongDouble = 0x17,
    CXType_NullPtr = 0x18,
    CXType_Overload = 0x19,
    CXType_Dependent = 0x1a,
    CXType_ObjCId = 0x1b,
    CXType_ObjCClass = 0x1c,
    CXType_ObjCSel = 0x1d,
    CXType_Float128 = 0x1e,
    CXType_Half = 0x1f,
    CXType_Float16 = 0x20,
    CXType_ShortAccum = 0x21,
    CXType_Accum = 0x22,
    CXType_LongAccum = 0x23,
    CXType_UShortAccum = 0x24,
    CXType_UAccum = 0x25,
    CXType_ULongAccum = 0x26,
    CXType_FirstBuiltin = 0x2,
    CXType_LastBuiltin = 0x26,
    CXType_Complex = 0x64,
    CXType_Pointer = 0x65,
    CXType_BlockPointer = 0x66,
    CXType_LValueReference = 0x67,
    CXType_RValueReference = 0x68,
    CXType_Record = 0x69,
    CXType_Enum = 0x6a,
    CXType_Typedef = 0x6b,
    CXType_ObjCInterface = 0x6c,
    CXType_ObjCObjectPointer = 0x6d,
    CXType_FunctionNoProto = 0x6e,
    CXType_FunctionProto = 0x6f,
    CXType_ConstantArray = 0x70,
    CXType_Vector = 0x71,
    CXType_IncompleteArray = 0x72,
    CXType_VariableArray = 0x73,
    CXType_DependentSizedArray = 0x74,
    CXType_MemberPointer = 0x75,
    CXType_Auto = 0x76,
    CXType_Elaborated = 0x77,
    CXType_Pipe = 0x78,
    CXType_OCLImage1dRO = 0x79,
    CXType_OCLImage1dArrayRO = 0x7a,
    CXType_OCLImage1dBufferRO = 0x7b,
    CXType_OCLImage2dRO = 0x7c,
    CXType_OCLImage2dArrayRO = 0x7d,
    CXType_OCLImage2dDepthRO = 0x7e,
    CXType_OCLImage2dArrayDepthRO = 0x7f,
    CXType_OCLImage2dMSAARO = 0x80,
    CXType_OCLImage2dArrayMSAARO = 0x81,
    CXType_OCLImage2dMSAADepthRO = 0x82,
    CXType_OCLImage2dArrayMSAADepthRO = 0x83,
    CXType_OCLImage3dRO = 0x84,
    CXType_OCLImage1dWO = 0x85,
    CXType_OCLImage1dArrayWO = 0x86,
    CXType_OCLImage1dBufferWO = 0x87,
    CXType_OCLImage2dWO = 0x88,
    CXType_OCLImage2dArrayWO = 0x89,
    CXType_OCLImage2dDepthWO = 0x8a,
    CXType_OCLImage2dArrayDepthWO = 0x8b,
    CXType_OCLImage2dMSAAWO = 0x8c,
    CXType_OCLImage2dArrayMSAAWO = 0x8d,
    CXType_OCLImage2dMSAADepthWO = 0x8e,
    CXType_OCLImage2dArrayMSAADepthWO = 0x8f,
    CXType_OCLImage3dWO = 0x90,
    CXType_OCLImage1dRW = 0x91,
    CXType_OCLImage1dArrayRW = 0x92,
    CXType_OCLImage1dBufferRW = 0x93,
    CXType_OCLImage2dRW = 0x94,
    CXType_OCLImage2dArrayRW = 0x95,
    CXType_OCLImage2dDepthRW = 0x96,
    CXType_OCLImage2dArrayDepthRW = 0x97,
    CXType_OCLImage2dMSAARW = 0x98,
    CXType_OCLImage2dArrayMSAARW = 0x99,
    CXType_OCLImage2dMSAADepthRW = 0x9a,
    CXType_OCLImage2dArrayMSAADepthRW = 0x9b,
    CXType_OCLImage3dRW = 0x9c,
    CXType_OCLSampler = 0x9d,
    CXType_OCLEvent = 0x9e,
    CXType_OCLQueue = 0x9f,
    CXType_OCLReserveID = 0xa0,
    CXType_ObjCObject = 0xa1,
    CXType_ObjCTypeParam = 0xa2,
    CXType_Attributed = 0xa3,
    CXType_OCLIntelSubgroupAVCMcePayload = 0xa4,
    CXType_OCLIntelSubgroupAVCImePayload = 0xa5,
    CXType_OCLIntelSubgroupAVCRefPayload = 0xa6,
    CXType_OCLIntelSubgroupAVCSicPayload = 0xa7,
    CXType_OCLIntelSubgroupAVCMceResult = 0xa8,
    CXType_OCLIntelSubgroupAVCImeResult = 0xa9,
    CXType_OCLIntelSubgroupAVCRefResult = 0xaa,
    CXType_OCLIntelSubgroupAVCSicResult = 0xab,
    CXType_OCLIntelSubgroupAVCImeResultSingleRefStreamout = 0xac,
    CXType_OCLIntelSubgroupAVCImeResultDualRefStreamout = 0xad,
    CXType_OCLIntelSubgroupAVCImeSingleRefStreamin = 0xae,
    CXType_OCLIntelSubgroupAVCImeDualRefStreamin = 0xaf,
    CXType_ExtVector = 0xb0,
}
enum CXCallingConv
{
    CXCallingConv_Default = 0x0,
    CXCallingConv_C = 0x1,
    CXCallingConv_X86StdCall = 0x2,
    CXCallingConv_X86FastCall = 0x3,
    CXCallingConv_X86ThisCall = 0x4,
    CXCallingConv_X86Pascal = 0x5,
    CXCallingConv_AAPCS = 0x6,
    CXCallingConv_AAPCS_VFP = 0x7,
    CXCallingConv_X86RegCall = 0x8,
    CXCallingConv_IntelOclBicc = 0x9,
    CXCallingConv_Win64 = 0xa,
    CXCallingConv_X86_64Win64 = 0xa,
    CXCallingConv_X86_64SysV = 0xb,
    CXCallingConv_X86VectorCall = 0xc,
    CXCallingConv_Swift = 0xd,
    CXCallingConv_PreserveMost = 0xe,
    CXCallingConv_PreserveAll = 0xf,
    CXCallingConv_AArch64VectorCall = 0x10,
    CXCallingConv_Invalid = 0x64,
    CXCallingConv_Unexposed = 0xc8,
}
struct CXType
{
   CXTypeKind kind;
   void*[2] data;
}
extern(C) CXType clang_getCursorType(CXCursor C);
extern(C) CXString clang_getTypeSpelling(CXType CT);
extern(C) CXType clang_getTypedefDeclUnderlyingType(CXCursor C);
extern(C) CXType clang_getEnumDeclIntegerType(CXCursor C);
extern(C) long clang_getEnumConstantDeclValue(CXCursor C);
extern(C) ulong clang_getEnumConstantDeclUnsignedValue(CXCursor C);
extern(C) int clang_getFieldDeclBitWidth(CXCursor C);
extern(C) int clang_Cursor_getNumArguments(CXCursor C);
extern(C) CXCursor clang_Cursor_getArgument(CXCursor C, uint i);
enum CXTemplateArgumentKind
{
    CXTemplateArgumentKind_Null = 0x0,
    CXTemplateArgumentKind_Type = 0x1,
    CXTemplateArgumentKind_Declaration = 0x2,
    CXTemplateArgumentKind_NullPtr = 0x3,
    CXTemplateArgumentKind_Integral = 0x4,
    CXTemplateArgumentKind_Template = 0x5,
    CXTemplateArgumentKind_TemplateExpansion = 0x6,
    CXTemplateArgumentKind_Expression = 0x7,
    CXTemplateArgumentKind_Pack = 0x8,
    CXTemplateArgumentKind_Invalid = 0x9,
}
extern(C) int clang_Cursor_getNumTemplateArguments(CXCursor C);
extern(C) CXTemplateArgumentKind clang_Cursor_getTemplateArgumentKind(CXCursor C, uint I);
extern(C) CXType clang_Cursor_getTemplateArgumentType(CXCursor C, uint I);
extern(C) long clang_Cursor_getTemplateArgumentValue(CXCursor C, uint I);
extern(C) ulong clang_Cursor_getTemplateArgumentUnsignedValue(CXCursor C, uint I);
extern(C) uint clang_equalTypes(CXType A, CXType B);
extern(C) CXType clang_getCanonicalType(CXType T);
extern(C) uint clang_isConstQualifiedType(CXType T);
extern(C) uint clang_Cursor_isMacroFunctionLike(CXCursor C);
extern(C) uint clang_Cursor_isMacroBuiltin(CXCursor C);
extern(C) uint clang_Cursor_isFunctionInlined(CXCursor C);
extern(C) uint clang_isVolatileQualifiedType(CXType T);
extern(C) uint clang_isRestrictQualifiedType(CXType T);
extern(C) uint clang_getAddressSpace(CXType T);
extern(C) CXString clang_getTypedefName(CXType CT);
extern(C) CXType clang_getPointeeType(CXType T);
extern(C) CXCursor clang_getTypeDeclaration(CXType T);
extern(C) CXString clang_getDeclObjCTypeEncoding(CXCursor C);
extern(C) CXString clang_Type_getObjCEncoding(CXType type);
extern(C) CXString clang_getTypeKindSpelling(CXTypeKind K);
extern(C) CXCallingConv clang_getFunctionTypeCallingConv(CXType T);
extern(C) CXType clang_getResultType(CXType T);
extern(C) int clang_getExceptionSpecificationType(CXType T);
extern(C) int clang_getNumArgTypes(CXType T);
extern(C) CXType clang_getArgType(CXType T, uint i);
extern(C) CXType clang_Type_getObjCObjectBaseType(CXType T);
extern(C) uint clang_Type_getNumObjCProtocolRefs(CXType T);
extern(C) CXCursor clang_Type_getObjCProtocolDecl(CXType T, uint i);
extern(C) uint clang_Type_getNumObjCTypeArgs(CXType T);
extern(C) CXType clang_Type_getObjCTypeArg(CXType T, uint i);
extern(C) uint clang_isFunctionTypeVariadic(CXType T);
extern(C) CXType clang_getCursorResultType(CXCursor C);
extern(C) int clang_getCursorExceptionSpecificationType(CXCursor C);
extern(C) uint clang_isPODType(CXType T);
extern(C) CXType clang_getElementType(CXType T);
extern(C) long clang_getNumElements(CXType T);
extern(C) CXType clang_getArrayElementType(CXType T);
extern(C) long clang_getArraySize(CXType T);
extern(C) CXType clang_Type_getNamedType(CXType T);
extern(C) uint clang_Type_isTransparentTagTypedef(CXType T);
enum CXTypeNullabilityKind
{
    CXTypeNullability_NonNull = 0x0,
    CXTypeNullability_Nullable = 0x1,
    CXTypeNullability_Unspecified = 0x2,
    CXTypeNullability_Invalid = 0x3,
}
extern(C) CXTypeNullabilityKind clang_Type_getNullability(CXType T);
enum CXTypeLayoutError
{
    CXTypeLayoutError_Invalid = 0xffffffffffffffff,
    CXTypeLayoutError_Incomplete = 0xfffffffffffffffe,
    CXTypeLayoutError_Dependent = 0xfffffffffffffffd,
    CXTypeLayoutError_NotConstantSize = 0xfffffffffffffffc,
    CXTypeLayoutError_InvalidFieldName = 0xfffffffffffffffb,
    CXTypeLayoutError_Undeduced = 0xfffffffffffffffa,
}
extern(C) long clang_Type_getAlignOf(CXType T);
extern(C) CXType clang_Type_getClassType(CXType T);
extern(C) long clang_Type_getSizeOf(CXType T);
extern(C) long clang_Type_getOffsetOf(CXType T, byte* S);
extern(C) CXType clang_Type_getModifiedType(CXType T);
extern(C) long clang_Cursor_getOffsetOfField(CXCursor C);
extern(C) uint clang_Cursor_isAnonymous(CXCursor C);
extern(C) uint clang_Cursor_isAnonymousRecordDecl(CXCursor C);
extern(C) uint clang_Cursor_isInlineNamespace(CXCursor C);
enum CXRefQualifierKind
{
    CXRefQualifier_None = 0x0,
    CXRefQualifier_LValue = 0x1,
    CXRefQualifier_RValue = 0x2,
}
extern(C) int clang_Type_getNumTemplateArguments(CXType T);
extern(C) CXType clang_Type_getTemplateArgumentAsType(CXType T, uint i);
extern(C) CXRefQualifierKind clang_Type_getCXXRefQualifier(CXType T);
extern(C) uint clang_Cursor_isBitField(CXCursor C);
extern(C) uint clang_isVirtualBase(CXCursor );
enum CX_CXXAccessSpecifier
{
    CX_CXXInvalidAccessSpecifier = 0x0,
    CX_CXXPublic = 0x1,
    CX_CXXProtected = 0x2,
    CX_CXXPrivate = 0x3,
}
extern(C) CX_CXXAccessSpecifier clang_getCXXAccessSpecifier(CXCursor );
enum CX_StorageClass
{
    CX_SC_Invalid = 0x0,
    CX_SC_None = 0x1,
    CX_SC_Extern = 0x2,
    CX_SC_Static = 0x3,
    CX_SC_PrivateExtern = 0x4,
    CX_SC_OpenCLWorkGroupLocal = 0x5,
    CX_SC_Auto = 0x6,
    CX_SC_Register = 0x7,
}
extern(C) CX_StorageClass clang_Cursor_getStorageClass(CXCursor );
extern(C) uint clang_getNumOverloadedDecls(CXCursor cursor);
extern(C) CXCursor clang_getOverloadedDecl(CXCursor cursor, uint index);
extern(C) CXType clang_getIBOutletCollectionType(CXCursor );
enum CXChildVisitResult
{
    CXChildVisit_Break = 0x0,
    CXChildVisit_Continue = 0x1,
    CXChildVisit_Recurse = 0x2,
}
alias CXCursorVisitor = void*;
extern(C) uint clang_visitChildren(CXCursor parent, CXCursorVisitor visitor, CXClientData client_data);
extern(C) CXString clang_getCursorUSR(CXCursor );
extern(C) CXString clang_constructUSR_ObjCClass(byte* class_name);
extern(C) CXString clang_constructUSR_ObjCCategory(byte* class_name, byte* category_name);
extern(C) CXString clang_constructUSR_ObjCProtocol(byte* protocol_name);
extern(C) CXString clang_constructUSR_ObjCIvar(byte* name, CXString classUSR);
extern(C) CXString clang_constructUSR_ObjCMethod(byte* name, uint isInstanceMethod, CXString classUSR);
extern(C) CXString clang_constructUSR_ObjCProperty(byte* property, CXString classUSR);
extern(C) CXString clang_getCursorSpelling(CXCursor );
extern(C) CXSourceRange clang_Cursor_getSpellingNameRange(CXCursor , uint pieceIndex, uint options);
alias CXPrintingPolicy = void*;
enum CXPrintingPolicyProperty
{
    CXPrintingPolicy_Indentation = 0x0,
    CXPrintingPolicy_SuppressSpecifiers = 0x1,
    CXPrintingPolicy_SuppressTagKeyword = 0x2,
    CXPrintingPolicy_IncludeTagDefinition = 0x3,
    CXPrintingPolicy_SuppressScope = 0x4,
    CXPrintingPolicy_SuppressUnwrittenScope = 0x5,
    CXPrintingPolicy_SuppressInitializers = 0x6,
    CXPrintingPolicy_ConstantArraySizeAsWritten = 0x7,
    CXPrintingPolicy_AnonymousTagLocations = 0x8,
    CXPrintingPolicy_SuppressStrongLifetime = 0x9,
    CXPrintingPolicy_SuppressLifetimeQualifiers = 0xa,
    CXPrintingPolicy_SuppressTemplateArgsInCXXConstructors = 0xb,
    CXPrintingPolicy_Bool = 0xc,
    CXPrintingPolicy_Restrict = 0xd,
    CXPrintingPolicy_Alignof = 0xe,
    CXPrintingPolicy_UnderscoreAlignof = 0xf,
    CXPrintingPolicy_UseVoidForZeroParams = 0x10,
    CXPrintingPolicy_TerseOutput = 0x11,
    CXPrintingPolicy_PolishForDeclaration = 0x12,
    CXPrintingPolicy_Half = 0x13,
    CXPrintingPolicy_MSWChar = 0x14,
    CXPrintingPolicy_IncludeNewlines = 0x15,
    CXPrintingPolicy_MSVCFormatting = 0x16,
    CXPrintingPolicy_ConstantsAsWritten = 0x17,
    CXPrintingPolicy_SuppressImplicitBase = 0x18,
    CXPrintingPolicy_FullyQualifiedName = 0x19,
    CXPrintingPolicy_LastProperty = 0x19,
}
extern(C) uint clang_PrintingPolicy_getProperty(CXPrintingPolicy Policy, CXPrintingPolicyProperty Property);
extern(C) void clang_PrintingPolicy_setProperty(CXPrintingPolicy Policy, CXPrintingPolicyProperty Property, uint Value);
extern(C) CXPrintingPolicy clang_getCursorPrintingPolicy(CXCursor );
extern(C) void clang_PrintingPolicy_dispose(CXPrintingPolicy Policy);
extern(C) CXString clang_getCursorPrettyPrinted(CXCursor Cursor, CXPrintingPolicy Policy);
extern(C) CXString clang_getCursorDisplayName(CXCursor );
extern(C) CXCursor clang_getCursorReferenced(CXCursor );
extern(C) CXCursor clang_getCursorDefinition(CXCursor );
extern(C) uint clang_isCursorDefinition(CXCursor );
extern(C) CXCursor clang_getCanonicalCursor(CXCursor );
extern(C) int clang_Cursor_getObjCSelectorIndex(CXCursor );
extern(C) int clang_Cursor_isDynamicCall(CXCursor C);
extern(C) CXType clang_Cursor_getReceiverType(CXCursor C);
enum CXObjCPropertyAttrKind
{
    CXObjCPropertyAttr_noattr = 0x0,
    CXObjCPropertyAttr_readonly = 0x1,
    CXObjCPropertyAttr_getter = 0x2,
    CXObjCPropertyAttr_assign = 0x4,
    CXObjCPropertyAttr_readwrite = 0x8,
    CXObjCPropertyAttr_retain = 0x10,
    CXObjCPropertyAttr_copy = 0x20,
    CXObjCPropertyAttr_nonatomic = 0x40,
    CXObjCPropertyAttr_setter = 0x80,
    CXObjCPropertyAttr_atomic = 0x100,
    CXObjCPropertyAttr_weak = 0x200,
    CXObjCPropertyAttr_strong = 0x400,
    CXObjCPropertyAttr_unsafe_unretained = 0x800,
    CXObjCPropertyAttr_class = 0x1000,
}
extern(C) uint clang_Cursor_getObjCPropertyAttributes(CXCursor C, uint reserved);
extern(C) CXString clang_Cursor_getObjCPropertyGetterName(CXCursor C);
extern(C) CXString clang_Cursor_getObjCPropertySetterName(CXCursor C);
enum CXObjCDeclQualifierKind
{
    CXObjCDeclQualifier_None = 0x0,
    CXObjCDeclQualifier_In = 0x1,
    CXObjCDeclQualifier_Inout = 0x2,
    CXObjCDeclQualifier_Out = 0x4,
    CXObjCDeclQualifier_Bycopy = 0x8,
    CXObjCDeclQualifier_Byref = 0x10,
    CXObjCDeclQualifier_Oneway = 0x20,
}
extern(C) uint clang_Cursor_getObjCDeclQualifiers(CXCursor C);
extern(C) uint clang_Cursor_isObjCOptional(CXCursor C);
extern(C) uint clang_Cursor_isVariadic(CXCursor C);
extern(C) uint clang_Cursor_isExternalSymbol(CXCursor C, CXString* language, CXString* definedIn, uint* isGenerated);
extern(C) CXSourceRange clang_Cursor_getCommentRange(CXCursor C);
extern(C) CXString clang_Cursor_getRawCommentText(CXCursor C);
extern(C) CXString clang_Cursor_getBriefCommentText(CXCursor C);
extern(C) CXString clang_Cursor_getMangling(CXCursor );
extern(C) CXStringSet* clang_Cursor_getCXXManglings(CXCursor );
extern(C) CXStringSet* clang_Cursor_getObjCManglings(CXCursor );
alias CXModule = void*;
extern(C) CXModule clang_Cursor_getModule(CXCursor C);
extern(C) CXModule clang_getModuleForFile(CXTranslationUnit , CXFile );
extern(C) CXFile clang_Module_getASTFile(CXModule Module);
extern(C) CXModule clang_Module_getParent(CXModule Module);
extern(C) CXString clang_Module_getName(CXModule Module);
extern(C) CXString clang_Module_getFullName(CXModule Module);
extern(C) int clang_Module_isSystem(CXModule Module);
extern(C) uint clang_Module_getNumTopLevelHeaders(CXTranslationUnit , CXModule Module);
extern(C) CXFile clang_Module_getTopLevelHeader(CXTranslationUnit , CXModule Module, uint Index);
extern(C) uint clang_CXXConstructor_isConvertingConstructor(CXCursor C);
extern(C) uint clang_CXXConstructor_isCopyConstructor(CXCursor C);
extern(C) uint clang_CXXConstructor_isDefaultConstructor(CXCursor C);
extern(C) uint clang_CXXConstructor_isMoveConstructor(CXCursor C);
extern(C) uint clang_CXXField_isMutable(CXCursor C);
extern(C) uint clang_CXXMethod_isDefaulted(CXCursor C);
extern(C) uint clang_CXXMethod_isPureVirtual(CXCursor C);
extern(C) uint clang_CXXMethod_isStatic(CXCursor C);
extern(C) uint clang_CXXMethod_isVirtual(CXCursor C);
extern(C) uint clang_CXXRecord_isAbstract(CXCursor C);
extern(C) uint clang_EnumDecl_isScoped(CXCursor C);
extern(C) uint clang_CXXMethod_isConst(CXCursor C);
extern(C) CXCursorKind clang_getTemplateCursorKind(CXCursor C);
extern(C) CXCursor clang_getSpecializedCursorTemplate(CXCursor C);
extern(C) CXSourceRange clang_getCursorReferenceNameRange(CXCursor C, uint NameFlags, uint PieceIndex);
enum CXNameRefFlags
{
    CXNameRange_WantQualifier = 0x1,
    CXNameRange_WantTemplateArgs = 0x2,
    CXNameRange_WantSinglePiece = 0x4,
}
enum CXTokenKind
{
    CXToken_Punctuation = 0x0,
    CXToken_Keyword = 0x1,
    CXToken_Identifier = 0x2,
    CXToken_Literal = 0x3,
    CXToken_Comment = 0x4,
}
struct CXToken
{
   uint[4] int_data;
   void* ptr_data;
}
extern(C) CXToken* clang_getToken(CXTranslationUnit TU, CXSourceLocation Location);
extern(C) CXTokenKind clang_getTokenKind(CXToken );
extern(C) CXString clang_getTokenSpelling(CXTranslationUnit , CXToken );
extern(C) CXSourceLocation clang_getTokenLocation(CXTranslationUnit , CXToken );
extern(C) CXSourceRange clang_getTokenExtent(CXTranslationUnit , CXToken );
extern(C) void clang_tokenize(CXTranslationUnit TU, CXSourceRange Range, CXToken** Tokens, uint* NumTokens);
extern(C) void clang_annotateTokens(CXTranslationUnit TU, CXToken* Tokens, uint NumTokens, CXCursor* Cursors);
extern(C) void clang_disposeTokens(CXTranslationUnit TU, CXToken* Tokens, uint NumTokens);
extern(C) CXString clang_getCursorKindSpelling(CXCursorKind Kind);
extern(C) void clang_getDefinitionSpellingAndExtent(CXCursor , byte** startBuf, byte** endBuf, uint* startLine, uint* startColumn, uint* endLine, uint* endColumn);
extern(C) void clang_enableStackTraces();
extern(C) void clang_executeOnThread(void* fn, void* user_data, uint stack_size);
alias CXCompletionString = void*;
struct CXCompletionResult
{
   CXCursorKind CursorKind;
   CXCompletionString CompletionString;
}
enum CXCompletionChunkKind
{
    CXCompletionChunk_Optional = 0x0,
    CXCompletionChunk_TypedText = 0x1,
    CXCompletionChunk_Text = 0x2,
    CXCompletionChunk_Placeholder = 0x3,
    CXCompletionChunk_Informative = 0x4,
    CXCompletionChunk_CurrentParameter = 0x5,
    CXCompletionChunk_LeftParen = 0x6,
    CXCompletionChunk_RightParen = 0x7,
    CXCompletionChunk_LeftBracket = 0x8,
    CXCompletionChunk_RightBracket = 0x9,
    CXCompletionChunk_LeftBrace = 0xa,
    CXCompletionChunk_RightBrace = 0xb,
    CXCompletionChunk_LeftAngle = 0xc,
    CXCompletionChunk_RightAngle = 0xd,
    CXCompletionChunk_Comma = 0xe,
    CXCompletionChunk_ResultType = 0xf,
    CXCompletionChunk_Colon = 0x10,
    CXCompletionChunk_SemiColon = 0x11,
    CXCompletionChunk_Equal = 0x12,
    CXCompletionChunk_HorizontalSpace = 0x13,
    CXCompletionChunk_VerticalSpace = 0x14,
}
extern(C) CXCompletionChunkKind clang_getCompletionChunkKind(CXCompletionString completion_string, uint chunk_number);
extern(C) CXString clang_getCompletionChunkText(CXCompletionString completion_string, uint chunk_number);
extern(C) CXCompletionString clang_getCompletionChunkCompletionString(CXCompletionString completion_string, uint chunk_number);
extern(C) uint clang_getNumCompletionChunks(CXCompletionString completion_string);
extern(C) uint clang_getCompletionPriority(CXCompletionString completion_string);
extern(C) CXAvailabilityKind clang_getCompletionAvailability(CXCompletionString completion_string);
extern(C) uint clang_getCompletionNumAnnotations(CXCompletionString completion_string);
extern(C) CXString clang_getCompletionAnnotation(CXCompletionString completion_string, uint annotation_number);
extern(C) CXString clang_getCompletionParent(CXCompletionString completion_string, CXCursorKind* kind);
extern(C) CXString clang_getCompletionBriefComment(CXCompletionString completion_string);
extern(C) CXCompletionString clang_getCursorCompletionString(CXCursor cursor);
struct CXCodeCompleteResults
{
   CXCompletionResult* Results;
   uint NumResults;
}
extern(C) uint clang_getCompletionNumFixIts(CXCodeCompleteResults* results, uint completion_index);
extern(C) CXString clang_getCompletionFixIt(CXCodeCompleteResults* results, uint completion_index, uint fixit_index, CXSourceRange* replacement_range);
enum CXCodeComplete_Flags
{
    CXCodeComplete_IncludeMacros = 0x1,
    CXCodeComplete_IncludeCodePatterns = 0x2,
    CXCodeComplete_IncludeBriefComments = 0x4,
    CXCodeComplete_SkipPreamble = 0x8,
    CXCodeComplete_IncludeCompletionsWithFixIts = 0x10,
}
enum CXCompletionContext
{
    CXCompletionContext_Unexposed = 0x0,
    CXCompletionContext_AnyType = 0x1,
    CXCompletionContext_AnyValue = 0x2,
    CXCompletionContext_ObjCObjectValue = 0x4,
    CXCompletionContext_ObjCSelectorValue = 0x8,
    CXCompletionContext_CXXClassTypeValue = 0x10,
    CXCompletionContext_DotMemberAccess = 0x20,
    CXCompletionContext_ArrowMemberAccess = 0x40,
    CXCompletionContext_ObjCPropertyAccess = 0x80,
    CXCompletionContext_EnumTag = 0x100,
    CXCompletionContext_UnionTag = 0x200,
    CXCompletionContext_StructTag = 0x400,
    CXCompletionContext_ClassTag = 0x800,
    CXCompletionContext_Namespace = 0x1000,
    CXCompletionContext_NestedNameSpecifier = 0x2000,
    CXCompletionContext_ObjCInterface = 0x4000,
    CXCompletionContext_ObjCProtocol = 0x8000,
    CXCompletionContext_ObjCCategory = 0x10000,
    CXCompletionContext_ObjCInstanceMessage = 0x20000,
    CXCompletionContext_ObjCClassMessage = 0x40000,
    CXCompletionContext_ObjCSelectorName = 0x80000,
    CXCompletionContext_MacroName = 0x100000,
    CXCompletionContext_NaturalLanguage = 0x200000,
    CXCompletionContext_IncludedFile = 0x400000,
    CXCompletionContext_Unknown = 0x7fffff,
}
extern(C) uint clang_defaultCodeCompleteOptions();
extern(C) CXCodeCompleteResults* clang_codeCompleteAt(CXTranslationUnit TU, byte* complete_filename, uint complete_line, uint complete_column, CXUnsavedFile* unsaved_files, uint num_unsaved_files, uint options);
extern(C) void clang_sortCodeCompletionResults(CXCompletionResult* Results, uint NumResults);
extern(C) void clang_disposeCodeCompleteResults(CXCodeCompleteResults* Results);
extern(C) uint clang_codeCompleteGetNumDiagnostics(CXCodeCompleteResults* Results);
extern(C) CXDiagnostic clang_codeCompleteGetDiagnostic(CXCodeCompleteResults* Results, uint Index);
extern(C) ulong clang_codeCompleteGetContexts(CXCodeCompleteResults* Results);
extern(C) CXCursorKind clang_codeCompleteGetContainerKind(CXCodeCompleteResults* Results, uint* IsIncomplete);
extern(C) CXString clang_codeCompleteGetContainerUSR(CXCodeCompleteResults* Results);
extern(C) CXString clang_codeCompleteGetObjCSelector(CXCodeCompleteResults* Results);
extern(C) CXString clang_getClangVersion();
extern(C) void clang_toggleCrashRecovery(uint isEnabled);
alias CXInclusionVisitor = void*;
extern(C) void clang_getInclusions(CXTranslationUnit tu, CXInclusionVisitor visitor, CXClientData client_data);
enum CXEvalResultKind
{
    CXEval_Int = 0x1,
    CXEval_Float = 0x2,
    CXEval_ObjCStrLiteral = 0x3,
    CXEval_StrLiteral = 0x4,
    CXEval_CFStr = 0x5,
    CXEval_Other = 0x6,
    CXEval_UnExposed = 0x0,
}
alias CXEvalResult = void*;
extern(C) CXEvalResult clang_Cursor_Evaluate(CXCursor C);
extern(C) CXEvalResultKind clang_EvalResult_getKind(CXEvalResult E);
extern(C) int clang_EvalResult_getAsInt(CXEvalResult E);
extern(C) long clang_EvalResult_getAsLongLong(CXEvalResult E);
extern(C) uint clang_EvalResult_isUnsignedInt(CXEvalResult E);
extern(C) ulong clang_EvalResult_getAsUnsigned(CXEvalResult E);
extern(C) double clang_EvalResult_getAsDouble(CXEvalResult E);
extern(C) byte* clang_EvalResult_getAsStr(CXEvalResult E);
extern(C) void clang_EvalResult_dispose(CXEvalResult E);
alias CXRemapping = void*;
extern(C) CXRemapping clang_getRemappings(byte* path);
extern(C) CXRemapping clang_getRemappingsFromFileList(byte** filePaths, uint numFiles);
extern(C) uint clang_remap_getNumFiles(CXRemapping );
extern(C) void clang_remap_getFilenames(CXRemapping , uint index, CXString* original, CXString* transformed);
extern(C) void clang_remap_dispose(CXRemapping );
enum CXVisitorResult
{
    CXVisit_Break = 0x0,
    CXVisit_Continue = 0x1,
}
struct CXCursorAndRangeVisitor
{
   void* context;
   void* visit;
}
enum CXResult
{
    CXResult_Success = 0x0,
    CXResult_Invalid = 0x1,
    CXResult_VisitBreak = 0x2,
}
extern(C) CXResult clang_findReferencesInFile(CXCursor cursor, CXFile file, CXCursorAndRangeVisitor visitor);
extern(C) CXResult clang_findIncludesInFile(CXTranslationUnit TU, CXFile file, CXCursorAndRangeVisitor visitor);
alias CXIdxClientFile = void*;
alias CXIdxClientEntity = void*;
alias CXIdxClientContainer = void*;
alias CXIdxClientASTFile = void*;
struct CXIdxLoc
{
   void*[2] ptr_data;
   uint int_data;
}
struct CXIdxIncludedFileInfo
{
   CXIdxLoc hashLoc;
   byte* filename;
   CXFile file;
   int isImport;
   int isAngled;
   int isModuleImport;
}
struct CXIdxImportedASTFileInfo
{
   CXFile file;
   CXModule _module;
   CXIdxLoc loc;
   int isImplicit;
}
enum CXIdxEntityKind
{
    CXIdxEntity_Unexposed = 0x0,
    CXIdxEntity_Typedef = 0x1,
    CXIdxEntity_Function = 0x2,
    CXIdxEntity_Variable = 0x3,
    CXIdxEntity_Field = 0x4,
    CXIdxEntity_EnumConstant = 0x5,
    CXIdxEntity_ObjCClass = 0x6,
    CXIdxEntity_ObjCProtocol = 0x7,
    CXIdxEntity_ObjCCategory = 0x8,
    CXIdxEntity_ObjCInstanceMethod = 0x9,
    CXIdxEntity_ObjCClassMethod = 0xa,
    CXIdxEntity_ObjCProperty = 0xb,
    CXIdxEntity_ObjCIvar = 0xc,
    CXIdxEntity_Enum = 0xd,
    CXIdxEntity_Struct = 0xe,
    CXIdxEntity_Union = 0xf,
    CXIdxEntity_CXXClass = 0x10,
    CXIdxEntity_CXXNamespace = 0x11,
    CXIdxEntity_CXXNamespaceAlias = 0x12,
    CXIdxEntity_CXXStaticVariable = 0x13,
    CXIdxEntity_CXXStaticMethod = 0x14,
    CXIdxEntity_CXXInstanceMethod = 0x15,
    CXIdxEntity_CXXConstructor = 0x16,
    CXIdxEntity_CXXDestructor = 0x17,
    CXIdxEntity_CXXConversionFunction = 0x18,
    CXIdxEntity_CXXTypeAlias = 0x19,
    CXIdxEntity_CXXInterface = 0x1a,
}
enum CXIdxEntityLanguage
{
    CXIdxEntityLang_None = 0x0,
    CXIdxEntityLang_C = 0x1,
    CXIdxEntityLang_ObjC = 0x2,
    CXIdxEntityLang_CXX = 0x3,
    CXIdxEntityLang_Swift = 0x4,
}
enum CXIdxEntityCXXTemplateKind
{
    CXIdxEntity_NonTemplate = 0x0,
    CXIdxEntity_Template = 0x1,
    CXIdxEntity_TemplatePartialSpecialization = 0x2,
    CXIdxEntity_TemplateSpecialization = 0x3,
}
enum CXIdxAttrKind
{
    CXIdxAttr_Unexposed = 0x0,
    CXIdxAttr_IBAction = 0x1,
    CXIdxAttr_IBOutlet = 0x2,
    CXIdxAttr_IBOutletCollection = 0x3,
}
struct CXIdxAttrInfo
{
   CXIdxAttrKind kind;
   CXCursor cursor;
   CXIdxLoc loc;
}
struct CXIdxEntityInfo
{
   CXIdxEntityKind kind;
   CXIdxEntityCXXTemplateKind templateKind;
   CXIdxEntityLanguage lang;
   byte* name;
   byte* USR;
   CXCursor cursor;
   CXIdxAttrInfo** attributes;
   uint numAttributes;
}
struct CXIdxContainerInfo
{
   CXCursor cursor;
}
struct CXIdxIBOutletCollectionAttrInfo
{
   CXIdxAttrInfo* attrInfo;
   CXIdxEntityInfo* objcClass;
   CXCursor classCursor;
   CXIdxLoc classLoc;
}
enum CXIdxDeclInfoFlags
{
    CXIdxDeclFlag_Skipped = 0x1,
}
struct CXIdxDeclInfo
{
   CXIdxEntityInfo* entityInfo;
   CXCursor cursor;
   CXIdxLoc loc;
   CXIdxContainerInfo* semanticContainer;
   CXIdxContainerInfo* lexicalContainer;
   int isRedeclaration;
   int isDefinition;
   int isContainer;
   CXIdxContainerInfo* declAsContainer;
   int isImplicit;
   CXIdxAttrInfo** attributes;
   uint numAttributes;
   uint flags;
}
enum CXIdxObjCContainerKind
{
    CXIdxObjCContainer_ForwardRef = 0x0,
    CXIdxObjCContainer_Interface = 0x1,
    CXIdxObjCContainer_Implementation = 0x2,
}
struct CXIdxObjCContainerDeclInfo
{
   CXIdxDeclInfo* declInfo;
   CXIdxObjCContainerKind kind;
}
struct CXIdxBaseClassInfo
{
   CXIdxEntityInfo* base;
   CXCursor cursor;
   CXIdxLoc loc;
}
struct CXIdxObjCProtocolRefInfo
{
   CXIdxEntityInfo* protocol;
   CXCursor cursor;
   CXIdxLoc loc;
}
struct CXIdxObjCProtocolRefListInfo
{
   CXIdxObjCProtocolRefInfo** protocols;
   uint numProtocols;
}
struct CXIdxObjCInterfaceDeclInfo
{
   CXIdxObjCContainerDeclInfo* containerInfo;
   CXIdxBaseClassInfo* superInfo;
   CXIdxObjCProtocolRefListInfo* protocols;
}
struct CXIdxObjCCategoryDeclInfo
{
   CXIdxObjCContainerDeclInfo* containerInfo;
   CXIdxEntityInfo* objcClass;
   CXCursor classCursor;
   CXIdxLoc classLoc;
   CXIdxObjCProtocolRefListInfo* protocols;
}
struct CXIdxObjCPropertyDeclInfo
{
   CXIdxDeclInfo* declInfo;
   CXIdxEntityInfo* getter;
   CXIdxEntityInfo* setter;
}
struct CXIdxCXXClassDeclInfo
{
   CXIdxDeclInfo* declInfo;
   CXIdxBaseClassInfo** bases;
   uint numBases;
}
enum CXIdxEntityRefKind
{
    CXIdxEntityRef_Direct = 0x1,
    CXIdxEntityRef_Implicit = 0x2,
}
enum CXSymbolRole
{
    CXSymbolRole_None = 0x0,
    CXSymbolRole_Declaration = 0x1,
    CXSymbolRole_Definition = 0x2,
    CXSymbolRole_Reference = 0x4,
    CXSymbolRole_Read = 0x8,
    CXSymbolRole_Write = 0x10,
    CXSymbolRole_Call = 0x20,
    CXSymbolRole_Dynamic = 0x40,
    CXSymbolRole_AddressOf = 0x80,
    CXSymbolRole_Implicit = 0x100,
}
struct CXIdxEntityRefInfo
{
   CXIdxEntityRefKind kind;
   CXCursor cursor;
   CXIdxLoc loc;
   CXIdxEntityInfo* referencedEntity;
   CXIdxEntityInfo* parentEntity;
   CXIdxContainerInfo* container;
   CXSymbolRole role;
}
struct IndexerCallbacks
{
   void* abortQuery;
   void* diagnostic;
   void* enteredMainFile;
   void* ppIncludedFile;
   void* importedASTFile;
   void* startedTranslationUnit;
   void* indexDeclaration;
   void* indexEntityReference;
}
extern(C) int clang_index_isEntityObjCContainerKind(CXIdxEntityKind );
extern(C) CXIdxObjCContainerDeclInfo* clang_index_getObjCContainerDeclInfo(CXIdxDeclInfo* );
extern(C) CXIdxObjCInterfaceDeclInfo* clang_index_getObjCInterfaceDeclInfo(CXIdxDeclInfo* );
extern(C) CXIdxObjCCategoryDeclInfo* clang_index_getObjCCategoryDeclInfo(CXIdxDeclInfo* );
extern(C) CXIdxObjCProtocolRefListInfo* clang_index_getObjCProtocolRefListInfo(CXIdxDeclInfo* );
extern(C) CXIdxObjCPropertyDeclInfo* clang_index_getObjCPropertyDeclInfo(CXIdxDeclInfo* );
extern(C) CXIdxIBOutletCollectionAttrInfo* clang_index_getIBOutletCollectionAttrInfo(CXIdxAttrInfo* );
extern(C) CXIdxCXXClassDeclInfo* clang_index_getCXXClassDeclInfo(CXIdxDeclInfo* );
extern(C) CXIdxClientContainer clang_index_getClientContainer(CXIdxContainerInfo* );
extern(C) void clang_index_setClientContainer(CXIdxContainerInfo* , CXIdxClientContainer );
extern(C) CXIdxClientEntity clang_index_getClientEntity(CXIdxEntityInfo* );
extern(C) void clang_index_setClientEntity(CXIdxEntityInfo* , CXIdxClientEntity );
alias CXIndexAction = void*;
extern(C) CXIndexAction clang_IndexAction_create(CXIndex CIdx);
extern(C) void clang_IndexAction_dispose(CXIndexAction );
enum CXIndexOptFlags
{
    CXIndexOpt_None = 0x0,
    CXIndexOpt_SuppressRedundantRefs = 0x1,
    CXIndexOpt_IndexFunctionLocalSymbols = 0x2,
    CXIndexOpt_IndexImplicitTemplateInstantiations = 0x4,
    CXIndexOpt_SuppressWarnings = 0x8,
    CXIndexOpt_SkipParsedBodiesInSession = 0x10,
}
extern(C) int clang_indexSourceFile(CXIndexAction , CXClientData client_data, IndexerCallbacks* index_callbacks, uint index_callbacks_size, uint index_options, byte* source_filename, byte** command_line_args, int num_command_line_args, CXUnsavedFile* unsaved_files, uint num_unsaved_files, CXTranslationUnit* out_TU, uint TU_options);
extern(C) int clang_indexSourceFileFullArgv(CXIndexAction , CXClientData client_data, IndexerCallbacks* index_callbacks, uint index_callbacks_size, uint index_options, byte* source_filename, byte** command_line_args, int num_command_line_args, CXUnsavedFile* unsaved_files, uint num_unsaved_files, CXTranslationUnit* out_TU, uint TU_options);
extern(C) int clang_indexTranslationUnit(CXIndexAction , CXClientData client_data, IndexerCallbacks* index_callbacks, uint index_callbacks_size, uint index_options, CXTranslationUnit );
extern(C) void clang_indexLoc_getFileLocation(CXIdxLoc loc, CXIdxClientFile* indexFile, CXFile* file, uint* line, uint* column, uint* offset);
extern(C) CXSourceLocation clang_indexLoc_getCXSourceLocation(CXIdxLoc loc);
alias CXFieldVisitor = void*;
extern(C) uint clang_Type_visitFields(CXType T, CXFieldVisitor visitor, CXClientData client_data);
