#!/bin/sh
#
#	aard_report-VERSION
#
# This script supports the program 'aard'

printf '%s' "$*" | xsel -i --primary || exit 1
