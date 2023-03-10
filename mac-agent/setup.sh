#! /bin/bash
echo -n Please input your malware alert webhook url:
read slackstr

echo -n Please input your asset management spread sheet url:
read spreadstr


sudo mkdir /usr/local/bin/ 2>/dev/null
sudo mkdir -p /usr/local/etc/clamav/ 2>/dev/null

sudo sh -c "cat system_info_syncx.sh | sed \"s!##spread_sheet_api_url##!${spreadstr}!\" > /usr/local/bin/system_info_syncx"
sudo chmod 700 /usr/local/bin/system_info_syncx
sudo install -m 644 ./jp.aeyesec.SystemInfoSync.plist /Library/LaunchDaemons
sudo launchctl unload /Library/LaunchDaemons/jp.aeyesec.SystemInfoSync.plist 2> /dev/null
sudo launchctl load /Library/LaunchDaemons/jp.aeyesec.SystemInfoSync.plist

sudo sh -c "cat malware_monitor.sh | sed \"s!##slack_webhook_url##!${slackstr}!\" > /usr/local/bin/malware_monitor"
sudo sh -c "cat malware_monitor_scan.sh | sed \"s!##slack_webhook_url##!${slackstr}!\" > /usr/local/bin/malware_monitor_scan"
sudo chmod 700 /usr/local/bin/malware_monitor
sudo chown root:wheel /usr/local/bin/malware_monitor
sudo chmod 700 /usr/local/bin/malware_monitor_scan
sudo chown root:wheel /usr/local/bin/malware_monitor_scan
sudo cp malware_monitor_update.sh /usr/local/bin/malware_monitor_update
sudo chmod 700 /usr/local/bin/malware_monitor_update
sudo chown root:wheel /usr/local/bin/malware_monitor_update
sudo cp malware_monitor_wrapper /usr/local/bin/malware_monitor_wrapper
sudo chmod 700 /usr/local/bin/malware_monitor_wrapper
sudo chown root:wheel /usr/local/bin/malware_monitor_wrapper
sudo cp freshclam.conf /usr/local/etc/clamav/freshclam.conf
sudo mkdir /usr/local/etc/clamav/quarantine 2> /dev/null
sudo mkdir /var/log/clamav/ 2> /dev/null
sudo mkdir -p /usr/local/var/run/clamav 2> /dev/null
sudo chown -R _clamav /var/log/clamav/
sudo mkdir -p /usr/local/Cellar/clamav/0.104.1/share/clamav
sudo chown _clamav /usr/local/Cellar/clamav/*/share/clamav/
sudo chown _clamav /usr/local/var/run/clamav
if [ -e "/opt/homebrew/sbin/clamd" ]; then
  sudo chown _clamav /opt/homebrew/var/lib/clamav
  sudo /opt/homebrew/bin/freshclam -v
  sudo install -m 644 ./jp.aeyesec.Clamd2.plist /Library/LaunchDaemons/jp.aeyesec.Clamd.plist
  sudo cp clamd.conf /opt/homebrew/etc/clamav/clamd.conf
else
  sudo mkdir -p /usr/local/var/lib/clamav
  chown _clamav:_clamav /usr/local/var/lib/clamav
  sudo /usr/local/bin/freshclam -v
  sudo install -m 644 ./jp.aeyesec.Clamd.plist /Library/LaunchDaemons
  sudo cp clamd.conf /usr/local/etc/clamav/clamd.conf
fi
sudo launchctl unload /Library/LaunchDaemons/jp.aeyesec.Clamd.plist 2> /dev/null
sudo launchctl load /Library/LaunchDaemons/jp.aeyesec.Clamd.plist
sudo install -m 644 ./jp.aeyesec.ClamdOnAccessAlert.plist /Library/LaunchDaemons
sudo launchctl unload /Library/LaunchDaemons/jp.aeyesec.ClamdOnAccessAlert.plist 2> /dev/null
sudo launchctl load /Library/LaunchDaemons/jp.aeyesec.ClamdOnAccessAlert.plist
sudo install -m 644 ./jp.aeyesec.ClamdUpdate.plist /Library/LaunchDaemons
sudo launchctl unload /Library/LaunchDaemons/jp.aeyesec.ClamdUpdate.plist 2> /dev/null
sudo launchctl load /Library/LaunchDaemons/jp.aeyesec.ClamdUpdate.plist
sudo install -m 644 ./jp.aeyesec.ClamdScheduledScan.plist /Library/LaunchDaemons
sudo launchctl unload /Library/LaunchDaemons/jp.aeyesec.ClamdScheduledScan.plist 2> /dev/null
sudo launchctl load /Library/LaunchDaemons/jp.aeyesec.ClamdScheduledScan.plist
