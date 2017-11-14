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

  # Get the first and last day of last month
  CURMTH="$(date +%m)"
  CURYR="$(date +%Y)"

  if [[ "${CURMTH}" -eq 1 ]]; then
    PRVMTH="12"
    PRVYR=`expr "${CURYR}" - 1`
  else PRVMTH=`expr "${CURMTH}" - 2`
    PRVYR="${CURYR}"
  fi

  if [[ $PRVMTH -lt 10 ]];
    then PRVMTH="0"$PRVMTH
  fi


LASTDY=`cal ${PRVMTH} ${PRVYR} | egrep "28|29|30|31" |tail -1 |awk '{print $NF}'`

  # If there were no commits last month, skip creating the report
#  if [[ $(git log --before={'date "+%Y-%m-01"'} --after={'date --date="$(date +%Y-%m-01) -1 month"') ]]; then
#    git log --before={'date "+%Y-%m-01"'} --after={'date --date="$(date +%Y-%m-01) -1 month"'} --pretty=format:"<tr class=\"item-row\"><td class=\"item-name\">%h</td><td class=\"description\">%s</td></tr>" --since="last month" > "${statFile}"

  if [[ $(git log --before={'date "+%Y-%m-01"'} --after=${PRVYR}-${PRVMTH}-31) ]]; then
    git log --all --no-merges --first-parent --before={'date "+%Y-%m-01"'} --after="${PRVYR}-${PRVMTH}-31 00:00" --pretty=format:"<tr class=\"item-row\"><td class=\"item-name\">%h</td><td class=\"description\">%s</td></tr>" > "${statFile}"

    # Compile full report 
    cat "${deployPath}/html/${HTMLTEMPLATE}/report/header.html" "${statFile}" "${deployPath}/html/${HTMLTEMPLATE}/report/footer.html" > "${htmlFile}"

    # Filter and replace template variables
    processHTML

    # Get the email payload ready
    # digestSendmail=$(<"${htmlFile}")
  else
    echo "No activity found, canceling report."
    quietExit
  fi
}
