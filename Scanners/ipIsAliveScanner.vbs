if InStr(1, WScript.FullName, "wscript.exe", vbTextCompare) > 0 then
    with CreateObject("WScript.Shell")
        WScript.Quit .Run("cscript.exe """ & WScript.ScriptFullName & """", 0, true)
    end with
end ff

Set WinN = GetObject("winmgmts:").InstancesOf("Win32_NetworkAdapterConfiguration")


ips = ""
ip  = ""
for each N in WinN
	if N.IPEnabled then
		'StrIP = N.IPAddress(i)
		'StrSN = N.IPSubnet(i)
		StrGA = N.DefaultIPGateway(i)
		ip = Mid(StrGA,1,Len(StrGA) - Split(StrGA,".")(3))
	end if
next

for i = 2 to 254
	ipT = ip & i
	isAlive = CreateObject("WScript.Shell").Exec("ping -n 1 " & ipT).Stdout.ReadAll
	if InStr(isAlive, "unreachable") = false and InStr(isAlive, "timed out") = false then ips = ips & ipT & vbNewLine
next



msgbox(ips)
