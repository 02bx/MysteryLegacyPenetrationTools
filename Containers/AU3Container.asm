FORMAT PE GUI 4.0

; Author : Suleiman Al-Othman || twitter, github (@sulealothman)
; Ver. : 0.1
; Project Name : Autoit 3 Container by Flat Assembly (Fasm)

INCLUDE 'win32ax.inc'


AU3I:
file "AutoIt3.exe"

virtual at 0
    file "AutoIt3.exe"
    au3Size = $
end virtual

AU3SC:
file "scriptname.au3"

virtual at 0
    file "scriptname.au3"
    scrSize = $
end virtual


.data

tempDir db "temp", 0
autoitIntp db "\autoit3.exe", 0
autoitScript db "scriptname.au3", 0
au3Parameter db ' /AutoIt3ExecuteScript ', 0

PI PROCESS_INFORMATION
SPI STARTUPINFO

fullPathAU3I rb 256d
fullPathAU3SC rb 256d
au3Command rb 128d

au3Handle dd ?
scriptHandle dd ?


.code

    START:
        
        invoke GetEnvironmentVariable, tempDir, fullPathAU3I, MAX_PATH
        invoke lstrcat, fullPathAU3I, autoitIntp
        invoke CreateFile, fullPathAU3I, GENERIC_WRITE, 0, 0, CREATE_NEW, 0, 0
        mov [au3Handle], eax
        invoke WriteFile, [au3Handle], AU3I, au3Size, 0, 0
        invoke CloseHandle, [au3Handle]

        invoke GetEnvironmentVariable, tempDir, fullPathAU3SC, MAX_PATH
        invoke lstrcat, fullPathAU3SC, "\"
        invoke lstrcat, fullPathAU3SC, autoitScript
        invoke CreateFile, fullPathAU3SC, GENERIC_WRITE, 0, 0, CREATE_NEW, 0, 0
        mov [scriptHandle], eax
        invoke WriteFile, [scriptHandle], AU3SC, scrSize, 0, 0
        invoke CloseHandle, [scriptHandle]

        invoke lstrcat, au3Command, au3Parameter
        invoke lstrcat, au3Command, autoitScript
        invoke CreateProcess, fullPathAU3I, au3Command, 0, 0, 0, 4, 0, 0, SPI, PI
        invoke ResumeThread,[PI.hThread], 0
        invoke ExitProcess, 0

    .end START