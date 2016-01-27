#!/bin/bash
clear
###
#
#	VHOST Maker
#	Version: 1.0.1
#
#	Author: Lee Hodson
#	Donate: paypal.me/vr51
#	First Written: 5th Dec. 2015
#	First Release: 26th Jan. 2015
#	This Release: 26th Jan. 2015
#
#	https://github.com/VR51/vhost-maker
#	https://journalxtra.com
#
#	Copyright 2015 Lee Hodson
#	License: GPL3
#
#		Commercial and non-commercial use permitted. Program developer(s) must be credited. Credits may not be removed. Derivitive works must include credits.
#
#
###


###
#
#	INSTRUCTIONS
#
###
#
#	TO RUN either 'bash vhost-maker.sh' or click the file 'vhost-maker.sh'
#
#
###


###
#
#	WHAT TO EXPECT
#
###
#
#		Creates and installs:
#
#			server space
#			site.conf
#			site-ssl.conf
#			(optionally) self-signed openssl certificate
#
#		Enables
#
#			(optionally) mod_pagespeed
#
#		Sets:
#
#			file and directory permissions to 755 and 644, respectively
#			file and directory user and group to www-data:www-data (auto detected and user configurable)
#
#
#	PROGRAM TESTED WITH
#
#		Used and tested on Kubuntu 15.10 and Ubuntu server 14.04. Should work with other up-to-date Debian varients.
#
#
#	SOFTWARE DEPENDENCIES
#
#		Requires Apache, dialog or whiptail, (optionally) mod_pagespeed, (optionally) openssl
#
#
#	USER IS EXPECTED
#
#		To enable the created site with
#
#			sudo a2ensite SITENAME
#			sudo service apache2 reload
#
#			or with
#
#			sudo a2ensite (select site)
#			sudo service apache2 restart
#
#		Add entry to /etc/hosts where applicable
#
#	READ THE RUN LOG AFTER PROGRAM USE
#
#
###

##
#
#	WARNING
#
##
#
#	VHost Maker will check whether or not dirctories and files exist before it tries to create them and will not overwrite files directories or files that do already exist.
#
#	But...
#
#	VHost Maker will not confirm the correctness of information entered in anwer to questions.
#	VHost Maker will not delete existing files or dirctories but will add new directories and files in whatever path is stated.
#	The file permissions, run user and run group for directories and files created or made known to VHost Maker will be set as programmed or specified to VHost Maker.
#
#
##

###
#
#	CREDITS
#
###
#
#	lee Hodson, JournalXtra <https://journalxtra.com>
#	lee Hodson, VR51 <https://vr51.com>
#
#
###

###
#
#	DISCLAIMER
#
###
#
#	Provided without warrenty. Use at own risk.
#
#	"If I sell you a knife and you cut yourself then that's your probelm, not mine. The power was use." ~ Lee Hodson
#
#
###



###
#
#	Let the user know we are running
#
###

printf "VHOST MAKER STARTED\n--------------------------\n\n"

###
#
#	Set Variables
#
###

version="v1.0.1"
title="VHost Maker"

# Establish Linux epoch time in seconds
now=$(date +%s)

# Establish both Date and Time
todaytime=$(date +"%Y-%m-%d-%H:%M:%S")

# Locate Where We Are
filepath="$(dirname "$(readlink -f "$0")")"


###
#
#	Make Program Dirctories
#
###

programdirectories=( 'log' 'tmp' )
for i in "${programdirectories[@]}"; do

	if test ! -d "$filepath/$i"
	then
		mkdir "$filepath/$i"
	fi

done


###
#
#	Register add_to_log function
#
###

add_to_log() {
	# Add to log file
	printf "\n$(date +"%Y-%m-%d-%H:%M:%S"): $1" >> "$filepath/log/run.log"
	# Print to screen
	printf "\n$(date +"%Y-%m-%d-%H:%M:%S"): $1"
}


###
#
#	Register leave_program function
#
###

