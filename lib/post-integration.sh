#!/bin/bash
#
# post-integration.sh
#
# Handles integration with other services
trace "Loading integration services"

# Compile commit message with other stuff for integration
function buildLog() {
	trace "Posting ${TASKLOG}"
	# OK let's grab the short version of the commit hash
	COMMITHASH="$(git rev-parse --short HEAD)"; COMMITURL="${REPOHOST}/${REPO}/commits/${COMMITHASH}"
	echo "<strong>Commit ${COMMITHASH}</strong>: ${notes}" > "${postFile}"
}

function mailPost() {
	echo "${COMMITURL}" >> "${postFile}"
	# Make this better
	# (cat "${postFile}") | mail -r "${USER}@${FROMDOMAIN}" -s "$(echo -e ${SUBJECT} "-" ${APP}"\nContent-Type: text/plain")" "${POSTEMAIL}"
	postSendmail=$(<"${postFile}")
	(
	if [ "$AUTOMATE" = "1" ]; then
		echo "From: ${FROM}"
	else
		echo "From: ${USER}@${FROMDOMAIN}"
	fi
	echo "To: ${POSTEMAIL}"
	echo "Subject: ${SUBJECT} - ${APP}"
	echo "Content-Type: text/html"
	echo
	echo "${postSendmail}";
	) | "${MAILPATH}"/sendmail -t
}

# Post via email
function postCommit() {
	# Check for a Wordpress core update, update production database if needed
	if [ "$UPDCORE" = "1" ]; then
		info "Upgrading production database..."; lynx -dump "${PRODURL}"/system/wp-admin/upgrade.php?step=1 > "${trshFile}"
	fi

	# Just for yuks, display git stats for this user (user can override this if it annoys them)
	gitStats
	# Is Slack integration configured?
	if [ "${POSTTOSLACK}" == "TRUE" ]; then
		trace "Posting to Slack"
		buildLog; slackPost > /dev/null 2>&1
	fi
	# Check to see if there's an email integration setup
	if [[ -z "$POSTEMAIL" ]]; then
		trace "No email integration setup"
	else
		# Is it a valid email address? Ghetto check but better than nothing
		if [[ "$POSTEMAIL" == ?*@?*.?* ]]; then
			trace "Running email integration"
			buildLog; mailPost
		else
			trace "Integration email address ${POSTEMAIL} does not look valid. Check your configuration."
		fi
	fi
}
