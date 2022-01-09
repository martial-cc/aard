#!/bin/sh
#
#	aard-VERSION
#
# MIT/X Consortium License
#
# © 2021-2022 Carl H. Henriksson <aard at martial dot cc>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

AARD_OPTION="\
-		populate <buffer> with data read from standard input
base64		encode the data in <buffer> to base64
clean		clean up the data in <buffer>
clear		remove all data in <buffer>
define		fetch definition of grammatical unit in <buffer>
edit		edit the data in <buffer> with a text editor
emoji		select and emoji and load it into <buffer>
fetch		load filesystem, log, or shell history entity into <buffer>
file		read the file data from path in <buffer>
help		list all options and select one for execution
host		select and load ip from the system hosts into <buffer>
html		load source from url to <buffer>
htmlx		dump render from url to <buffer>
image		open the <buffer> as an image file
light		set X backlight to percent integer value in <buffer>
log		timestamp and append the <buffer> to the log file
media 		open the <buffer> as a media file
option		input options and execute them
paste		write the <buffer> to standard output
pdf		create a pdf with the data in <buffer>
post		input and add postfix to <buffer>
pre		input and add prefix to <buffer>
qr		create a QR code png with the data in <buffer>
random		load random ascii encoded hex into <buffer>
report		pass the <buffer> to the report system
run		input and execute commands in <buffer> loading output to <buffer>
select		isolate one line in the <buffer>
set		set <buffer>
tty		open terminal
url		isolate and select an url in <buffer>
word		select dictionary word and load it into <buffer>
x		execute <buffer> as command loading output to <buffer>
yt		search and select youtube video url"

# Error and system interface

aard_log() {
	printf '%s %s\n' "$(aard_date)" "$(cat "$AARD_BUFFER")" >> "$AARD_LOG_PATH" \
		|| aard_quit 1 'aard_log: Failed to write log'
}

aard_msg() {
	aard_report_set "$(aard_date) aard: $*" || exit 1
}

