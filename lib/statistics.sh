#!/usr/bin/env bash
#
# statistics.sh
#
###############################################################################
# Generate HTML statistics pages
###############################################################################
trace "Loading statistics functions"

# Initialize variables
read -r DB_API_TOKEN DB_BACKUP_PATH LAST_BACKUP BACKUP_STATUS CODE_STATS \
	BACKUP_BTN LATENCY_BTN UPTIME_BTN SCAN_BTN COMMITS_RECENT <<< ""
echo "${DB_API_TOKEN} ${DB_BACKUP_PATH} ${LAST_BACKUP} ${BACKUP_STATUS} 
	${CODE_STATS} ${BACKUP_BTN} ${LATENCY_BTN} ${UPTIME_BTN} ${SCAN_BTN}
	${COMMITS_RECENT}" > /dev/null

function project_stats() {
	hash gitchart 2>/dev/null || {
	error "gitchart not installed." 
	}

	if [[ "${REMOTELOG}" == "TRUE" ]]; then
	# Check for approval queue
	queue_check

	# Setup up tmp work folder
	if [[ ! -d "/tmp/stats" ]]; then
		umask 077 && mkdir /tmp/stats &> /dev/null
	fi

	# Prep assets
	cp -R "${deployPath}/html/${HTMLTEMPLATE}/stats/css" "/tmp/stats/"
	cp -R "${deployPath}/html/${HTMLTEMPLATE}/stats/fonts" "/tmp/stats/"
	cp -R "${deployPath}/html/${HTMLTEMPLATE}/stats/js" "/tmp/stats/"

	notice "Generating files..."

	# Attempt to get analytics
	analytics

	# Code stats
	CODE_STATS=$(git log --author="${FULLUSER}" --pretty=tformat: --numstat | \
    awk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf \
    "Total lines of code: %s<br>(+%s added | -%s deleted)\n",loc,add,subs }' -)

  # Get commits
  get_commits 6
  validate_urls "${statFile}"

 	# Process the HTML
	cat "${deployPath}/html/${HTMLTEMPLATE}/stats/index.html" > "${htmlFile}"
	process_html

	cat "${htmlFile}" > "/tmp/stats/index.html"
 	
	# Create the charts
	/usr/bin/gitchart -r "${WORKPATH}/${APP}" authors "/tmp/stats/authors.svg" &>> /dev/null &
	/usr/bin/gitchart -t "" -r "${WORKPATH}/${APP}" commits_day_week "/tmp/stats/commits_day_week.svg" &>> /dev/null &
	/usr/bin/gitchart -t "" -r "${WORKPATH}/${APP}" commits_hour_day "/tmp/stats/commits_hour_day.svg" &>> /dev/null &
	/usr/bin/gitchart -t "" -r "${WORKPATH}/${APP}" commits_hour_week "/tmp/stats/commits_hour_week.svg" &>> /dev/null &
	/usr/bin/gitchart -t "" -r "${WORKPATH}/${APP}" commits_month "/tmp/stats/commits_month.svg" &>> /dev/null &
	/usr/bin/gitchart -t "" -r "${WORKPATH}/${APP}" commits_year "/tmp/stats/commits_year.svg" &>> /dev/null &
	/usr/bin/gitchart -t "" -r "${WORKPATH}/${APP}" commits_year_month "/tmp/stats/commits_year_month.svg" &>> /dev/null &
	/usr/bin/gitchart -t "" -r "${WORKPATH}/${APP}" files_type "/tmp/stats/files_type.svg" &>> /dev/null &
	spinner $!

	# Default chart colors are
	#9999ff #8cedff #b6e354 #feed6c #ff9966 #ff0000 #ff00cc #899ca1 #bf4646

	# Process primary chart color and set permissions if needed
	sleep 1; find "/tmp/stats/" -type f -exec sed -i "s/#9999ff/${PRIMARYC}/g" {} \;
	sleep 1; find "/tmp/stats/" -type f -exec sed -i 's/Consolas,"Liberation Mono",Menlo,Courier,monospace/Roboto, Helvetica, Arial, sans-serif/g' {} \;

	postLog
#   if [[ "${LOCALHOSTPOST}" == "TRUE" ]]; then
#     [[ ! -d "${LOCALHOSTPATH}/${APP}" ]] && mkdir "${LOCALHOSTPATH}/${APP}"
#     [[ ! -d "${LOCALHOSTPATH}/${APP}/stats" ]] && mkdir "${LOCALHOSTPATH}/${APP}/stats"
#     cp -R "/tmp/stats" "${LOCALHOSTPATH}/${APP}"
#     chmod -R a+rw "${deployPath}/html/${HTMLTEMPLATE}/stats" &> /dev/null
#   fi
	fi
}