leave_program() {

	exittime=$(date +%s)
	runtime=$(($exittime - $now))

	add_to_log "RUN END"
	add_to_log "PROGRAM RUN TIME: $runtime seconds"

	$DIALOG --clear \
		--backtitle "$title" \
		--title "$title Tasks Complete" \
		--msgbox "Thank You for using $title.
		\n\n
		Visit https://journalxtra.com to learn more about $title.
		\n\n
		Send donations to paypal.me/vr51
		\n\n
		Program Run Time: $runtime seconds" 0 0

	exit

}


###
#
#	Add Start Time to run.log
#
###

add_to_log "RUN START"


###
#
#	Confirm we are running in a terminal
#		If not, try to launch this program in a terminal
#
###

tty -s

if test "$?" -ne 0
then

	# This code section is released in public domain by Han Boetes <han@mijncomputer.nl>
	# Updated by Dave Davenport <qball@gmpclient.org>
	# Updated by Lee Hodson <https://journalxtra.com> - Added break on successful hit, added more terminals, humanized the failure message, replaced call to rofi with printf and made $terminal an array for easy reuse.
	#
	# This script tries to exec a terminal emulator by trying some known terminal
	# emulators.
	#
	# We welcome patches that add distribution-specific mechanisms to find the
	# preferred terminal emulator. On Debian, there is the x-terminal-emulator
	# symlink for example.

	terminal=( 'konsole' 'gnome-terminal' 'x-terminal-emulator' 'xdg-terminal' 'terminator' 'urxvt' 'rxvt' 'Eterm' 'aterm' 'roxterm' 'xfce4-terminal' 'termite' 'lxterminal' 'xterm' )
	for i in "${terminal[@]}"; do
		if command -v $i > /dev/null 2>&1; then
			exec $i -e "$0"
			break
		else
			printf "\nUnable to automatically determine the correct terminal program to run e.g Console or Konsole. Please run $title program from a terminal AKA the command line.\n"
			read something
			leave_program
		fi
	done

fi

add_to_log "CHECKED FOR TERMINAL PROGRAM"


###
#
#	Check for required software dependencies
#
###

add_to_log "CHECKING FOR SOFTWARE DEPENDENCIES"
printf "\n\n"

requirement=( dialog whiptail apache2 openssl ) # p7zip and p7zip-full. Their status flag is used near line 510 (# Select the hosts file blocklists)
for i in ${requirement[@]}; do

	if command -v $i > /dev/null 2>&1; then
		statusmessage+=("%4sFound:%10s$i")
		statusflag+=('0')
	else
		statusmessage+=("%4sMissing:%8s$i")
		statusflag+=('1')
		whattoinstall+=("$i")
		error=1
	fi

done

# Display status of presence or not of each requirement

for LINE in "${statusmessage[@]}"; do
	printf "$LINE\n"
done

printf "\n"

# Check for critical errors. Set critical flag as appropriate.

critical=0

if test "${statusflag[0]}" = 1 && test "${statusflag[1]}" = 1; then
		printf "%4sCritical:%6s Neither dialog nor whiptail is installed. $title cannot run without at least one of them\n"
		critical=1
fi

if test "${statusflag[2]}" = 1; then
		printf "%4sCritical:%6s Apache2 is not installed. $title cannot run without Apache2\n"
		critical=1
fi

# Display warning messages

if test "${statusflag[3]}" = 1; then
		printf "%4sWarning:%6s openssl is not installed. $title will not ask to install openssl certificate. Install openssl or install certificate manually.\n"
		critical=1
fi

# Display appropriate status messages

if test "$error" = 0 && test "$critical" = 0; then
	printf "The software environment is optimal for this program.\n\n"
fi

if test "$error" = 1 && test "$critical" = 0; then
	printf "Non essential software required by $title is missing from this system. Some features may be disabled. If the program fails to run, consider to install with, for example,\n\n%6s sudo apt-get install ${whattoinstall[*]}\n\n"
