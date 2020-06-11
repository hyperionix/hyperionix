Hook {
  name = "NtQueryDirectoryFileExHook",
  target = "ntdll!NtQueryDirectoryFileEx",
  decl = [[
    NTSTATUS NtQueryDirectoryFileEx(
      _In_ HANDLE                 FileHandle,
      _In_opt_ HANDLE             Event,
      _In_opt_ PIO_APC_ROUTINE    ApcRoutine,
      _In_opt_ PVOID              ApcContext,
      _Out_ PIO_STATUS_BLOCK      IoStatusBlock,
      _Out_ PVOID                 FileInformation,
      _In_ ULONG                  Length,
      _In_ FILE_INFORMATION_CLASS FileInformationClass,
      _In_ ULONG                  QueryFlags,
      _In_opt_ PUNICODE_STRING    FileMask
    );
  ]]
}
