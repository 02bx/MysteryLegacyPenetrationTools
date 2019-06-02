FORMAT PE GUI 4.0

; Author : Suleiman Al-Othman || twitter, github (@sulealothman)
; Ver. : 0.1
; Project Name : Autoit 3 Container by Flat Assembly (Fasm)

INCLUDE 'win32ax.inc'


AHKI:
file "AutoHotKey.exe"

virtual at 0
    file "AutoHotKey.exe"
    ahkSize = $
end virtual

AHKSC:
file "scriptname.ahk"

virtual at 0
    file "scriptname.ahk"
    scrSize = $
end virtual


.data

tempDir db "temp", 0
ahkIntp db "\ahk.exe", 0
ahkScript db "\scriptname.ahk", 0

PI PROCESS_INFORMATION
SPI STARTUPINFO

fullPathAHKI rb 256d
fullPathAHKSC rb 256d
ahkCommand rb 128d

ahkHandle dd ?
scriptHandle dd ?


.code

    START:
        
        invoke GetEnvironmentVariable, tempDir, fullPathAHKI, MAX_PATH
        invoke lstrcat, fullPathAHKI, ahkIntp
        invoke CreateFile, fullPathAHKI, GENERIC_WRITE, 0, 0, CREATE_NEW, 0, 0
        mov [ahkHandle], eax
        invoke WriteFile, [ahkHandle], AHKI, ahkSize, 0, 0
        invoke CloseHandle, [ahkHandle]

        invoke GetEnvironmentVariable, tempDir, fullPathAHKSC, MAX_PATH
        invoke lstrcat, fullPathAHKSC, ahkScript
        invoke CreateFile, fullPathAHKSC, GENERIC_WRITE, 0, 0, CREATE_NEW, 0, 0
        mov [scriptHandle], eax
        invoke WriteFile, [scriptHandle], AHKSC, scrSize, 0, 0
        invoke CloseHandle, [scriptHandle]

        invoke lstrcat, ahkCommand, ' "'
        invoke lstrcat, ahkCommand, fullPathAHKSC
        invoke lstrcat, ahkCommand, '"'
        invoke CreateProcess, fullPathAHKI, ahkCommand, 0, 0, 0, 4, 0, 0, SPI, PI
        invoke ResumeThread,[PI.hThread], 0
        invoke ExitProcess, 0

    .end START