fi

if test "$critical" = 1; then
	printf "Critical Error: essential software dependencies are missing from this system. $title will stop here. Install missing software with, for example,\n\n%6s sudo apt-get install ${whattoinstall[*]}\n\n"
	read something
	leave_program
fi

add_to_log "CHECKED SOFTWARE DEPENDENCIES"


###
#
#	Set Dialog Program to use.
#		In this case we use first try to use 'dialog' then, if dialog is not installed, we try to use 'whiptail'. We could add or use any other dialog compatible program to the list.
#		The colour palette used by whiptail is controlled by newt. It can be configured with 'sudo update-alternatives --config newt-palette'
#		The colour palette used by dialog can be set by issuing command 'dialog --create-rc ~/.dialogrc'. The file .dialogrc can be edited as needed.
#
###

dialoguesystem=( dialog whiptail )
for i in "${dialoguesystem[@]}" ; do
	if command -v $i > /dev/null 2>&1; then
		DIALOG=$i
		break
	fi
done


###
#
#	Obtain Authorisation to Make System Changes
#
###

printf "\n\nAUTHORISATION\n-------------\n"

printf "\nAuthorise $title to install and edit files:\n"
sudo -v

add_to_log "ASKED FOR AUTHORISATION"


###
#
#	Introduction
#
###

$DIALOG --clear \
	--backtitle "$title" \
	--title "$title Creates Virtual Hosts for Apache Websites" \
	--msgbox "General Information.
\n\n
$title will create a server space and create an Apache virtual host config file to enable HTTP and HTTPS access for the created site.
\n\n
$title will optionally install a self-signed wildcard openssl certificate for the host provided openssl is installed on this system.
\n\n
Full instructions are in the readme.txt file that shipped with $title.
\n\n
The log file is in $filepath/log.
\n\n
If this is a development environment on a local machine read the log file if you need a reminder of what to add to the server's hosts file.
\n\n
More information about $title can be found at https://journalxtra.com.
\n\n
The next page begins the site creation process.
\n\n
$title is programmed to not overwrite existing files and directories. That does not mean is cannot happen. Use responsibily." 0 0

add_to_log "SHOWED INTRODUCTION TEXT"


##
#
#	Get the site title
#
##

sitename="$($DIALOG --stdout --clear --backtitle "$title" --inputbox 'What is the hostname of the site? Do not include protocols like HTTP or HTTPS' 0 0 'example.com')"

add_to_log "GOT THE SITE NAME"


##
#
#	Get the site server space directory
#
##

sitedirectory="$($DIALOG --stdout --clear --backtitle "$title" --inputbox "Enter the name of the site's directory? The site name is normally fine here." 0 0 "$sitename")"

add_to_log "GOT THE SITE DIRECTORY"


##
#
#	Get the server root directory
#
##

serverroot="$($DIALOG --stdout \
--clear \
--backtitle "$title" \
--radiolist "What is the server's root directory path. The site will be installed under this location. /var/www is normally correct for an Ubuntu system." 0 0 0 \
Default '/var/www' On \
Custom 'Enter a different server root path' Off \
)"

case $serverroot in

	Default) serverroot="/var/www"
	
	;;

	Custom) serverroot="$($DIALOG --stdout --clear --backtitle "$title" --inputbox "Enter the server's root directory. Do not enter the site name here or site directory here. Include the leading forward slash." 0 0 '/var/www')"
	
	;;

esac

add_to_log "GOT THE SERVER ROOT DIRECTORY PATH"


##
#
#	Get the HTTP port address
#
##

# Ask which port the server listens to
port="$($DIALOG --stdout \
--clear \
--backtitle "$title" \
--radiolist 'Which port does the server listen to for HTTP traffic' 0 0 0 \
80 '80 (default)' On \
Custom 'Enter a different HTTP listen port address' Off \
)"

