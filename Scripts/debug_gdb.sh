#!/usr/bin/env bash

## run::debug:=Debug applications using gdb
## run::debug::app::\"demo_app\"
## run::debug::app:=App to pass into gdb (default app=demo_app)

# function for querying user yes/no
# only argument is query message
# return value is stored in $?
QueryForInput() {
	echo " "
	read -p "$1 (Y/n)? " choice
	case "$choice" in
		y|Y )
			return 1
			;;
		n|N )
			return 0
			;;
		* )
			return 1 # defualt is yes
			;;
	esac
}

APP='./bin/demo_app'
if [[ ! -z ${1} ]]; then
	APP=$1
fi

# Make sure exe exists
if [[ ! -f $APP ]]; then
	echo "$APP not found. Exiting debug."
	exit 1
fi

COREDUMP=''
APP_TIME=$(stat -c %Y $APP)
if [[ -f './core' ]]; then
	COREDUMP_TIME=$(stat -c %Y './core')

	if [[ $COREDUMP_TIME -gt $APP_TIME ]]; then
		COREDUMP='./core'

		echo "Valid core dump piped in"
	else
		QueryForInput "Delete old core dump"
		if [[ $? -eq 1 ]]; then
			rm core
		fi
	fi

	gdb -tui -ex="focus cmd" $APP $COREDUMP
else
	# To view output w/ color information :
	#  less -r ./bin/gdb_out.log
	gdb $APP -x="Scripts/gdb_cmds.txt"
fi

