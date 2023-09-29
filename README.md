# curry-wurst
This repository contains a collection of handy scripts for various purposes. Whether you're a developer, sysadmin, or just someone looking to automate everyday tasks, you might find something useful here.
Feel free to explore and use these scripts to make your life easier.

## Clean-Desktop

The Clean-Desktop PowerShell script is a handy tool for archiving and cleaning up files on your desktop. It utilizes a JSON configuration file to customize the cleanup process according to your preferences.   

Here's the default Clean-Desktop.json file:  

&nbsp;&nbsp;{   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"General": {   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"BackupLocation": "C:\\\Users\\\%USERNAME%\\\OneDrive\\\Documents\\\_ Archives",   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"DateFormat": "yyyyMMdd",   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"Threshold": 1   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;},   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"Filter": {   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"Exclude": ["*.lnk"]   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;},   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"Debug": {   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"WhatIf": true   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}   
&nbsp;&nbsp;}   

**BackupLocation:** The folder where files from the desktop will be moved for backup. Specify the path as a string, you can also user environnement variables.    
**DateFormat:** Name of the subfolder within the archive folder (Backup Location). Use: d for day, M for month, y for year.   
**Threshold:** The number of days old a file on the desktop can be before it's moved to the backup location. Specify an integer value.   
**Filter:** An optional filter for file extensions to exclude from the cleanup process. By default, it's set to *.lnk.   
**WhatIf:** Set this option to $true if you want to perform a simulation without actually moving files. This is useful for testing the configuration.   

