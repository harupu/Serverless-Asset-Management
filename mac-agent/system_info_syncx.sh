SPREADSHEET_URL="##spread_sheet_api_url##"
SERIAL=$(system_profiler SPHardwareDataType | grep Serial | sed -e "s/.*: //")
HOSTNAME=$(hostname)
USERNAME=$(/usr/bin/stat -f "%Su" /dev/console)
if [ "$USERNAME" = "root" ]; then
    USERNAME=$(ls -t /Users/ | grep -v Shared | head -1)
fi
OSVER=$(sw_vers | grep ProductVersion | sed -e "s/.*:.//")
BUILDVER=$(sw_vers | grep Build | sed -e "s/.*:.//")
ANTI_VIRUS="False"
if [ "$(echo PING | nc -U /usr/local/var/run/clamav/clamd.sock)" = "PONG" ]; then
    ANTI_VIRUS="True"
fi

CLAMDSCAN="/usr/local/bin/clamdscan"
if [ -e "/opt/homebrew/bin/clamdscan" ]; then
    CLAMDSCAN="/opt/homebrew/bin/clamdscan"
fi
SIGVAR=$($CLAMDSCAN --version | awk -F "[ /]" '{print $3}')
if [ -e "/opt/homebrew/bin/clamdscan" ]; then
    SIGDATE=$(date -r $(stat -f "%m" /opt/homebrew/var/lib/clamav/daily.cld) "+%Y/%m/%d %H:%M")
else
    if [ -e "/usr/local/var/lib/clamav/daily.cvd" ]; then
        SIGDATE=$(date -r $(stat -f "%m" /usr/local/var/lib/clamav/daily.cvd) "+%Y/%m/%d %H:%M")
    else
        SIGDATE=$(date -r $(stat -f "%m" /usr/local/var/lib/clamav/daily.cld) "+%Y/%m/%d %H:%M")
    fi
fi

curl -s -S -X POST $SPREADSHEET_URL -H "Content-Type: application/x-www-form-urlencoded" -d "serialNumber=$SERIAL&hostname=$HOSTNAME&username=$USERNAME&latestKB=&realtimeEnabled=$ANTI_VIRUS&signatureVersion=$SIGVAR&signatureDate=$SIGDATE&osVersion=${OSVER}_$BUILDVER" > /dev/null
