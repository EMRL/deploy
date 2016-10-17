#!/bin/bash
#
# log-handling.sh
#
# Handles parsing and creating logs
trace "Loading log handling"

# Log via email, needs work
function makeLog {

	# Filter raw log output as configured by user
	if [ "${NOPHP}" == "TRUE" ]; then
		grep -vE "(PHP |Notice:|Warning:|Strict Standards:)" "${logFile}" > "${postFile}"
		cat "${postFile}" > "${logFile}"
	fi

	# Start compiling HTML files if needed
	if [ "${EMAILHTML}" == "TRUE" ] || [ "${REMOTELOG}" == "TRUE" ] || [ "${NOTIFYCLIENT}" == "TRUE" ]; then
		echo "<!--// VARIABLE INPUT //--><p style=\"font-family: Arial, sans-serif; font-style: normal; font-weight: 400; color: #000;\"><strong>Date:</strong> ${NOW}<br /><strong>Project:</strong> ${PROJNAME} (${PROJCLIENT})" > "${trshFile}"

		# If this is a website, display the production URL, otherwise skip it
		if [ -n "${PRODURL}" ]; then
			echo "<br /><strong>Production URL:</strong> <a style=\"color: #47ACDF; text-decoration:none; font-weight: bold;\" href=\"${PRODURL}\">${PRODURL}</a>" >> "${trshFile}"
		fi
		echo "</p><table style=\"background-color: " >> "${trshFile}"

		# Hopefully clients don't see errors, but if they do, change header color
		if [ "${message_state}" == "ERROR" ]; then
			echo "#CC2233" >> "${trshFile}"
			COMMITURL="#"
		else
			echo "#47ACDF" >> "${trshFile}"
		fi

		echo ";\" border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" height=\"60\"><tr><td width=\"82\" height=\"82\" style=\"padding-left:20px;\"><div style=\"width: 60px; height: 60px; position: relative; overflow: hidden; -webkit-border-radius: 50%; -moz-border-radius: 50%; -ms-border-radius: 50%; -o-border-radius: 50%; border-radius: 50%;\"><img style=\"display: inline; margin: 0 auto; height: 100%; width: auto;\"" >> "${trshFile}"

		# Check for a client logo
		if [ -n "${CLIENTLOGO}" ]; then
			echo "src=\"${CLIENTLOGO}\"" >> "${trshFile}"
		else
			echo "src=\"https://guestreviewsystem.com/themes/hrs/images/no_logo.gif\"" >> "${trshFile}"
		fi
		echo "alt=\"${PROJNAME}\" title=\"${PROJNAME}\" /></div></td><td><a href=\"${COMMITURL}\" style=\"font-family: Arial, sans-serif; font-style: normal; font-weight: 700; color: #fff; text-decoration: none;\">" >> "${trshFile}"
		
		# Oh geez, more errors
		if [ "${message_state}" == "ERROR" ]; then
			echo "DEPLOYMENT ERROR" >> "${trshFile}"
			notes="${error_msg}"
		else
			echo "Commit #${COMMITHASH}" >> "${trshFile}"
		fi

		echo "</a></td><td align=\"right\" style=\"padding-right: 20px;\">" >> "${trshFile}"

		# Is there a full log posted to the web? If so, include a link
		if [ "${REMOTELOG}" == "TRUE" ] && [ -n "${REMOTEURL}" ]; then
			echo "<a href=\"${REMOTEURL}/${APP}.html\"><img src=\"http://emrl.co/assets/img/open.png\" height=\"32\" width=\"32\" alt=\"Open Details\" title=\"Open Details\" /></a>" >> "${trshFile}"
		fi

		echo "</td></tr><tr><td colspan=\"3\" valign=\"middle\" style=\"background-color: #eee; padding: 20px;\"><p style=\"font-family: Arial, sans-serif; font-style: normal; font-weight: 400; color: #000;\"><strong>Message:</strong> ${notes}</p>" >> "${trshFile}" >> "${trshFile}"

		# Include a "reply" link if there's a task integration for this project
		if [ -n "${POSTEMAILHEAD}" ] || [ -n "${TASK}" ] || [ -n "${POSTEMAILTAIL}" ]; then
			echo "<p style=\"font-family: Arial, sans-serif; font-style: normal; color: #000;\">If you have any comments or questions, <a style=\"color: #47ACDF; text-decoration:none;\" href=\"mailto: ${POSTEMAILHEAD}${TASK}${POSTEMAILTAIL}?subject=Question%20on%20deployment%20${COMMITHASH}\">send them over</a>.</p>" >> "${trshFile}"
		fi
		echo "</td></tr></table>" >> "${trshFile}" 	# Close the report table

		# Compile short client email
		if [ "${NOTIFYCLIENT}" == "TRUE" ]; then
			if [ "${AUTOMATEDONLY}" == "TRUE" ] && [ "${AUTOMATE}" != "1" ]; then
				trace "Skipping client notification"
			else
				cat "${deployPath}/html/emrl/head.html" "${trshFile}" "${deployPath}/html/emrl/foot.html" > "${clientEmail}"
				# Email to client
				mail -s "$(echo -e "${SUBJECT} - ${APP}\nMIME-Version: 1.0\nContent-Type: text/html")" "${CLIENTEMAIL}" < "${clientEmail}"
			fi
		fi
	fi

	# Remote log function 
	if [ "${REMOTELOG}" == "TRUE" ]; then
		# Compile the head, log information, and footer into a single html file
		cat "${deployPath}/html/emrl/head.html" "${trshFile}" "${logFile}" "${deployPath}/html/emrl/foot.html" > "${htmlEmail}"
		trace "Posting logs to remote server"
		# scp "${htmlFile}" emrl@web521.webfaction.com:/home/emrl/webapps/emrl/current/public/deploy/
		# Copy to home directory to help with debugging
		if [ "${POSTTOLOCALHOST}" == "TRUE" ]; then
			cp "${htmlFile}" "${LOCALHOSTPATH}"
		fi
	fi
}

function mailLog {
	if [ "${EMAILHTML}" == "TRUE" ]; then
		# Compile full log information into a single html file
		cat "${deployPath}/html/emrl/head.html" "${trshFile}" > "${htmlEmail}"
		echo "<pre style=\"font: 100% courier,monospace; border: 1px solid #ccc; overflow: auto; overflow-x: scroll; width: 540px; padding: 0 1em 1em 1em; background: #eee; color: #000;\"><code style=\"font-size: 80%; word-wrap:break-word;\">" >> "${htmlEmail}"
		cat "${logFile}" >> "${htmlEmail}"
		echo "</code></pre>" >> "${htmlEmail}"
		cat "${deployPath}/html/emrl/foot.html" >> "${htmlEmail}"
		# This is just to help debugging
		cp "${htmlEmail}" ~/"${APP}".html
		mail -s "$(echo -e "${SUBJECT} - ${APP}""\n"MIME-Version: 1.0"\n"Content-Type: text/html)" "${TO}" < "${htmlEmail}"
	else
		mail -s "$(echo -e "${SUBJECT} - ${APP}""\n"Content-Type: text/plain)" "${TO}" < "${logFile}"
	fi
}