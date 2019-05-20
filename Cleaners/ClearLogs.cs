using System.Diagnostics;
using System.Security.Principal;
using Microsoft.VisualBasic.CompilerServices;

namespace ClearLogs {
    static class Cleaner {
       /*
        * Author : Suleiman Al-Othman | twitter & github => (@sulealothman)
        * ClassName : Clear All Event Logs & Delete All log files
        * Ver. : 0.1
        * Run as Administrator (UAC)
        */
        static void Main() {

            if (!(new WindowsPrincipal(WindowsIdentity.GetCurrent())).IsInRole(WindowsBuiltInRole.Administrator)) return;
                Process pro = new Process();
                pro.StartInfo.RedirectStandardInput = true;
                pro.StartInfo.FileName = "cmd.exe";
                pro.StartInfo.UseShellExecute = false;
                pro.StartInfo.CreateNoWindow = true;
                pro.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
                pro.Start();
                pro.StandardInput.WriteLine(@"Del *.log /a /s /q /f");

                foreach (var l in EventLog.GetEventLogs()) {
                    l.Clear();
                    l.Dispose();
                }
                ProjectData.EndApp();
        }
    }
}
