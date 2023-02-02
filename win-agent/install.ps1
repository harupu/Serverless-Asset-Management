# Exit if running without Admin priviledge
if (-not(([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( `
    [Security.Principal.WindowsBuiltInRole] "Administrator" `
    ))) {
    echo "Administrator priviledge is required. Please Run as Administrator."
    exit
}
$webhook_url = Read-Host "Please input your malware alert webhook url (blank to skip)"
$spreadsheet_url = Read-Host "Please input your asset management spread sheet url (blank to skip)"
mkdir c:\Progra~1\aeyesec\ 2>$null

(Get-Content .\asset_management.ps1) | %{ $_ -replace "{{ slack_webhook_url }}","${webhook_url}" } | Set-Content .\tmp_asset_management_1.ps1
(Get-Content .\tmp_asset_management_1.ps1) | %{ $_ -replace "{{ spread_sheet_api_url }}","${spreadsheet_url}" } | Set-Content .\tmp_asset_management_2.ps1
Move-Item tmp_asset_management_2.ps1 c:\Progra~1\aeyesec\asset_management.ps1 -force
if (!(Test-Path c:\Progra~1\nssm-2.24)){
  curl https://nssm.cc/release/nssm-2.24.zip -O nssm-2.24.zip
  Expand-Archive nssm-2.24.zip
  Move-Item nssm-2.24\nssm-2.24 c:\Progra~1\ -force
}
if ([System.Environment]::Is64BitProcess) {
  cd c:\Progra~1\nssm-2.24\win64
} else {
  cd c:\Progra~1\nssm-2.24\win32
}
.\nssm stop WindowsAssetManagementX 2>$null
.\nssm remove WindowsAssetManagementX confirm 2>$null
.\nssm install WindowsAssetManagementX C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe "-ExecutionPolicy Bypass -NoProfile -File c:\Progra~1\aeyesec\asset_management.ps1" 
.\nssm start WindowsAssetManagementX
