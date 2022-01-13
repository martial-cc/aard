#!/bin/sh
#
#	aard_status-VERSION
#
# This script supports the program 'aard'

command -v xsino > /dev/null 2>&1 || exit 1

if [ "$1" == "FAIL" ]; then
	xsino -n > /dev/null 2>&1
fi
if [ "$1" == "SUCCESS" ]; then
	xsino -y > /dev/null 2>&1
fi
