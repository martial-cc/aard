#!/bin/sh
#
#	aard_report-VERSION
#
# This script supports the program 'aard'

pgrep 'dwm' > /dev/null 2>&1 || exit 1

xsetroot -name "$*" > /dev/null 2>&1
