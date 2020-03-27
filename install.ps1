# Exit if running without Admin priviledge
if (-not(([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( `
    [Security.Principal.WindowsBuiltInRole] "Administrator" `
    ))) {
    echo "Administrator priviledge is required. Please Run as Administrator."
    exit
}
$webhook_url = Read-Host "Please input your webhook url"
mkdir c:\Progra~1\aeyesec\ 2>$null

 (Get-Content .\malware_monitor.ps1) | %{ $_ -replace "{{ webhook_url }}","${webhook_url}" } | Set-Content .\tmp_malware_monitor.ps1
Move-Item tmp_malware_monitor.ps1 c:\Progra~1\aeyesec\malware_monitor.ps1 -force
curl http://nssm.cc/release/nssm-2.24.zip -O nssm-2.24.zip
rm -r .\nssm-2.24
Expand-Archive nssm-2.24.zip
if ([System.Environment]::Is64BitProcess) {
  cd nssm-2.24\nssm-2.24\win64
} else {
  cd nssm-2.24\nssm-2.24\win32
}
.\nssm stop WindowsDefenderSlackAlert 2>$null
.\nssm remove WindowsDefenderSlackAlert confirm 2>$null
.\nssm install WindowsDefenderSlackAlert C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe "-ExecutionPolicy Bypass -NoProfile -File c:\Progra~1\aeyesec\malware_monitor.ps1" 
.\nssm start WindowsDefenderSlackAlert
