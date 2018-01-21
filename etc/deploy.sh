#!/bin/bash
#
# Here are examples of settings you might need to change on a per-project 
# basis. This file should be placed in config/deploy.sh in your projects' 
# root folder. Project settings will override both system & per-user settings.
# 
# If any value set here will override both global and per-user settings.


###############################################################################
# Project Information
###############################################################################

# A human readable project name
# PROJNAME="Best Webapp Ever"	

# A human readable client name
# PROJCLIENT="Client Name"

# Development project URL, including http:// or https:// 
# DEVURL="http://devurl.com"

# Production, or "Live" project URL, including http:// or https://
# PRODURL="http://productionurl.com"

# If you want to use an email template unique to this project (instead of the 
# globally configured template) define it below. HTML templates are stored in 
# separate folders in /etc/deploy/html. The value used below should be the 
# folder name of your template.
# HTMLTEMPLATE="default"

# If you are using html logfiles, define the full URL to the client's logo
# CLIENTLOGO="http://client.com/assets/img/logo.png"


###############################################################################
# Git Configuration
###############################################################################

# The URL for this repo's hosting, with no trailing slash. For example, if 
# you use Github and your repo URL looks like https://github.com/EMRL/deploy
# your REPOHOST should be set to https://github.com/EMRL (with no trailing 
# slash) If most of your repos are all hosted at the same location, you may 
# want to define this in either the global or user configuration files.
# REPOHOST=""

# The exact name of the Bitbucket/Github repository
# REPO="name-of-repo"

# Configure your branches. In most cases the name will be master & production. 
# If you are only using a master branch, leave production undefined.
# MASTER="master"
# PRODUCTION="production"

# Configure merge behavior. If you wish to automatically merge your MASTER and 
# PRODUCTION branches when deploying, set AUTOMERGE to TRUE.
# AUTOMERGE="TRUE"

# If dirty (yet to be committed) files exist in the repo, deploy will normally 
# not halt execution when running with the --automate flag. If you prefer to 
# have the dirty files stashed and proceed with updates set the below value 
# to TRUE. Files will be unstashed after the deployment is complete.  
# STASH="TRUE"

# Define CHECKBRANCH if you only want deploy to run when the set branch is 
# currently checked out; e.g. if CHECKBRANCH="master" and the current branch is 
# "production", deployment will halt.
# CHECKBRANCH="master"

# If you have no SSH key or wish to login manually using your account name and
# password in the console, set NOKEY to exactly "TRUE"
#
# NOKEY="TRUE"

# By default deploy will check for valid SSH keys; if you want to override this
# behavior, set DISABLESSHCHECK to TRUE
# DISABLESSHCHECK="FALSE"

# If for some reason you'd like a default commit message. It will
# always be editable before finalizing commit.	
# COMMITMSG="This is a default commit message"


###############################################################################
# Wordpress Setup
###############################################################################

# Some developers employ a file structure that separates Wordpress core from 
# their application code. If you're using non-standard file paths, define the 
# root, system, and app (plugin/theme) directories below. Note that the forward
# slash is required. Just about everyone on the planet can leave this alone.
# WPROOT="/public"
# WPAPP="/app"
# WPSYSTEM="/system"

# If you do not want to allow core updates, set DONOTUPDATEWP to TRUE.
# DONOTUPDATEWP="FALSE"

# Advanced Custom Fields Pro License
# 
# Too many issues seem to crop up with the normal method of updating the 
# Wordpress plugin ACF Pro. Including your license key below will enable 
# upgrades to happen more reliably.
# ACFKEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"


###############################################################################
# Deployment Configuration
###############################################################################

# The command to finalize deployment of your project(s)
# DEPLOY="mina deploy"				

# To require approval before pushing this project's code to a live production
# environment, set REQUIREAPPROVAL="TRUE"
# REQUIREAPPROVAL="TRUE"

# Disallow deployment; set to TRUE to enable. Double negative, it's tricky.
# DONOTDEPLOY="TRUE"


###############################################################################
# Integration
###############################################################################

# Project Management 
#
# Task#: This is used to post deploy logs to project management systems 
# that can external email input. For examples, for our task management system 
# accepts emails in the format task-####@projects.emrl.com, with the #### 
# being the task identification number for the project being deployed.
# TASK="task"
#
# If you wish to have automated deployments add tracked time to your project 
# management system, uncomment and configure the two values below. TASKUSER 
# should be the email address of the user that the time will be logged as,
# and ADDTIME is the amount of time to be added for each deployment. Time 
# formats can in hh:mm (02:23) or HhMm (2h23m) format.
# TASKUSER="deploy@emrl.com"
# ADDTIME="10m"

