#! /bin/bash

# log [level] [message]
#
# log outputs the right message in a common format
log ()
{
	BLURB="$1"
	shift
	case $BLURB in
		error)   >&2 echo "[ERROR] abcde: $@" >&2 ;;
		warning) >&2 echo "[WARNING] $@" >&2 ;;
		info)    >&4 echo "[INFO] $@" ;;
        console) >&4 echo "$@" ;;
	esac
}

# vecho [-c|-n] [message]
#
# vecho outputs a message if EXTRAVERBOSE is 1 or more
# -c is for a continuation line, -n is for no newline
vecho ()
{
if [ x"$EXTRAVERBOSE" != "x" ] && [ "$EXTRAVERBOSE" -gt 0 ] ; then
	case $1 in
		warning) shift ; log warning "$@" ;;
        -c) shift ; >&4 echo              "$@" ;; # for a continuation line
		-n) shift ; >&4 echo -n "[Verbose] $@" ;;
		*)          >&4 echo    "[Verbose] $@" ;;
	esac
fi
}

# vvecho [-c|-n] [message]
#
# vvecho outputs a message if EXTRAVERBOSE is 2 or more
# -c is for a continuation line, -n is for no newline
vvecho ()
{
if [ x"$EXTRAVERBOSE" != "x" ] && [ "$EXTRAVERBOSE" -gt 1 ] ; then
	case $1 in
		warning) shift ; log warning "$@" ;;
		-c) shift ; >&4 echo               "$@" ;; # for a continuation line
		-n) shift ; >&4 echo -n "[Verbose2] $@" ;;
		*)          >&4 echo    "[Verbose2] $@" ;;
	esac
fi
}

exec 4>&1
EXTRAVERBOSE=$1

echo "testing vecho and vvecho functions"
log console "call with a number 1 or 2 to see verbose logging output"
vecho "with newline"
vecho -n "without newline: "
vecho -c "continued on the same line"

vvecho "with newline"
vvecho -n "without newline: "
vvecho -c "continued on the same line"

log console "testing console log -- print without prefix"
log info "testing info log -- print with [INFO] prefix"
