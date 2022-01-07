#/bin/sh
#
#	aard_setup
#
# This script supports the makefiles 'conf' option
SOURCE_WORDLIST='https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt'
SOURCE_EMOJI='http://unicode.org/emoji/charts/full-emoji-list.html'

aard_getfile() {
	if [ "$#" -ne 2 ]; then
		printf 'aard_getfile: Failed to provide two arguments\n'
		exit 1
	fi

	command -v curl > /dev/null 2>&1
	if [ "$?" -eq 0 ]; then
		curl -o "$1" "$2"
		if [ "$?" -ne 0 ]; then
			printf 'Unable to download file\n'
			exit 2
		fi
	else
		command -v wget > /dev/null 2>&1
		if [ "$?" -ne 0 ]; then
			printf 'No file download program found\n'
			exit 3
		fi
		wget -O "$1" "$2"
		if [ "$?" -ne 0 ]; then
			printf 'Unable to download file\n'
			exit 4
		fi
	fi
}

if [ "$#" -ne 1 ]; then
	printf 'This script should only be called through make\n'
	exit 1
fi

if [ ! -r "$1" ]; then
	printf 'Unable to read aard configuration file\n'
	exit 2
fi

. "$1"

aard_getfile "$AARD_DICTIONARY_PATH" "$SOURCE_WORDLIST"
aard_getfile "$AARD_EMOJI_PATH" "$SOURCE_EMOJI"