case $port in

	Custom) port="$($DIALOG --stdout --clear --backtitle "$title" --inputbox 'Enter the HTTP port address' 0 0 '80')"
	
	;;

esac

add_to_log "GOT THE HTTP PORT"


##
#
#	Get the HTTPS port address
#
##

# Ask which port the server listens to
sslport="$($DIALOG --stdout \
--clear \
--backtitle "$title" \
--radiolist 'Which port does the server listen to for HTTPS traffic' 0 0 0 \
443 '443 (default)' On \
Custom 'Enter a different HTTPS listen port address' Off \
)"

case $sslport in

	Custom) sslport="$($DIALOG --stdout --clear --backtitle "$title" --inputbox 'Enter the HTTPS listen port address' 0 0 '443')"
	
	;;

esac

add_to_log "GOT THE HTTPS PORT"


##
#
#	SSL: Are we installing wildcard openssl certificate
#
##

if test "${statusflag[3]}" = 0; then

	$DIALOG --clear --backtitle "$title" --title "OPENSSL Certificate" --yesno "Install self-signed wildcard SSL certificate?\n\nThis is a free openssl certificate suitable fir development environments and internal networks. Do not use for production sites unless you know what you are doing." 0 0
	sslinstall=$?

	add_to_log "ASKED TO INSTALL WILDCARD OPENSSL CERTIFICATE"

	else
	
	sslinstall='1'
	
fi


##
#
#	Get the IP address for the site
#
##

ipaddress="$($DIALOG --stdout \
--clear \
--backtitle "$title" \
--radiolist 'Set the IP Address of the site' 0 0 0 \
127.0.0.1 'localhost (default)' On \
127.0.1.1 'localhost (non default)' Off \
0.0.0.0 'localhost (non default)' Off \
Custom 'Type in a custom IP Address' Off \
)"

case $ipaddress in

	Custom) ipaddress="$($DIALOG --stdout --clear --backtitle "$title" --inputbox 'Enter the IP address the server will use for this site' 0 0 '127.0.1.1')"

esac

add_to_log "GOT THE SITE IP ADDRESS"


##
#
#	Get the site admin email address
#
##

emailaddress="$($DIALOG --stdout \
--clear \
--backtitle "$title" \
--radiolist 'Set the webmaster email name for this site. Do not include the hostname.' 0 0 0 \
webmaster 'webmaster (default)' On \
admin 'admin' Off \
Custom 'Type in a different name' Off \
)"

case $emailaddress in

	Custom) emailaddress="$($DIALOG --stdout --clear --backtitle "$title" --inputbox 'Enter the webmaster email name for this site' 0 0 'webmaster')"
	
	;;

esac

add_to_log "GOT EMAIL ADDRESS"


##
#
#	Are we using mod_pagespeed
#
##

$DIALOG --clear --backtitle "$title" --title "Mod_Pagespeed" --yesno 'Is mod_pagespeed installed on this server? Shall we enable mod_pagespeed for this site?' 0 0
allowpagespeed=$?

add_to_log "MOD_PAGESPEED QUESTION"


##
#
#	Apache User
#
##

# Attempt to detect the Apache user
apacheuserauto=$(grep 'export APACHE_RUN_USER=' /etc/apache2/envvars | cut -f2- -d'=')

apacheuser="$($DIALOG --stdout \
--clear \
--backtitle "$title" \
--radiolist 'Which user does Apache run as?' 0 0 0 \
www-data "www-data (default)" On \
auto "$apacheuserauto" Off \
Custom 'Type in a different run user' Off \
)"

case $apacheuser in

	auto) apacheuser="$apacheuserauto"
	
	;;

	Custom) apacheuser="$($DIALOG --stdout --clear --backtitle "$title" --inputbox 'Enter the username. This is not your own login username.' 0 0 "$apacheuserauto")"
	
	;;

esac

add_to_log "APACHE USER QUESTION"


##
#
#	Apache User
#
##

