pushd %~dp0
powershell -NoProfile -ExecutionPolicy Unrestricted ".\uninstall_service.ps1"
pause