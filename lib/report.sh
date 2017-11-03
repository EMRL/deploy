#!/bin/bash
#
# report.sh
#
###############################################################################
# Handles parsing and creating monthly work reports
###############################################################################
trace "Loading report handling"

function createReport() {
  message_state="REPORT"
  htmlDir

  # If there were no commits last month, skip creating the report
  if [[ $(git log --before={'date "+%Y-%m-01"'} --after={'date --date="$(date +%Y-%m) -1 month"') ]]; then
    git log --before={'date "+%Y-%m-01"'} --after={'date --date="$(date +%Y-%m) -1 month"'} --pretty=format:"<tr class=\"item-row\"><td class=\"item-name\">%h</td><td class=\"description\">%s</td></tr>" --since="last month" > "${statFile}"

    # Compile full report 
    cat "${deployPath}/html/${HTMLTEMPLATE}/report/header.html" "${statFile}" "${deployPath}/html/${HTMLTEMPLATE}/report/footer.html" > "${htmlFile}"

    # Filter and replace template variables
    processHTML

    # Get the email payload ready
    # digestSendmail=$(<"${htmlFile}")
  else
    echo "No activity found, canceling report."
    safeExit
  fi
}