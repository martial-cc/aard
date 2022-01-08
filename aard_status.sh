#!/bin/sh
#
#	aard_status-VERSION
#
# This script supports the program 'aard'

printf '%s' "$*" | xsel -i --secondary
if [ "$?" -ne 0 ]; then
	exit 1
fi
