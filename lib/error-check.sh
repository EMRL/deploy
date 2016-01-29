#!/bin/bash
#
# errorChk()
#
# Handles various exit code checking
trace "Loading errorChk()"

# Try to get exit/error code
function errorChk() {
	EXITCODE=$?; 
	if
		[[ $EXITCODE == 0 ]]; then 
		trace "OK"; console "Success."
	else
		trace "FAIL"; warning "Exiting on error code" $EXITCODE
		errorExit
	fi
}