aard_quit() {
	if [ $# -eq 2 ]; then
		aard_msg "$2"
	fi

	aard_status_set 'FAIL'
	AARD_QUIT_RETURN='1'

	if [ $# -eq 1 ]; then
		AARD_QUIT_RETURN="$1"
	fi

	aard_post

	exit "$AARD_QUIT_RETURN"
}

aard_report_set() {
	if [ -z "$AARD_X_REPORT" ]; then
		return 0
	fi

	command -v aard_report > /dev/null 2>&1 || return 1
	aard_report "$*"
}

aard_status_set() {
	if [ -z "$AARD_X_STATUS" ]; then
		return 0
	fi

	command -v aard_status > /dev/null 2>&1 || return 1
	aard_status "$*"
}

# Utilities

aard_date() {
	date +"$AARD_DATE_FORMAT" 2> /dev/null || aard_quit 1 'aard_date: Failed to get date'
}

# Clipboard

aard_clip_get() {
	eval " $AARD_CLIP_GET" 2> /dev/null || aard_quit 1 'aard_clip_get: Failed to read clipboard'
}

aard_clip_set() {
	eval " $AARD_CLIP_SET" 2> /dev/null || aard_quit 1 'aard_clip_set: Failed to write clipboard'
}

# Etc

aard_prompt() {
	if [ -z "$AARD_PROMPT" ]; then
		aard_quit 1 'aard_prompt: Failed to read variable: AARD_PROMPT'
	fi

	if [ $# -ne 1 ]; then
		AARD_PROMPT_MSG='aard:'
	else
		AARD_PROMPT_MSG="$1"
	fi

	AARD_PROMPT_CMD="$AARD_PROMPT \"$AARD_PROMPT_MSG\""

	eval " $AARD_PROMPT_CMD" 2> /dev/null || aard_quit 2 'aard_prompt: Failed to open prompt'
}

aard_select() {
	aard_prompt 'aard select:' || aard_quit 1 'aard_select: Failed to select line'
}

# Main

aard_arg() {
	if [ $# -eq 0 ]; then
		printf 'aard: No arguments provided\n'
		exit 1
	fi

	case "$1" in
	--help)
		printf '%s\n' 'usage: aard [-v] [option ...]'
		;;
	-v)
		printf '%s\n' 'aard-VERSION'
		;;
	*)
		return
		;;
	esac

	exit 0
}

aard_iterate() {
	for option in "$@"; do
		aard_process "$option"
	done
}

aard_process() {
	if [ $# -ne 1 ]; then
		aard_quit 1 'aard_process: Failed to provide valid argument amount'
	fi

	aard_status_set 'PROCESSING'

	case "$1" in
	-)
		cat - > "$AARD_BUFFER"
		;;
	base64)
		command -v b64encode > /dev/null 2>&1 \
			|| aard_quit 1 'aard_process base64: Failed to find program: b64encode'

		b64encode aard < "$AARD_BUFFER" > "$AARD_FILE" 2> /dev/null \
			|| aard_quit 2 'aard_process base64: Failed to encode base64'

		cat "$AARD_FILE" > "$AARD_BUFFER"
		;;
	clean)
		AARD_CLEAN_WHITESPACE="$(awk '$1=$1' "$AARD_BUFFER" 2> /dev/null \
			|| aard_quit 1 'aard_process clean: Failed to clean whitespace')"

		printf '%s' "$AARD_CLEAN_WHITESPACE" | tr -d '\n' > "$AARD_BUFFER" 2> /dev/null \
			|| aard_quit 2 'aard_process clean: Failed to clean newline'
		;;
	clear)
		printf '' > "$AARD_BUFFER"
		;;
	define)
		command -v w3m > /dev/null 2>&1 || aard_quit 1 'aard_process define: Failed to find program: w3m'

		AARD_DEFINE_WORD="$(cat "$AARD_BUFFER")"
		AARD_DEFINE_URL="http://merriam-webster.com/dictionary/$AARD_DEFINE_WORD"

		w3m -config /dev/null -T html/text "$AARD_DEFINE_URL" > "$AARD_FILE" 2> /dev/null \
			|| aard_quit 2 'aard_process define: Failed to fetch html'

		AARD_FORMAT="$(awk '/Definition of/,/Synonyms for*/;/Synonyms for/{exit}' "$AARD_FILE" 2> /dev/null \
			|| aard_quit 3 'aard_process define: Failed to format html')"

		AARD_CLEAN="$(printf '%s' "$AARD_FORMAT" | sed '$d' 2> /dev/null \
			|| aard_quit 4 'aard_process define: Failed to clean data')"

		printf '%s %s\n' "$AARD_DEFINE_WORD" "$AARD_CLEAN" > "$AARD_BUFFER"

		if [ -n "$AARD_X_DEFINEPDF" ]; then
			aard_process 'pdf'
		fi
		;;
	edit)
		cat "$AARD_BUFFER" > "$AARD_FILE"

		eval " $AARD_EDITOR $AARD_FILE" 2> /dev/null \
			|| aard_quit 1 'aard_process edit: Failed to edit temporary file'

		cat "$AARD_FILE" > "$AARD_BUFFER"
		;;
	emoji)
		if [ -z "$AARD_EMOJI_PATH" ]; then
			aard_quit 1 'aard_process emoji: Failed to read variable: AARD_EMOJI_PATH'
		fi

		awk -F'<[^>]*>' '
			NR>25 && NR<31506 && /chars/ && length($2) > 1 {
				printf $2 "\t\t"
			} /class=\047name/ {
				gsub(/\&amp;/, "and");
				if (length($5) < 7)
					print $2;
					else print $5
			}' OFS='' "$AARD_EMOJI_PATH" > "$AARD_FILE" 2> /dev/null \
			|| aard_quit 2 'aard_process emoji: Failed to format emoji list'

		AARD_EMOJI_CHOSEN="$(expand "$AARD_FILE" | aard_select 'aard emoji')"

		AARD_EMOJI_ISOLATED="$(printf '%s' "$AARD_EMOJI_CHOSEN" | awk -F' ' '{print $1}' 2> /dev/null \
			|| aard_quit 3 'aard_process emoji: Failed to isolate emoji')"

		printf '%s' "$AARD_EMOJI_ISOLATED" > "$AARD_BUFFER"
		;;
	fetch)
		find "$HOME" > "$AARD_FILE" 2> /dev/null

		if [ -n "$AARD_HISTORY_PATH" ]; then
			tail -r "$AARD_HISTORY_PATH" >> "$AARD_FILE" 2> /dev/null
		fi

		if [ -n "$AARD_LOG_PATH" ]; then
			tail -r "$AARD_LOG_PATH" >> "$AARD_FILE" 2> /dev/null
		fi

		aard_select 'aard fetch' > "$AARD_BUFFER" < "$AARD_FILE"
		;;
	file)
		AARD_FILENAME="$(cat "$AARD_BUFFER")"
		if [ ! -r "$AARD_FILENAME" ]; then
			aard_quit 1 'aard_process file: Failed to read file'
		fi
		cat "$AARD_FILENAME" > "$AARD_BUFFER"
		;;
	help)
		printf '%s' "$AARD_OPTION" | expand > "$AARD_FILE" 2> /dev/null \
			|| aard_quit 1 'aard_process help: Failed to expand help'

		AARD_HELP_SELECTION="$(aard_select 'aard help' < "$AARD_FILE" | awk '{print $1}' 2> /dev/null \
			|| aard_quit 2 'aard_process help: Failed to read selection')"

		aard_process "$AARD_HELP_SELECTION"
		;;
	host)
		AARD_HOST_EXPANDED="$(expand /etc/hosts 2> /dev/null | aard_select 'aard host' \
			|| aard_quit 1 'aard_process host: Failed to expand selection')"

		AARD_HOST_SELECTION="$(printf '%s' "$AARD_HOST_EXPANDED" | awk '{print $1}' 2> /dev/null \
			|| aard_quit 2 'aard_process host: Failed to isolate selection')"

		printf '%s' "$AARD_HOST_SELECTION" > "$AARD_BUFFER"
		;;
	html)
		command -v w3m > /dev/null 2>&1 || aard_quit 1 'aard_process html: Failed to find program: w3m'

		w3m -config /dev/null -dump_source "$(cat "$AARD_BUFFER")" > "$AARD_FILE" 2> /dev/null \
			|| aard_quit 2 'aard_process html: Failed to fetch html'

		cat "$AARD_FILE" > "$AARD_BUFFER"
		;;
	htmlx)
		command -v w3m > /dev/null 2>&1 || aard_quit 1 'aard_process htmlx: Failed to find program: w3m'

		w3m -config /dev/null -T html/text "$(cat "$AARD_BUFFER")" > "$AARD_FILE" 2> /dev/null \
			|| aard_quit 2 'aard_process htmlx: Failed to fetch html'

		cat "$AARD_FILE" > "$AARD_BUFFER"
		;;
	image)
		if [ -z "$AARD_IMAGE" ]; then
			aard_quit 1 'aard_process image: Failed to read variable: AARD_IMAGE'
		fi

		eval " $AARD_IMAGE $(cat "$AARD_BUFFER")" 2> /dev/null \
			|| aard_quit 2 'aard_process image: Failed to show image'
		;;
	light)
		command -v xbacklight > /dev/null 2>&1 \
			|| aard_quit 1 'aard_process light: Failed to find program: xbacklight'

		xbacklight -set "$(cat "$AARD_BUFFER")" 2> /dev/null \
			|| aard_quit 2 'aard_process light: Failed to set light'
		;;
	log)
		aard_log
		;;
	media)
		if [ -z "$AARD_MEDIA" ]; then
			aard_quit 1 'aard_process media: Failed to read variable: AARD_MEDIA'
		fi

		aard_log
		AARD_TARGET="$(cat "$AARD_BUFFER")"

		eval " $AARD_MEDIA $AARD_TARGET" 2> /dev/null \
			|| aard_quit 2 'aard_process media: Failed to play media'
		;;
	option)
		aard_iterate $(printf '' | aard_prompt 'aard option:')
		;;
	paste)
		cat "$AARD_BUFFER"
		;;
	pdf)
		command -v enscript > /dev/null 2>&1 \
			|| aard_quit 1 'aard_process pdf: Failed to find program: enscript'

		command -v ps2pdf > /dev/null 2>&1 \
			|| aard_quit 2 'aard_process pdf: Failed to find program: ps2pdf'

		if [ -z "$AARD_PDF" ]; then
			aard_quit 3 'aard_process pdf: Failed to read variable: AARD_PDF'
		fi

		if [ -z "$AARD_PDF_PATH" ]; then
			aard_quit 4 'aard_process pdf: Failed to read variable: AARD_PDF_PATH'
		fi

		enscript -p - > "$AARD_FILE" 2> /dev/null < "$AARD_BUFFER" \
			|| aard_quit 5 'aard_process pdf: Failed to generate postscript'

		ps2pdf "$AARD_FILE" "$AARD_PDF_PATH" 2> /dev/null \
			|| aard_quit 6 'aard_process pdf: Failed to generate pdf'

		printf '%s' "$AARD_PDF_PATH" > "$AARD_BUFFER"

		if [ -n "$AARD_X_PDFSHOW" ]; then
			AARD_TARGET="$(cat "$AARD_BUFFER")"

			eval " $AARD_PDF $AARD_TARGET" 2> /dev/null \
				|| aard_quit 7 'aard_process pdf: Failed to show pdf'
		fi
		;;
	post)
		AARD_POSTFIX="$(printf '' | aard_prompt 'post:' \
			|| aard_quit 1 'aard_process post: Failed to read user input')"

		printf '%s%s' "$(cat "$AARD_BUFFER")" "$AARD_POSTFIX" > "$AARD_BUFFER"
		;;
	pre)
		AARD_PREFIX="$(printf '' | aard_prompt 'pre:' \
			|| aard_quit 1 'aard_process pre: Failed to read user input')"

		printf '%s%s' "$AARD_PREFIX" "$(cat "$AARD_BUFFER")" > "$AARD_BUFFER"
		;;
	qr)
		command -v qrencode > /dev/null 2>&1 \
			|| aard_quit 1 'aard_process qr: Failed to find program: qrencode'

		if [ -z "$AARD_QR_PATH" ]; then
			aard_quit 2 'aard_process qr: Failed to read variable: AARD_QR_PATH'
		fi

		qrencode -s 24 -o "$AARD_QR_PATH" 2> /dev/null < "$AARD_BUFFER" \
			|| aard_quit 3 'aard_process qr: Failed to generate QR'

		printf '%s' "$AARD_QR_PATH" > "$AARD_BUFFER"

		aard_process image
		;;
	random)
		command -v w3m > /dev/null 2>&1 \
			|| aard_quit 1 'aard_process random: Failed to find program: w3m'

		w3m -dump_source 'http://random.org/cgi-bin/randbyte?nbytes=4' > "$AARD_FILE" 2> /dev/null \
			|| aard_quit 2 'aard_process random: Failed to fetch html'

		AARD_RANDOM_ISOLATED="$(hexdump -n 8 -e '2/4 "%08X"' "$AARD_FILE" 2> /dev/null \
			|| aard_quit 3 'aard_process random: Failed to format hex')"

		printf '%s' "$AARD_RANDOM_ISOLATED" > "$AARD_BUFFER"

		aard_process clean
		;;
	report)
		aard_report_set "$(cat "$AARD_BUFFER")" \
			|| aard_quit 1 'aard_process report: Failed to report'
		;;
	run)
		aard_iterate 'set' 'x'
		;;
	select)
		aard_select 'aard select' > "$AARD_FILE" < "$AARD_BUFFER"
		cat "$AARD_FILE" > "$AARD_BUFFER"
		;;
	set)
		AARD_SET_INPUT="$(printf '' | aard_prompt 'aard set:' \
			|| aard_quit 1 'aard_process set: Failed to read user input')"

		printf '%s' "$AARD_SET_INPUT" > "$AARD_BUFFER"
		;;
	tty)
		if [ -z "$AARD_TTY" ]; then
			aard_quit 1 'aard_process tty: Failed to read variable: AARD_TTY'
		fi

		eval " $AARD_TTY" 2> /dev/null \
			|| aard_quit 2 'aard_process tty: Failed to open terminal'
		;;
	url)
		command -v urlisolator > /dev/null 2>&1 \
			|| aard_quit 1 'aard_process url: Failed to find program: urlisolator'

		urlisolator > "$AARD_FILE" 2> /dev/null < "$AARD_BUFFER" \
			|| aard_quit 2 'aard_process url: Failed to isolate url'

		aard_select 'aard url' > "$AARD_BUFFER" < "$AARD_FILE"
		;;
	word)
		if [ -z "$AARD_DICTIONARY_PATH" ]; then
			aard_quit 1 'aard_process word: Failed to read variable: AARD_DICTIONARY_PATH'
		fi

		tr -d '\r' < "$AARD_DICTIONARY_PATH" > "$AARD_FILE" 2> /dev/null \
			|| aard_quit 2 'aard_process word: Failed to fix newline'

		aard_select 'aard word' > "$AARD_BUFFER" < "$AARD_FILE"
		;;
	x)
		cat "$AARD_BUFFER" > "$AARD_FILE"

		chmod +x "$AARD_FILE" 2> /dev/null \
			|| aard_quit 1 'aard_process x: Failed to change file permissions'

		AARD_X_OUTPUT="$(sh "$AARD_FILE" 2>&1)"

		printf '%s' "$AARD_X_OUTPUT" > "$AARD_BUFFER"
		;;
	yt)
		command -v yt-dlp > /dev/null 2>&1 \
			|| aard_quit 1 'aard_process yt: Failed to find program: yt-dlp'

		yt-dlp -j "ytsearch16:$(cat "$AARD_BUFFER")" > "$AARD_FILE" 2> /dev/null \
			|| aard_quit 2 'aard_process yt: Failed to find URLs'

		AARD_YT_SEARCH="$(awk -F'"' '{print $4, $8}' "$AARD_FILE" 2> /dev/null)" \
			|| aard_quit 3 'aard_process yt: Failed to format URLs'

		AARD_YT_URL="$(printf '%s' "$AARD_YT_SEARCH" | aard_select 'aard yt' \
		| awk '{print "http://youtube.com/watch?v=" $1}' 2> /dev/null \
			|| aard_quit 4 'aard_process yt: Failed to format URL')"

		printf '%s' "$AARD_YT_URL" > "$AARD_BUFFER"

		aard_log
		;;
	*)
		aard_quit 1 "aard_process *: Failed to identify argument; $*"
		;;
	esac

	aard_status_set 'SUCCESS'
}

