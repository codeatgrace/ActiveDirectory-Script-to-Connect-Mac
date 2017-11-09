#!/bin/bash

# THIS IS A SCRIPT WE USE TO BULK CONNECT OS X LAPTOPS TO ACTIVE DIRECTORY DOMAIN
# 1 - ADJUST THE VARIABLES
# 2 - CORRECT THE dsconfigad LINE TO REFLECT PROPER DC
# 3 - DO NOT DEPLOY UNTIL YOU KNOW THE SCRIPT IS WORKING AS YOU WANT!
# IF YOU HAVE ISSUES WITH THE VARIABLES, YOU MAY WANT TO TRY HARD-CODING THE VALUES

# --- YOU MUST SET THE FOLLOWING VARIABLE ---
adUsername = "CHANGE ME TO AD ADMIN USERNAME"
adPassword = "CHANGE ME TO AD ADMIN PASSWORD"
mydomain="mydomain.local"
### NOTE: YOU MUST ALSO MODIFY dsconfigad line to reflect DC information

# redirect the output for log file
# change ".../administrator/..." to reflect the OS X desktop admin account used to run the script
	exec > /Users/administrator/Desktop/AD-Connection-Log.txt
	sleep 2
# open the console in order to watch the results live
	sudo -u Administrator open -a /Applications/Utilities/Console.app /Users/administrator/Desktop/AD-Connection-Log.txt

ECHO " !!! PPREPARING TO CONNECT MAC TO ACTIVE DIRECTORY !!!"
ECHO " --- PRE STAGE --- REMOVE EXISTING ACTIVE DIRECTORY CONNECTION"
ECHO " --> REMOVING DOMAIN SETTINGS"
	# Remove any domain settings if they exist
		sudo dsconfigad -force -remove -u $adUsername -p $adPassword

# Uncomment this section if you want to set the hostname to the serial # of the mac
# ECHO " --> USING SCUTIL TO CHANGE ComputerName, LocalHostName, and HostName"
# 	sudo scutil --set ComputerName `system_profiler SPHardwareDataType | grep -i Serial | grep -oE '[^ ]+$'`
#	sudo scutil --set LocalHostName `system_profiler SPHardwareDataType | grep -i Serial | grep -oE '[^ ]+$'`
#	sudo scutil --set HostName `system_profiler SPHardwareDataType | grep -i Serial | grep -oE '[^ ]+$'`
#ECHO "     HOSTNAME SET TO: " `hostname`
#ECHO

ECHO " --- BIND TO ACTIVE DIRECTORY ---"
ECHO " --> RUNNING DSCONFIGAD UNTIL SUCCESSFUL BIND TO AD SERVER"
	domain=$( dsconfigad -show | awk '/Active Directory Domain/{print $NF}' )
	while [[ "$domain" != "$mydomain" ]]; do
# MODIFY LINE BELOW WITH PROPER DC INFORMATION
		sudo dsconfigad -force -add $mydomain -username $adUsername -password $adPassword -ou CN=Computers,DC=mydomain,DC=local -mobile enable -mobileconfirm disable -useuncpath disable
		domain=$( dsconfigad -show | awk '/Active Directory Domain/{print $NF}' )
		sleep 5
	done
ECHO " --- AD CONNECTION COMPLETE ---"
ECHO " --- SET LOGIN TO USE FULL USERNAME ---"

	sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true
ECHO
sudo reboot
