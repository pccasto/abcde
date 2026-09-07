#! /bin/bash



# CDDB
# Currently three supported options ("musicbrainz", "cddb" for gnudb.org and "cdtext")
CDDBMETHOD=musicbrainz
CDDBURL="http://gnudb.gnudb.org/~cddb/cddb.cgi"
CDDBSUBMIT=submit@gnudb.org
CDDBPROTO=6
HELLOINFO="$(whoami)@$(hostname)"
CDDBCOPYLOCAL="n"
CDDBLOCALPOLICY="always"
CDDBLOCALRECURSIVE="y"
CDDBLOCALDIR="$HOME/.cddb"
CDDBUSELOCAL="n"

# List of fields we parse and show during the CDDB parsing...
SHOWCDDBFIELDS="year,genre"


INTERACTIVE=n

# flac
FLAC=flac

EJECT=eject

MKCUE=mkcue


# flac
# The flac option is a workaround for an error where flac fails
# to encode with error 'floating point exception'. This is flac 
# error in get_console_width(), corrected in flac 1.3.1
FLACOPTS="--silent"
FLACGAINOPTS="--add-replay-gain"

# Defaults for album art downloads
ALBUMARTFILE="cover.jpg"
ALBUMARTDIR="${HOME}"
ALBUMARTTYPE="JPEG"
ALBUMARTALWAYSCONVERT="n"


HTTPGET=wget

MUSICBRAINZ=abcde-musicbrainz-tool

CDDBAVAIL=y

# Load user preference defaults
if [ -r "$HOME/.abcde.conf" ]; then
	. "$HOME/.abcde.conf"
fi


if [ "$HTTPGETOPTS" = "" ] ; then
	case $HTTPGET in
		wget) HTTPGETOPTS="-q -nv -e timestamping=off -O -";;
		curl) HTTPGETOPTS="-f -s -L";;
		fetch)HTTPGETOPTS="-q -o -";;
		ftp)  HTTPGETOPTS="-a -V -o - ";;
		*) log warning "HTTPGET in non-standard and HTTPGETOPTS are not defined." ;;
	esac
fi


CDROMREADER="$CDPARANOIA"
CDROMREADEROPTS="$CDPARANOIAOPTS"

FLACENCODEROPTSCLI="$( echo $OUTPUT | cut -d: -f2- )" 

[ "$FLACENCODERSYNTAX" = "default" ] && FLACENCODERSYNTAX=flac
[ "$DOTAG" = "y" ] && NEEDMETAFLAC=y
[ "$DOREPLAYGAIN" = "y" ] && NEEDMETAFLAC=y
[ "$ONETRACK" = "y" ] && [ "$DOCUE" = "y" ] && NEEDMETAFLAC=y
[ "$EMBEDALBUMART" = "y" ] && NEEDMETAFLAC=y

# Options for mkcue
case "$CUEREADERSYNTAX" in
	default|mkcue)
		CUEREADEROPTS="${CDROM}"
		CUEREADER="$MKCUE"
		;;
	abcde.mkcue)
		CUEREADEROPTS="$MKCUEOPTS ${CDROM}"
		CUEREADER="$MKCUE"
		;;
esac



export WAVOUTPUTDIR=/tmp/ramdisk/waves
export VERSION=2.12.3
export CDROMREADERSYNTAX=cdparanoia
export CDPARANOIA=cdparanoia
export CDROMREADER="$CDPARANOIA"
export CDROMREADEROPTS="$CDPARANOIAOPTS"
export EXTRAVERBOSE=2
export CDROM=/dev/sr0
export ONETRACK=y
CDDBMETHOD=musicbrainz
export ONETRACKOUTPUTFORMAT='${ARTISTFILE} - (${YEAR}) ${ALBUMFILE} - ${GENRE}'
CUEREADER=mkcue
DOCUE=y ; MAKECUEFILE=y

exec 4>&1

PF_HOME=~paul/git/bash-tools

source $PF_HOME/inspect-functions.sh
source <($PF_HOME/pull-functions.sh mungetrackname mungefilename mungeartistname mungealbumname mungegenre mungecddb checkstatus vecho vvecho log)
source <($PF_HOME/pull-functions.sh decorate  makeids get_first get_last do_musicbrainz_read)
source <($PF_HOME/pull-functions.sh instrument do_musicbrainz_read getcddbinfo splitvarious)
source <($PF_HOME/pull-functions.sh inspect do_discid do_cddbedit do_cleancue getcddbinfo)



# # rewrite the functions !!!
# source instrumentation.sh
# don't need to source the functions that are not being decorated, instrumented or inspected when this code is added to abcde.
# source <(./pull-functions.sh decorate  makeids get_first get_last)
# source <(./pull-functions.sh instrument do_musicbrainz_read getcddbinfo splitvarious)
# source <(./pull-functions.sh inspect do_discid do_cddbedit do_cleancue getcddbinfo) # the inspect doesn't seem to work with getcddbinfo...


read -p "starting - Press [Enter] key to continue..."
do_discid
rm "${ABCDETEMPDIR}/cue*.out"
#read -p "discid finished Press [Enter] key to continue..."

sed -i -E 's/^.*cue.*$//' "${ABCDETEMPDIR}/status"
sed -i -E 's/^.*cddb.*$//' "${ABCDETEMPDIR}/status"
#read -p "status reset Press [Enter] key to continue..."
					
do_cddbedit
cat $ABCDETEMPDIR/cue*
#read -p "cddbedit finished Press [Enter] key to continue..."

# If we are using ONETRACK, we can proceed with the normal encoding using just the $FIRSTTRACK as TRACKQUEUE
if [ "$ONETRACK" = "y" ] ; then
	TRACKQUEUE="$FIRSTTRACK"
	TRACKS="$FIRSTTRACK"
fi
if [ -e "$CDDBDATA" ]; then
	if [ "$ONETRACK" = "y" ]; then
		TRACKNAME="$DALBUM"
		TRACKNUM="$FIRSTTRACK"
		splitvarious
	else
		TRACKNUM="$UTRACKNUM"
		CDDBTRACKNUM=$(expr $UTRACKNUM - 1) # Unpad
		getcddbinfo TRACKNAME
		splitvarious
	fi
fi



do_cleancue
#read -p "cleancue finished Press [Enter] key to continue..."


cat ${ABCDETEMPDIR}/cue*
read -p "Press [Enter] key to continue..."