aard_post() {
	rm "$AARD_BUFFER" 2> /dev/null
	rm "$AARD_FILE" 2> /dev/null
}

aard_pre() {
	# Configuration
	if [ -z "$AARD_CONF" ]; then
		# This variable is defined in the Makefile
		AARD_CONF="MAKECONFROOT/aard.conf"
		if [ -z "$AARD_CONF" ]; then
			aard_quit 1 'aard_run: Failed to find configuration file'
		fi
	fi

	if [ ! -r "$AARD_CONF" ]; then
		aard_quit 2 'aard_run: Failed to read file'
	fi

	. "$AARD_CONF"

	# Files
	AARD_BUFFER="$(mktemp -t aard."$$".XXXXXXXX 2> /dev/null \
		|| aard_quit 3 'aard_run: Failed to create buffer file')"
	AARD_FILE="$(mktemp -t aard."$$".XXXXXXXX 2> /dev/null \
		|| aard_quit 4 'aard_run: Failed to create temporary file')"
}

aard_run() {
	aard_arg "$@"
	aard_pre

	aard_clip_get > "$AARD_BUFFER"
	aard_iterate "$@"
	if [ -n "$AARD_X_CLIPBOARD" ]; then
		aard_clip_set < "$AARD_BUFFER"
	fi

	aard_post
}

aard_run "$@"
