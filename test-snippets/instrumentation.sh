INST_OUTPUT=/tmp/abcde   # no trailing slash!
mkdir -p $INST_OUTPUT

export INST_ENV="$INST_OUTPUT/environment_data"
touch $INST_ENV
export INST_LOG="$INST_OUTPUT/abcde.log"
touch $INST_LOG

UNRELATED='^(?:unrelated|pull_func|diff|inst_|gnome|xdg|xmod|ssh|session|ret|qt|wd|ps4|path|suer|uid|termopt|oldpwd|mem|ls_co|logname|im_hostname|hist|gtk|gpg|gdm|euid|dbus|colu|color|bash|user|ps1|lang|display|host|group|home|mailc|ppid|ps2|opt|vte|line|dir|im_c|systemd|pwd|wayland|xauth|term|shello|desktop|ls_opt).*'
INST_DIFF=diff
INST_DIFF_OPTIONS="-N -C 1"


# Define a "method missing" hook
# this does not accomplish the export -f or retry...
# but it does provide an indicator of the functions than need to be added to one of the pull-function calls
command_not_found_handle() {
    local missing_method="$1"
    shift
    local args=("$@")

    echo -e "\nCalled missing method: '$missing_method'"
    #echo "Passed arguments: ${args[*]}"

	# this causes issues if the function is not one that can be pulled in, so commenting out for now.
	# source <(./pull-functions.sh $missing_method)

	# if [[ $? -eq 0 ]]; then
	# 	#export -f $missing_method
	# 	echo "retrying $missing_method"
	# 	$missing_method $args

	# 	EC=$?

	# 	echo "call to $missing_method had exit code of $EC"
	# 	return $EC
	# fi

    # Return 127 to mimic standard "command not found" exit status
    return 127
}

show_env () {
	(set -o posix; set | grep -Pvi $UNRELATED)
}

instrument_env () {
	if [[ -e $INST_ENV ]]; then
		mv $INST_ENV $INST_ENV.old
	fi

	show_env > $INST_ENV
	[ $2 == 'start' ] && echo -e "vvvvvvvv\n" >> $INST_LOG
	[ $1 ] && echo -e "\n*** Function: $@ ***********\n" >> $INST_LOG
	$INST_DIFF $INST_DIFF_OPTIONS $INST_ENV.old $INST_ENV  >> $INST_LOG
	[ $2 == 'exit' ] && echo -e "\n^^^^^^^^^" >> $INST_LOG

}

#export -f instrument_env
#export -f show_env
#export -f command_not_found_handle