# Slack
# 
# You'll need to set up an "Incoming Webhook" custom integration on the Slack 
# side to get this ready to roll. 
# See https://YOURTEAMNAME.slack.com/apps/manage/custom-integrations to get 
# going. Once your Slack webhook is setup, run # 'deploy --slack-test' to 
# test your configuration.
#
# Set POSTTOSLACK to "TRUE" to enable Slack integration.
# POSTTOSLACK="TRUE"
#
# Add your full Webhook URL below, including https://
# SLACKURL="https://hooks.slack.com/services/###################/########################"
#
# Normally only successful deployments are posted to Slack.
# Enable the settings below to post on WARNiNG and/or ERROR.
# SLACKERROR="FALSE"

# Google Analytics
#
# API credentials
# CLIENTID="#############################################.apps.googleusercontent.com"
# CLIENTSECRET="########################"
# REDIRECTURI="http://localhost"
#
# OAuth authorization will expire after one hour, but will be updated when needed
# if the tokens below are configured correctly
# AUTHORIZATIONCODE="##############################################"
#
# Tokens
# ACCESSTOKEN="#################################################################################################################################"
# REFRESHTOKEN="##################################################################"
#
# Google Analytics ID
# PROFILEID="########"


###############################################################################
# Server Monitoring
###############################################################################

# Uptime and average latency can be included in logs, digests, and reports when 
# integrating with PHP Server Monitor, and an add-on API. 
# See https://github.com/EMRL/deploy/wiki/Integration for more information. 
#
# Full API URL
# MONITORURL="https://your.phpservermonitor.com/api/monitorapi.php"
#
# Email/password of the user that will access the API. Password can be stored in
# a file outside of the project repo for security reasons
# MONITORUSER="user@domain.com"
# MONITORPASS="/path/to/password/file"
# 
# Server ID to monitor. When viewing the server on your web console, your URL 
# will be something like https://monitor.com/?&mod=server&action=view&id=3 - in 
# this case SERVERID would be "3" (notice the &id=3 at the end of the URL)
# SERVERID="###"


###############################################################################
# Logging
###############################################################################

# If you need to send logfiles and email alerts to address(es) other 
# than those configured globally, enter them below.
# TO="notify@client.com"

# IF INCOGNITO is set to true, log files as well as verbose output to screen 
# will be stripped of details such as email addresses and system file paths.
# INCOGNITO="TRUE"

# Post HTML logs to remote server. This needs to be set to "TRUE" even you
# are only posting to LOCALHOST.
# REMOTELOG="TRUE"

# Define the root url where the deploy log will be accessible with no 
# trailing slash
# REMOTEURL="http://deploy.domain.com"

# If using HTML logs, define which template you'd like to use. HTML templates
# are stored in separate folders in /etc/deploy/html. The value used below 
# should be the folder name of your template.
# REMOTETEMPLATE="default"

# Post logs via SCP
# SCPPOST="TRUE"
# SCPUSER="user"
# SCPHOST="hostname.com"
# SCPHOSTPATH="/full/path/to/file"

# DANGER DANGER: If for some reason you absolutely can't use an SSH key you 
# can configure your password here
# SCPPASS="password"

# Post commit logs to this URL.
# POSTURL=""

# If you're posting logs to a place on the same machine you're deploying from,
# set POSTTOLOCALHOST to "TRUE" and define the path where you want to store 
# the HTML logs.
# LOCALHOSTPOST="TRUE"
# LOCALHOSTPATH="/var/www/production/deploy"


###############################################################################
# Weekly Digests
###############################################################################

# If you'd like to send branded HTML emails using the `deploy --digest [project]` 
# command, enter the recipient's email address below. Email value can be a comma 
# separated string of multiple addresses. 
# DIGESTEMAIL="digest@email.com"

# If you are using a digest theme that includes a cover image, at the URL below.
# DIGESTCOVER="http://client.com/assets/img/cover.jpg"

# If you'd like to post a Slack notification with a URL to view the weekly digest  
# set the following to TRUE. IF you want to use an incoming webhook other than the 
# one defined in SLACKURL below, enter that here *instead* of TRUE.
# DIGESTSLACK="TRUE"


###############################################################################
# Monthly Reporting
###############################################################################

# First and last name of the primary contact for this client 
# CLIENTCONTACT="First Last"

# Include hosting as a line item on monthly reports? If set to TRUE, the report
# line item will read "Monthly web hosting"; customize the text included in
# report by setting it to any other value.
# INCLUDEHOSTING="TRUE"