# Attempt to detect the Apache user
apachegroupauto=$(grep 'export APACHE_RUN_GROUP=' /etc/apache2/envvars | cut -f2- -d'=')

apachegroup="$($DIALOG --stdout \
--clear \
--backtitle "$title" \
--radiolist 'Which group does the Apache user belong to?' 0 0 0 \
www-data "www-data (default)" On \
auto "$apachegroupauto" Off \
Custom 'Type in a different group name' Off \
)"

case $apachegroup in

	auto) apachegroup="$apachegroupauto"
	
	;;

	Custom) apachegroup="$($DIALOG --stdout --clear --backtitle "$title" --inputbox 'Enter the run group. This is not your own group.' 0 0 "$apachegroupauto")"
	
	;;

esac

add_to_log "APACHE GROUP QUESTION"


##
#
#	Now Work
#
#		Create space on the server
#		Add directories
#		Add .htaccess and index.php
#		Create vhost
#		Move vhost to /etc/apache2/sites-available
#		Install xip-io SSL as appropriate
#
##


# Make Site Directories and Add Default Files

sudo mkdir "$serverroot/$sitename"

directories=( 'tmp' 'log' 'cgi-bin' 'doc' 'server-status' )
files=( '.htaccess' 'index.php' )

for i in "${directories[@]}"; do

	if test ! -d "$serverroot/$sitename/$i"
	then
		sudo mkdir "$serverroot/$sitename/$i"
		
		add_to_log "INSTALLED DEFAULT DIRECTORY $serverroot/$sitename/$i"
		
	else
	
		add_to_log "DID NOT INSTALL DEFAULT DIRECTORY $serverroot/$sitename/$i. ALREADY EXISTS"
	
	fi
	
	for f in "${files[@]}"; do

		if test ! -f "$serverroot/$sitename/$f"
		then
			sudo touch "$serverroot/$sitename/$f"
			
			add_to_log "INSTALLED DEFAULT FILE $serverroot/$sitename/$f"
		else
		
			add_to_log "DID NOT INSTALL DEFAULT FILE $serverroot/$sitename/$f. ALREADY EXISTS"
		
		fi
	
		if test ! -f "$serverroot/$sitename/$i/$f"
		then
			sudo touch "$serverroot/$sitename/$i/$f"
			
			add_to_log "INSTALLED DEFAULT FILE $serverroot/$sitename/$i/$f"
		else
		
			add_to_log "DID NOT INSTALL DEFAULT FILE $serverroot/$sitename/$i/$f. ALREADY EXISTS"
		
		fi
	
	done

done


# Add default content to index.php if file size is 0

size=$(wc -c <"$serverroot/$sitename/index.php")
if test $size -eq 0 ; then

	printf "\n"
	printf "<?php echo '<p>Welcome to $sitename.</p><p>Test both HTTP and HTTPS versions of this site to confirm proper installation.</p><p>Host created with $title $version.</p><p>Read more about $title at https://github.com/vr51/vhost-maker</p>'; ?>" | sudo tee -a "$serverroot/$sitename/index.php"
	add_to_log "INSTALLED WELCOME TEXT INTO $serverroot/$sitename/index.php"
	
else

	add_to_log "DID NOT INSTALL WELCOME TEXT INTO $serverroot/$sitename/index.php. FILE ALREADY HAS CONTENT"

fi

# Make site confs. Overwrite existing files in tmp directory if needs be.

cp "$filepath/confs/default.conf" "$filepath/tmp/$sitename.conf"
cp "$filepath/confs/default-ssl.conf" "$filepath/tmp/$sitename-ssl.conf"

# Data in these two arrays is mapped by list order
search=( 'IPADDRESS' 'SSLPORT' 'PORT' 'SITENAME' 'EMAILADDRESS' 'SERVERROOT' 'DUMMYDATA')
replace=( "$ipaddress" "$sslport" "$port" "$sitename" "$emailaddress" "$serverroot" "DUMMYDATA")

