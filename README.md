# aard - modular action interface

The aard utility facilitates the execution of arbitrary actions in X.
Enabling the user to execute multiple functions in series, aard
provides a modular interface to action composition.

Through the utilization of a user prompt and the X clipboard,
the user can request information, modify data, and run programs.

Installation instructions
-------------------------

aard is written in sh (Bourne shell), needless of compilation.
Though the program is developed in OpenBSD, any X oriented
POSIX/Unix-like system should be compatible.

While the core functionality depends on few external programs,
most dependencies are optional.
The core dependencies can also be replaced with the users preferred tools,
allowing for a smaller footprint yet.
[See configuration file](aard.conf.example)

To download the dictionary and emoji list files, one of the following programs
must be available in the system:

```sh
curl
wget
```

To install and configure the program:

	$ sudo make install && make conf

Every other user wanting to run the program, must configure it themselves:

	$ make conf

Dependencies
------------

To make use of a default aard configuration, the following
programs must be available in the system:

```sh
xsel		# X clipboard interface
dmenu		# prompt and launcher
```

To utilize the full functionality of a default aard configuration, the following
programs should be available (note that many of these can be replaced
with equivalent programs in the configuration file):

```sh
b64encode
dmenu
enscript
mpv
mupdf
ps2pdf
qrencode
sxiv
urlisolator		# the user must roll their own
w3m
xbacklight
yt-dlp
```

Documentation
-------------

End user documentation can be found in the [`aard(1)` manual page](aard.1).

Configuration
-------------

aard has a system for elaborate error reporting, and a system for simple status reporting.
Included in the installation are example scripts demonstrating simple usage of those two
systems.
The user is encouraged to modify these scripts to fit their particular environment, so that aard
can be deeper integrated into their systems as an assistant.
The two example scripts will use the X primary selection for reporting,
and the X secondary selection for status.
Note that these operations will overwrite the X primary and secondary selection;
disable these systems through the configuration file if that behaviour is unwanted.

Involvement
-----------

All communication can be directed to aard at martial dot cc

Usage examples
--------

```sh
# List all options, allowing the user to select one and run aard with that option
aard help

# bookmark keeper: create bookmark after adding comment
aard postfix log

# bookmark keeper: find bookmark and load it to clipboard
aard fetch

# find file, select line from it, and copy that line into clipboard
aard fetch file select

# input percentage, and set laptop backlight to that percentage
aard set light

# input search term, search youtube, select one video, and play it
aard set yt media

# find and select emoji based on keywords, and copy it to clipboard
aard emoji

# encode data in clipboard to QR code file, and show it
aard qr

# edit the clipboard contents in a text editor
aard edit

# fetch true random data online, and copy it to clipboard
aard random

# find spelling of a word, and request the definition of that word online.
aard word define

# fetch command from shell history, edit it, then execute it (the edit option must be executed from a terminal)
aard fetch edit x
```
