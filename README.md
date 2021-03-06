# VHOST Maker
Version: 1.1.0

Interactive Apache virtual host generator. Creates server space, adds default directories, adds default files, creates openssl self-signed SSL certificate, (optionally) enables mod_pagespeed for the generated site.conf, and optionally downloads WordPress.

Author: Lee Hodson

Donate: paypal.me/vr51

First Written: 5th Dec. 2015

First Release: 26th Jan. 2016

This Release: 15th May. 2016

Code Store: https://github.com/VR51/vhost-maker

Website: https://journalxtra.com

Copyright 2015 Lee Hodson

License: GPL3


# Instructions
Command line: bash vhost-maker.sh

Desktop: click the file vhost-maker.sh (make sure it is executable)


# What to Expect
Creates and installs:

- server space
- site.conf
- site-ssl.conf
- (optionally) self-signed openssl certificate
- default directories tmp, doc, log, server-status, cgi-bin
- default index.php and .htaccess files within created directories
- openssl certificate and key to directory /etc/ssl/SITE/openssl/
- optionally installs WordPress

Enables

- (optionally) mod_pagespeed

Sets:

- log file locations to /<site-path>/log/. Log files are error.log, access.log and error-ssl.log and access-ssl.log.
- file and directory permissions to 755 and 644, respectively
- file and directory user and group to www-data:www-data (auto detected and user configurable)

The site confs generated by VHost Maker set directory locations for 'server-status' and 'log'. These locations are locked from public view. You may need to whitelist your own IP address if you wish to access the server-status dirctory and log directory with a web browser. They can be viewed using Lynx via SSH.

The server administrator needs to enable the generated sites manually. This approach is taken to allow admins to check site confs are as needed, to prevent a site going live before required, and to prevent accidental server downtime. In our experience, the site confs generated by VHost Maker work great as they are.


# Program Tested With
Used and tested on *ubuntu server 14.04, 15.10 and 16.04. Should work with other up-to-date Debian varients.


# Software Dependencies
Requires Apache, dialog or whiptail, (optionally) mod_pagespeed, (optionally) openssl
	
VHost Maker will check requird software is installed. The check will display on screen.


# What the User is Expected to Do
Run the program and follow the onscreen prompts. Be accurate.

After VHost has completed, the server admin is expected to enable the created site with:

* sudo a2ensite SITENAME
* sudo service apache2 reload

or to enable the site with

* sudo a2ensite (select site)
* sudo service apache2 restart

Add entries to /etc/hosts where applicable. Details of what to add to /etc/hosts are shown in the log and in the final screen shown by VHOST Maker.

READ THE RUN LOG AFTER PROGRAM USE


# Notes
The Apache site configuration files are created from templates stored in the VHost Maker program's 'confs' directory.

The created site confs are named with the convention:

- sitename.tld.conf
- sitename.tld-ssl.conf

Use VHost Maker responsibly.


# Warning
VHost Maker will check whether or not directories and files exist before it tries to create them and will not overwrite files directories or files that do already exist.

But...

- VHost Maker will not confirm the correctness of information entered in anwer to questions.
- VHost Maker will not delete existing files or dirctories but will add new directories and files in whatever path is stated.
- The directory and file permissions as well the run user and run group for directories and files created or made known to VHost Maker will be set as programmed or specified to VHost Maker.
- WordPress is downloaded, unzipped and the files placed into the site's root directory. No checks are made by VHost to confirm whether WP files are already present but unzip should not overwrite files that do exist. WordPress database installation needs to be handled manually by you.


# Credits
lee Hodson, JournalXtra <https://journalxtra.com>
lee Hodson, VR51 <https://vr51.com>

# Disclaimer
Provided without warrenty. Use at own risk.