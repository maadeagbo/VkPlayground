#!/usr/bin/env bash

ORIG_PATH=$PATH
ROOT_PATH="$(pwd)"
TOOLS_PATH="${ROOT_PATH}/Tools/"

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

# reset directory to clean state
echo Cleaning directory...
git clean -xnd
QueryForInput "Clean untracked repo files"
if [[ $? -eq 1 ]]; then
	echo "And like Yahweh w/ Noah's flood..."
	echo " "
	git clean -xdf
fi

# Check for and install these packages
echo Searching for vulkan libs...
if version=$(dpkg-query -W -f='${Version}' libvulkan-dev 2>/dev/null); then
	echo Cmake ${version} found.
else
	QueryForInput "Project builds w/ libvulkan-dev. Install"

	if [[ $? -eq 1 ]]; then
		apt install libvulkan-dev
	else
		echo "Cannot build project. Exiting."
		exit 1
	fi
fi

# libs to install on linux:
# libxcb1-dev libxcb-icccm4-dev libxcb-keysyms1-dev 

echo Searching for xcb libs...
if version=$(dpkg-query -W -f='${Version}' libxcb1-dev 2>/dev/null); then
	echo Cmake ${version} found.
else
	QueryForInput "Project builds w/ libxcb1-dev. Install"

	if [[ $? -eq 1 ]]; then
		apt install libxcb1-dev
	else
		echo "Cannot build project. Exiting."
		exit 1
	fi
fi

if version=$(dpkg-query -W -f='${Version}' libxcb-icccm4-dev 2>/dev/null); then
	echo Cmake ${version} found.
else
	QueryForInput "Project builds w/ libxcb-icccm4-dev. Install"

	if [[ $? -eq 1 ]]; then
		apt install libxcb-icccm4-dev
	else
		echo "Cannot build project. Exiting."
		exit 1
	fi
fi

if version=$(dpkg-query -W -f='${Version}' libxcb-keysyms1-dev 2>/dev/null); then
	echo Cmake ${version} found.
else
	QueryForInput "Project builds w/ libxcb-keysyms1-dev. Install"

	if [[ $? -eq 1 ]]; then
		apt install libxcb-keysyms1-dev
	else
		echo "Cannot build project. Exiting."
		exit 1
	fi
fi

# Add the bin & tools/bin directory to the path if allowed
if [[ $ORIG_PATH != *"VulkanDemoScene"* ]]; then
	QueryForInput "Append /bin directory to path for this terminal session"

	if [[ $? -eq 1 ]]; then
		echo "Executing order 66..."
		echo " "
		PATH=${ROOT_PATH}/bin:${TOOLS_PATH}bin:$PATH
	else
		echo "You've chosen foolishly young jedi..."
		echo " "
	fi
fi

# Check if cmake is installed (and querying for the version number)
echo Searching for cmake...
if version=$(dpkg-query -W -f='${Version}' cmake 2>/dev/null); then
	echo Cmake ${version} found.
else
	QueryForInput "Project builds w/ cmake. Install cmake"

	if [[ $? -eq 1 ]]; then
		echo "Executing order 67..."
		echo " "
		apt install cmake
	else
		echo "Cannot build project. Exiting."
		exit 1
	fi
fi

# Check if git-lfs is installed (and querying for the version number)
echo Searching for git-lfs...
if version=$(dpkg-query -W -f='${Version}' git-lfs 2>/dev/null); then
	echo git-lfs ${version} found.
else
	QueryForInput "Project requires git-lfs. Install git-lfs"

	if [[ $? -eq 1 ]]; then
		echo "Executing order 68..."
		echo " "
		apt install git-lfs
	else
		echo "Cannot build project. Exiting."
		exit 1
	fi
fi

# Check if p7zip-full is installed (and querying for the version number)
echo Searching for 7zip...
if version=$(dpkg-query -W -f='${Version}' p7zip-full 2>/dev/null); then
	echo 7z ${version} found.
else
	QueryForInput "Project requires 7z. Install p7zip-full"

	if [[ $? -eq 1 ]]; then
		echo "Executing order 69 (lol)..."
		echo " "
		apt install p7zip-full
	else
		echo "Cannot build project. Exiting."
		exit 1
	fi
fi

mkdir -p build
cd build && cmake ${ROOT_PATH}

if [ ! -f ${TOOLS_PATH}bin/CompressonatorCLI ]; then
  7z e ${TOOLS_PATH}CompressonatorCLI_linux01.7z -o${TOOLS_PATH}bin
  7z e ${TOOLS_PATH}CompressonatorCLI_linux02.7z -o${TOOLS_PATH}bin
  7z e ${TOOLS_PATH}CompressonatorCLI_linux03.7z -o${TOOLS_PATH}bin
  7z e ${TOOLS_PATH}CompressonatorCLI_linux04.7z -o${TOOLS_PATH}bin
fi

ulimit -c unlimited
(cmake --build . --target lua)

cd ${ROOT_PATH}

# QueryForInput "Generate texture assets for default app?"
# if [[ $? -eq 1 ]]; then
# 	${ROOT_PATH}/bin/lua ${ROOT_PATH}/Scripts/TextureBuilder.lua -r default
# fi
# QueryForInput "Generate texture assets for material app?"
# if [[ $? -eq 1 ]]; then
# 	${ROOT_PATH}/bin/lua ${ROOT_PATH}/Scripts/TextureBuilder.lua -r material
# fi

lua ${ROOT_PATH}/Scripts/RunScrapper.lua

chmod +x ${ROOT_PATH}/run.sh
chmod +x ${ROOT_PATH}/Scripts/debug_gdb.sh
chmod +x ${ROOT_PATH}/Scripts/format_code_style.sh
chmod +x ${ROOT_PATH}/Scripts/compilefile.sh
chmod +x ${ROOT_PATH}/Scripts/better_git_log.sh

