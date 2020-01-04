#!/usr/bin/env bash

## run::compilef:=Build a specific file in the project. Targets are found in a cmake created makefile
## run::compilef::file::src/System/main.cpp
## run::compilef::file:=The only argument. A \".c\" or \".cpp\" file to build

if [[ -z $1 ]]; then
	echo "No file provided for compilation. Exiting."
	exit 1
fi

MAKEF="build.make"
MATCH=$(grep -r -i /$1.o: build --include=${MAKEF} --max-count 1 --files-with-matches)

if [[ ! -z $MATCH ]]; then
	FOLDER=${MATCH:0:${#MATCH}-${#MAKEF}}
	TARGET=${MATCH:6:${#MATCH}-${#MAKEF}-6}$1.o
	echo "Running build target in ${FOLDER}${MAKEF}..."
	cd build
	make -f ${MATCH:6} $TARGET
fi
