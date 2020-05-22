#!/bin/bash
slackstatus_shell_path="/Users/"$USER"/Library/LaunchAgents/slackstatus.sh"
slackstatus_plist_path="/Users/"$USER"/Library/LaunchAgents/local.slackstatus.plist"
launchctl unload -w $slackstatus_plist_path
launchctl remove -w $slackstatus_plist_path

rm $slackstatus_plist_path 
rm $slackstatus_shell_path