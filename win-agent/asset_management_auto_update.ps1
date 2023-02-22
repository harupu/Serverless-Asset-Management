$script_download_url = "{{ script_download_url }}"
# $script_api_key = "{{ script_api_key }}"

cd $PSScriptRoot
while (1) {
  # Get main script from some API 
  # Retry until success
  while(1) {
    # Use base64 format when API Gateway's mock response is expected.
    # $scriptBase64 = (Invoke-RestMethod -Uri $script_download_url -Method Get -Headers $script_api_key -ErrorAction SilentlyContinue)
    # $script = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($scriptBase64))
    $script = (Invoke-RestMethod -Uri $script_download_url -Method Get -ErrorAction SilentlyContinue)
    if (($script | Select-String PostMalwareSlackWebhook)) {
      Write-Output $script | Set-Content -Encoding Default asset_management_script.ps1
      break
    }
    Start-Sleep -s 60
  }

  .\asset_management_script.ps1
}