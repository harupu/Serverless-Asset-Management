# Exit if running without Admin priviledge
if (-not(([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( `
    [Security.Principal.WindowsBuiltInRole] "Administrator" `
    ))) {
    echo "Administrator priviledge is required. Please Run as Administrator."
    exit
}
if ([System.Environment]::Is64BitProcess) {
  cd c:\Progra~1\nssm-2.24\win64
} else {
  cd c:\Progra~1\nssm-2.24\win32
}
.\nssm stop WindowsAssetManagementX
.\nssm remove WindowsAssetManagementX confirm
