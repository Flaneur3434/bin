#!/bin/sh

inflags=yes
flags="-i"
while [ $# != 0 -a $inflags = yes ]
do
	case "$1" in
	--)
		inflags=no
		shift
		;;
	-*)
		flags="$flags $1"
		shift
		;;
	-)
		inflags=no
		shift
		;;
	*)
		inflags=no
		;;
	esac
done

case $# in
0)
	echo 1>&2 'usage: g [flags] pattern [files]'
	exit 1
	;;
1)
	pattern="$1"
	9 ls * | 9 grep $flags -- "$pattern"
	;;
*)
	pattern="$1"
	shift
	files="$@"
esac

exec 9 grep -n $flags -- "$pattern" $files /dev/null
