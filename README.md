# VHOST Maker
Version: 1.0.0

Interactive Apache virtual host generator. Creates server space, adds default directories &amp; default files, creates openssl self-signed SSL crt &amp; key, enables mod_pagespeed for the generated site.conf.

Author: Lee Hodson

Donate: paypal.me/vr51

First Written: 5th Dec. 2015

First Release: 26th Jan. 2015

This Release: 26th Jan. 2015

Code Store: https://github.com/VR51/vhost-maker

Website: https://journalxtra.com

Copyright 2015 Lee Hodson

License: GPL3


# Instructions

## To Run

Command line: bash vhost-maker.sh

Desktop: click the file vhost-maker.sh


# What to Expect

## VHost Maker

Creates and installs:

	- server space
	- site.conf
	- site-ssl.conf
	- (optionally) self-signed openssl certificate

Enables

	- (optionally) mod_pagespeed

Sets:

	- file and directory permissions to 755 and 644, respectively
	- file and directory user and group to www-data:www-data (auto detected and user configurable)


# Program Tested With

	Used and tested on Kubuntu 15.10 and Ubuntu server 14.04. Should work with other up-to-date Debian varients.


# Software Dependencies

	Requires Apache, dialog or whiptail, (optionally) mod_pagespeed, (optionally) openssl
	
	VHost Maker will check requird software is installed. The check will display on screen.


# What the User is Expected to Do

Run the program and follow the onscreen prompts. Be accurate.

After VHost has complete, the user is expected to:

	To enable the created site with

		sudo a2ensite SITENAME
		sudo service apache2 reload

		or to enable the site with

		sudo a2ensite (select site)
		sudo service apache2 restart

	Add entries to /etc/hosts where applicable. Details of what to add to /etc/hosts are shown in the log and in the final screen.

	READ THE RUN LOG AFTER PROGRAM USE


# Notes

The Apache site configuration files are created from templates stored in the VHost Maker program's 'confs' directory.

The created site confs are named with the convention:

	- sitename.tld.conf
	- sitename.tld-ssl.conf

Use VHost Maker responsibly.


# Warning

VHost Maker will check whether or not dirctories and files exist before it tries to create them and will not overwrite files directories or files that do already exist.

But...

- VHost Maker will not confirm the correctness of information entered in anwer to questions.
- VHost Maker will not delete existing files or dirctories but will add new directories and files in whatever path is stated.
- The directory and file permissions as well the run user and run group for directories and files created or made known to VHost Maker will be set as programmed or specified to VHost Maker.


# Credits

lee Hodson, JournalXtra <https://journalxtra.com>
lee Hodson, VR51 <https://vr51.com>

# Disclaimer

Provided without warrenty. Use at own risk.

"If I sell you a knife and you cut yourself then that's your probelm, not mine. The power was yours." ~ Lee Hodson
