#!/bin/bash
SLACKAPIKEY=`osascript -e 'set T to text returned of (display dialog "Enter your Slack OAuth API key" buttons {"Cancel", "OK"} default button "OK" default answer "" with hidden answer)'`

# Set  wifi SSIDs
MYWORKSSID=`osascript -e 'set T to text returned of (display dialog "What is the SSID (name) of your office Wifi?" buttons {"Cancel", "OK"} default button "OK" default answer "WeWork")'`
MYHOMESSID=`osascript -e 'set T to text returned of (display dialog "What about your home Wifi?" buttons {"Cancel", "OK"} default button "OK" default answer "MyHomeWiFi")'`
COFFEESSID=`osascript -e 'set T to text returned of (display dialog "Have a favorite coffee shop?" buttons {"Cancel", "OK"} default button "OK" default answer "Google Starbucks")'`


# Detemine if api key is valid
IS_VALID=`curl https://slack.com/api/auth.test --data 'token='$SLACKAPIKEY |     python -c "import sys, json; print json.load(sys.stdin)['ok']"`

if [ $IS_VALID == "True" ]; then
    slackstatus_shell_path="/Users/"$USER"/Library/LaunchAgents/slackstatus.sh"
    slackstatus_plist_path="/Users/"$USER"/Library/LaunchAgents/local.slackstatus.plist"


    cat <<< "#!/bin/bash
ssid=\`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr(\$0, index(\$0, \$2))}'\`
slack_token=\""$SLACKAPIKEY"\"


if [ \"\$ssid\" == \"$MYWORKSSID\" ]; then
    # set status to 'In the office'
    /usr/bin/curl https://slack.com/api/users.profile.set --data 'token='\$slack_token'&profile=%7B%22status_text%22%3A%20%22In%20the%20office%22%2C%22status_emoji%22%3A%20%22%3Aoffice%3A%22%7D' > /dev/null
elif [ \"\$ssid\" == \"$MYHOMESSID\" ]; then
    # set status to 'Working from home'
    /usr/bin/curl https://slack.com/api/users.profile.set --data 'token='\$slack_token'&profile=%7B%22status_text%22%3A%20%22Working%20from%20home%22%2C%22status_emoji%22%3A%20%22%3Ahouse_with_garden%3A%22%7D' > /dev/null
elif [ \"\$ssid\" == \"$COFFEESSID\" ]; then
    # set status to 'At coffee shop'
    /usr/bin/curl https://slack.com/api/users.profile.set --data 'token='\$slack_token'&profile=%7B%22status_text%22%3A%20%22At%20coffee%20shop%22%2C%22status_emoji%22%3A%20%22%3Acoffee%3A%22%7D' > /dev/null
else
    # set status to 'Location unknown'
    /usr/bin/curl https://slack.com/api/users.profile.set --data 'token='\$slack_token'&profile=%7B%22status_text%22%3A%20%22Somewhere%20unknown...%22%2C%22status_emoji%22%3A%20%22%3Ashrug%3A%22%7D' > /dev/null
fi" > $slackstatus_shell_path
    chmod a+x $slackstatus_shell_path
    cat <<< '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>local.slackstatus</string>
  <key>ProgramArguments</key>
  <array>
  <string>'$slackstatus_shell_path'</string>
  </array>
  <key>WatchPaths</key>
  <array>
    <string>/etc/resolv.conf</string>
    <string>/Library/Preferences/SystemConfiguration/NetworkInterfaces.plist</string>
    <string>/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>' > $slackstatus_plist_path
    launchctl unload -w $slackstatus_plist_path
    launchctl load -w $slackstatus_plist_path
else
    osascript -e 'display dialog "We could not verify that token" buttons {"Cancel", "OK"} default button "OK"'
fi
