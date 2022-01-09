#!/bin/sh
#
#	aard_status-VERSION
#
# This script supports the program 'aard'

printf '%s' "$*" | xsel -i --secondary || exit 1
