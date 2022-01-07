#/bin/sh
#
#	aard_report-VERSION
#
# This script supports the program 'aard'

printf '%s' "$*" | xsel -i --primary
if [ "$?" -ne 0 ]; then
	exit 1
fi
