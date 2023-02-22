$slack_webhook = "{{ slack_webhook_url }}"
$spread_sheet_api = "{{ spread_sheet_api_url }}"

function PostMalwareSlackWebhook($malware_name, $user_name, $path){
  $ip = ([Net.Dns]::GetHostAddresses('').IPAddressToString | select-string -notmatch ":" | %{$_.line})
  $date = (Get-Date)
  $payload = @{ 
    username = "malware alert";
    icon_emoji = ":imp:";
    attachments = @(@{
      pretext = "${malware_name} was detected";
      color = "#D00000";
      fields = @(
        @{
          title = "Name";
          value = "${malware_name}";
        },@{
          title = "User";
          value = "${user_name}";
          short = "true";
        },@{
          title = "Host";
          value = $Env:COMPUTERNAME;
          short = "true";
        },@{
          title = "IP";
          value = "${ip}";
          short = "true";
        },@{
          title = "Date";
          value = "${date}";
          short = "true";
        },@{
          title = "Path";
          value = "${path}";
        });
    });
  }
  $json = ConvertTo-Json -Depth 100 $payload
  $body = [System.Text.Encoding]::UTF8.GetBytes($json)
  Invoke-RestMethod -Uri $slack_webhook -Method Post -Body $body
}

function PostAssetInfo(){
  if ($spread_sheet_api -eq "") {
    return
  }
  Set-MpPreference -DisableRealtimeMonitoring 0
  $mp_status = (Get-MpComputerStatus)
  if ((Get-Date).AddDays(-2) -gt $mp_status.AntivirusSignatureLastUpdated) {
    Update-MpSignature -UpdateSource MicrosoftUpdateServer
    $mp_status = (Get-MpComputerStatus)
  }

  $status_check_start_date = (Get-Date)
  while (!$mp_status.RealTimeProtectionEnabled) {
    if ((Get-Date).AddMinutes(-10) -gt $status_check_start_date) {
      break
    }
    $mp_status = (Get-MpComputerStatus)
    Start-Sleep -s 30
  }

  $hostname = (hostname)
  $username = ((GET-WmiObject Win32_ComputerSystem).UserName)
  try {
    $latestKB = (Get-Hotfix -Description "Security Update" | Sort-Object HotFixID -Descending)[0].HotFixID;
  } catch {
    $latestKB = ""
  }
  $realtimeEnabled = $mp_status.RealTimeProtectionEnabled;
  $signatureVersion = $mp_status.AntivirusSignatureVersion;
  $signatureDate = $mp_status.AntivirusSignatureLastUpdated;
  $osVersion = (cmd /c ver) -join ""
  $serialNumber = (Get-WmiObject Win32_BIOS).SerialNumber;
  if([string]::IsNullOrEmpty($serialNumber) -or $serialNumber -eq "To Be Filled By O.E.M.") {
    $serialNumber = (Get-WmiObject Win32_OperatingSystem).SerialNumber;
  }
  $diskEncryption = (Get-WMIObject -Namespace "root/CIMV2/Security/MicrosoftVolumeEncryption" -Class Win32_EncryptableVolume).GetConversionStatus().ConversionStatus

  $data = @{
    serialNumber = "${serialNumber}";
    hostname = "${hostname}";
    username = "${username}";
    latestKB = "${latestKB}";
    realtimeEnabled = "${realtimeEnabled}";
    signatureVersion = "${signatureVersion}";
    signatureDate = "${signatureDate}";
    osVersion = "${osVersion}";
    diskEncryption = "${diskEncryption}";
  }
  Invoke-RestMethod -Uri $spread_sheet_api -Method Post -Body $data
}


$last_log_date = get-date
$last_detection_id = ""
PostAssetInfo
$last_update_date = get-date
while (1) {
  if ((get-date).AddHours(-1) -gt $last_update_date) {
    PostAssetInfo
    $last_update_date = get-date
    # break when autoupdate mode
    if ($myInvocation.MyCommand.name -eq "asset_management_script.ps1") {
      break
    }
  }

  $events = (get-winevent -LogName "Microsoft-Windows-Windows Defender/Operational" | where-object {$_.Id -ge 1006 -and $_.Id -le 1120 -and $_.TimeCreated -gt $last_log_date} )

  for($i = 0; $i -lt $events.Count; $i++){
    $event = [xml]$events[$i].ToXml()
    $detection_id = ($event.Event.EventData.Data | ? {$_.Name -eq "Detection ID"}).'#text'
    Write-Host ($last_detection_id)
    Write-Host ($detection_id)
    if ($last_detection_id -eq $detection_id) {
      continue
    }
    $last_detection_id = $detection_id
    $threat_id = ($event.Event.EventData.Data | ? {$_.Name -eq "Threat ID"}).'#text'
    $threat_name = ($event.Event.EventData.Data | ? {$_.Name -eq "Threat Name"}).'#text'
    $user_name = ($event.Event.EventData.Data | ? {$_.Name -eq "Detection User"}).'#text'
    $path = ($event.Event.EventData.Data | ? {$_.Name -eq "Path"}).'#text'
    Write-Host ($threat_name)
    if([string]::IsNullOrEmpty($threat_name)) {
      continue
    }
    PostMalwareSlackWebhook $threat_name $user_name $path
    $time_created = $events[$i].TimeCreated
    if ($time_created -gt $last_log_date) {
      $last_log_date = $time_created
    }
  }
  Start-Sleep -s 60
}
