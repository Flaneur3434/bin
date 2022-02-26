#!/bin/bash

# PLUMBFILE=$HOME/lib/plumbing
export SHELL=$PLAN9/bin/rc
export acmeshell=$PLAN9/bin/rc
export TERM=dumb
export PAGER=nobs
export BROWSER=chrome
export tabstop=4

font='/mnt/font/GoMono/10a/font'
# font='/mnt/font/LucidaGrande/16a/font'

if [ -z "$(pgrep fontsrv)" ]; then
	 echo "run fontsrv"
	 fontsrv &
fi

# [ -z "$(pgrep plumber)" ] && plumber &

# if [ -f "$PLUMBFILE" ]; then
# 	cat "$PLUMBFILE" | 9p write plumb/rules
# else
# 	cat $PLAN9/plumb/basic | 9p write plumb/rules
# fi

acme -a -f $font $1