for i in ${search[@]}; do

		sed -i "s#$i#${replace[0]}#g" "$filepath/tmp/$sitename.conf"
		sed -i "s#$i#${replace[0]}#g" "$filepath/tmp/$sitename-ssl.conf"
		# Remove the first array item from replace[@]
		replace=("${replace[@]:0:0}" "${replace[@]:1}")

done

### Below method left here in case it's needed again.
#
#	#search=( 'IPADDRESS' 'SSLPORT' 'PORT' 'SITENAME' 'EMAILADDRESS' 'SERVERROOT' )
#	#replace=( "$ipaddress" "$sslport" "$port" "$sitename" "$emailaddress" "$serverroot" )
#
#	#for i in "${search[@]}"; do
#
#	#	for r in "${replace[@]}"; do
#	#		# This is a fudge -- it loops through needless data -- but it works
#	#		sed -i "s/$i/$r/g" "$filepath/tmp/$sitename.conf"
#	#		sed -i "s/$i/$r/g" "$filepath/tmp/$sitename-ssl.conf"
#		
#	#	done
#
#	#done


add_to_log "MADE SITE CONFS"


# Enable mod_pagespeed for the sites

if test "$allowpagespeed" = 0; then

	sed -i "s/# ModPagespeedDomain/ModPagespeedDomain/g" "$filepath/tmp/$sitename.conf"
	sed -i "s/# ModPagespeedDomain/ModPagespeedDomain/g" "$filepath/tmp/$sitename-ssl.conf"

	add_to_log "ENABLED MOD_PAGESPEED IN SITE CONFS"
	
fi


# Install wildcard openssl certificate as appropriate

if test "$sslinstall" = 0; then

	ssl_dir="/etc/ssl/$sitename/openssl"
	
	# Install only if the SSL cert and key files do not already exist
	if test ! -f "$ssl_dir/$sitename-openssl.key" && test ! -f "$ssl_dir/$sitename-openssl.crt" ; then

		printf "\n"
		# Generate the certificate
		sudo mkdir -p "$ssl_dir"
		sudo openssl req -x509 -sha256 -newkey rsa:2048 -keyout "$ssl_dir/$sitename-openssl.key" -out "$ssl_dir/$sitename-openssl.crt" -days 1024 -nodes -subj "/CN=*.$sitename"
		
		# Enable the certificate in site-ssl.conf
		sed -i "s@# SSLCertificateKeyFile PATH@SSLCertificateKeyFile $ssl_dir/$sitename-openssl.key@g" "$filepath/tmp/$sitename-ssl.conf"
		sed -i "s@# SSLCertificateFile PATH@SSLCertificateFile $ssl_dir/$sitename-openssl.crt@g" "$filepath/tmp/$sitename-ssl.conf"
		
		add_to_log "INSTALLED WILDCARD OPENSSL CERTIFICATE AND KEY INTO $ssl_dir"
		
	else
		
		add_to_log "DID NOT INSTALL WILDCARD OPENSSL CERTIFICATE AND KEY INTO $ssl_dir. ALREADY EXIST."
		
	fi

fi


# Move site confs to /etc/apache2/sites-available

if test ! -f "/etc/apache2/sites-available/$sitename.conf"; then
	sudo cp "$filepath/tmp/$sitename.conf" "/etc/apache2/sites-available/$sitename.conf"
	
	add_to_log "COPIED HTTP CONF TO /ETC/APACHE2/SITES-AVAILABLE"
	
else
	
	add_to_log "DID NOT COPY HTTP CONF TO /ETC/APACHE2/SITES-AVAILABLE. ALREADY EXISTS"
	
fi

if test ! -f "/etc/apache2/sites-available/$sitename-ssl.conf"; then
	sudo cp "$filepath/tmp/$sitename-ssl.conf" "/etc/apache2/sites-available/$sitename-ssl.conf"
	
	add_to_log "COPIED HTTPS CONF TO /ETC/APACHE2/SITES-AVAILABLE"
	