function check_backup() {
	# Are we setup?
	if [[ -z "${DB_BACKUP_PATH}" ]] || [[ -z "${DB_API_TOKEN}" ]]; then
		return
	else
		
		# Examine the Dropbox backup directory
		curl -s -X POST https://api.dropboxapi.com/2/files/list_folder \
		--header "Authorization: Bearer ${DB_API_TOKEN}" \
		--header "Content-Type: application/json" \
		--data "{\"path\": \"${DB_BACKUP_PATH}\",\"recursive\": false,
			\"include_media_info\": false,\"include_deleted\": false,
			\"include_has_explicit_shared_members\": false}" > "${trshFile}"
		
		# Check for what we might assume is error output
		if [[ $(grep "error" "${trshFile}") ]]; then
			warning "Error in backup configuration"
			return
		fi

		# Start the loop
		for i in $(seq 0 365)
			do 
			var="$(date -d "${i} day ago" +"%Y-%m-%d")"
			if [[ $(grep "${var}" "${trshFile}") ]]; then
				if [[ "${i}" == "0" ]]; then 
					LAST_BACKUP="Today"
					BACKUP_STATUS="${SUCCESSC}"
					BACKUP_BTN="btn-success"
				elif [[ "${i}" == "1" ]]; then
					LAST_BACKUP="Yesterday" 
					BACKUP_STATUS="${SUCCESSC}"
					BACKUP_BTN="btn-success"
				else
					LAST_BACKUP="${i} days ago"
					if [[ "${i}" < "5" ]]; then
						BACKUP_STATUS="${SUCCESSC}"
					elif [[ "${i}" > "4" && "${i}" < "11" ]]; then
						BACKUP_STATUS="${WARNINGC}"
						BACKUP_BTN="btn-warning"
					else
						BACKUP_STATUS="${DANGERC}"
						BACKUP_BTN="btn-danger"
					fi
 
				fi
				trace "Last backup: ${LAST_BACKUP} (${var}) in ${DB_BACKUP_PATH}"
				return
			fi
		done
	fi
}

# Usage: get_commits [number of commits]
function get_commits() {
	git log -n $1 --pretty=format:"%n<table style=\"border-bottom: solid 1px #eeeeee;\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\"><tr><td width=\"90\" valign=\"top\" align=\"left\"><img src=\"{{GRAVATARURL}}/%an.png\" alt=\"%aN\" title=\"%aN\" width=\"64\" style=\"width: 64px; float: left; background-color: #f0f0f0; -webkit-border-radius: 4px; -moz-border-radius: 4px; -ms-border-radius: 4px; -khtml-border-radius: 4px; border-radius: 4px; overflow: hidden; margin-top: 4px;\"></td><td valign=\"top\" style=\"padding-bottom: 20px;\"><strong>%ncommit <a style=\"color: {{PRIMARY}}; text-decoration: none; font-weight: bold;\" href=\"${REMOTEURL}/${APP}/%h.html\">%h</a>%nAuthor: %aN%nDate: %aD (%cr)%n%s</td></tr></table><br>" > "${statFile}"
  sed -i '/^commit/ s/$/ <\/strong><br>/' "${statFile}"
  sed -i '/^Author:/ s/$/ <br>/' "${statFile}"
  sed -i '/^Date:/ s/$/ <br><br>/' "${statFile}"
}

# Usage: url_check [source file]
function validate_urls() {
  grep -oP "(?<=href=\")[^\"]+(?=\")" $1 > "${trshFile}"
  while read URL; do
    CODE=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "$URL")
    if [[ "${CODE}" != "200" ]]; then 
      sed -i "s,${URL},${REMOTEURL}/nolog.html,g" "${statFile}"
    fi
  done < "${trshFile}"
}

