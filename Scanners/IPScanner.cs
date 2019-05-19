using System;
using System.Collections.Generic;
using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;

namespace IPScanners
{
    static class IPScanner
    {

        /*
         * Author : Suleiman Al-Othman | twitter & github => (@sulealothman)
         * ClassName : IPScanner => Get all ip's is alive on local network
         * Ver. : 0.1
         */
        private static int countIPs = 254;
        private static List<string> ipArr = new List<string>();
        private static string ip = "";
        static void Main()
        {

            ip = GetLocalIPAddress();
            ip = ip.Remove(ip.LastIndexOf(".")) + ".";
            System.Threading.Thread th = new System.Threading.Thread(() => runThread());
            th.Start();
            th.Join();
            ipArr.ForEach(i => Console.WriteLine("{0}\t", i));
            Console.ReadLine();
        }
        static void runThread()
        {
            System.Threading.Thread [] arrThread = new System.Threading.Thread[countIPs];
            for(int i = 1; i < countIPs; i++)
            {
                arrThread[i] = new System.Threading.Thread(() => ipIsAlive(ip + i.ToString()));
                arrThread[i].Start();
            }
            for (int i = 1; i < countIPs; i++)
            {
                arrThread[i].Join();
            }
        }

        public static void ipIsAlive(string ipTest)
        {
            Ping ping = null;
            try
            {
                ping = new Ping();
                PingReply reply = ping.Send(ipTest, 3000, new byte[1]);
                if (reply.Status == IPStatus.Success)
                    ipArr.Add(ipTest);
            }
            catch (PingException)
            {
                if (ping != null)
                    ping.Dispose();
            }
            finally
            {
                if (ping != null)
                    ping.Dispose();
            }
        }
        

        
        public static string GetLocalIPAddress()
        {
            var host = Dns.GetHostEntry(Dns.GetHostName());
            foreach (var ip in host.AddressList)
            {
                if (ip.AddressFamily == AddressFamily.InterNetwork)
                {
                     return ip.ToString();
                }
            }
            throw new Exception("");
        }
       

    }
}