else
	
	add_to_log "DID NOT COPY HTTPS CONF TO /ETC/APACHE2/SITES-AVAILABLE. ALREADY EXISTS"
	
fi
	
	
#	Set File and Dirctory Permissions

add_to_log "CHECKED DIRECTORY (755) AND FILE (644) PERMISSIONS AT AND IN $serverroot/$sitename"

sudo find "$serverroot/$sitename" -type d -exec chmod 755 {} \;
sudo find "$serverroot/$sitename" -type f -exec chmod 644 {} \;


#	Check File and Dirctory Ownerships

add_to_log "CHECKED DIRECTORY AND FILE OWNERSHIP ($apacheuser":"$apachegroup) AT AND IN $serverroot/$sitename"

sudo chown -R "$apacheuser":"$apachegroup" "$serverroot/$sitename"


###
#
#	Outro
#
###

if test "$sslinstall" = '0'; then

	$DIALOG --clear \
		--backtitle "$title" \
		--title "SITE CREATED" \
		--msgbox "General Information.
	\n\n
	The site $sitename has been created.
	\n\n
	The server space for this site is in $serverroot/$sitename.
	\n\n
	The configuration files are at:
	\n\n
		1) /etc/apache2/sites-available/$sitename.conf
		\n
		2) /etc/apache2/sites-available/$sitename-ssl.conf
	\n\n
	The wildcard  certificate $title installed is self-signed. It will need to be replaced if this is a production site.
	\n\n
	If this is a local (development) server add the next two lines to /etc/hosts:
	\n\n
		1) $ipaddress	$sitename
		\n
		2) $ipaddress	www.$sitename
	\n\n
	Enable the sites with:
	\n\n
		1) a2ensite $sitename.conf
		\n
		2) a2ensite $sitename-ssl.conf
	\n\n
	Then restart Apache with the command 
	\n\n
		1) sudo service apache2 restart
	\n\n
	More information about $title can be found at https://journalxtra.com.
	\n\n
	Send donations to paypal.me/vr51" 0 0
	
	add_to_log "SHOWED OUTRO TEXT"
	
	add_to_log "ADD TO LOCALHOST in /etc/hosts (?):\n\n\t$ipaddress	$sitename\n\t$ipaddress	www.$sitename\n"

fi

if test "$sslinstall" = '1'; then

	$DIALOG --clear \
		--backtitle "$title" \
		--title "SITE CREATED" \
		--msgbox "General Information.
	\n\n
	The site $sitename has been created.
	\n\n
	The server space for this site is in $serverroot/$sitename.
	\n\n
	The configuration files are at:
	\n\n
		1) /etc/apache2/sites-available/$sitename.conf
		\n
		2) /etc/apache2/sites-available/$sitename-ssl.conf
	\n\n
	Edit $sitename-ssl.conf to update the path to the SSL certificate (crt) file and key file.
	\n\n
	If this is a local (development) server add the next two lines to /etc/hosts:
	\n\n
		1) $ipaddress	$sitename
		\n
		2) $ipaddress	www.$sitename
	\n\n
	Enable the sites non-SSL site with:
	\n\n
		1) a2ensite $sitename.conf
	\n\n
	Enable the sites SSL site when the certificate is installed and certificate path in $sitename-conf has been amended with:
	\n\n
		1) a2ensite $sitename-ssl.conf
	\n\n
	Restart Apache to enable the new site(s) with the command
	\n\n
		1) sudo service apache2 restart
	\n\n
	More information about $title can be found at https://journalxtra.com.
	\n\n
	Send donations to paypal.me/vr51" 0 0

	add_to_log "SHOWED OUTRO TEXT"
	
	add_to_log "ADD TO LOCALHOST in /etc/hosts (?):\n\n\t$ipaddress	$sitename\n\t$ipaddress	www.$sitename\n"
	
fi

leave_program