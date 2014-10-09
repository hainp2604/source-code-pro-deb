#!/bin/sh
url='git@github.com:adobe-fonts/source-code-pro.git'
afdko_home="http://www.adobe.com/devnet/opentype/afdko"
s="$( echo ${url} | cut -d'/' -f2 | cut -d. -f1 )"

binary_prompt_yn() {
	### usage:
	## binary_prompt_yn <yes> <no> <default> <dont exit on this> <message>
	y=$1
	shift 1
	n=$1
	shift 1
	default_resp=$1
	shift 1
	dont_exit_on=$1
	shift 1
	prompt_msg="$*"
	defaults="["
	if [ "${default_resp}" = "${y}" ]; then
		defaults="${defaults}$( echo $y |  tr [:lower:] [:upper:] )/${n}"
	else
		defaults="${defaults}$y/$( echo $n |  tr [:lower:] [:upper:] )"
	fi
	defaults="${defaults}]"
	read -p "${prompt_msg} ${defaults}? " x
	if [ -z "${x}" ]; then
		x="${default_resp}"
	fi
	resp="$( echo $x | tr [:upper:] [:lower:] | cut -c1 )"
	if [ "${dont_exit_on}" != "${resp}" ]; then
		echo "Exiting par user request."
		exit 0
	fi
}

show_intent() {
	echo "This script will:"
	/bin/echo -e "\t1. download latest adobe fonts sources"
	/bin/echo -e "\t2. build them with AFDKO (must be installed)"
	/bin/echo -e "\t3. create a Debian package for them"
	/bin/echo -e "\t4. (optional) install the created package"
}

check_tools() {
	echo "#######################################"
	echo "Checking tools..."
	echo "#######################################"
	which makeotf 2> /dev/null 1> /dev/null
	if [ ! $? -eq 0 ]; then
		echo "Error: makeotf is not found"
		echo "Hint: To obtain, browse to the page: ${afdko_home}"
		exit 1
	fi
	which dpkg-buildpackage 2> /dev/null 1> /dev/null
	if [ ! $? -eq 0 ]; then
		echo "Error: dpkg-buildpackage is not found."
		echo "Hint: to intall, run: sudo apt-get install dpkg-dev"
		exit 1
	fi
}

fetch_fonts_source () {
	echo "#######################################"
	echo "Fetching latest source for Fonts from: ${url}"
	echo "#######################################"
	if [ -d "${s}" ]; then
		rm -fr ${s}
	fi
	cmd="git clone ${url}"
	$cmd
	if [ $? -ne 0 ]; then
		echo "Error occurred when running: ${cmd}"
		exit 1
	fi
}

build_fonts() {
	echo "#######################################"
	echo "Building Fonts ..."
	echo "#######################################"
	fbuildlog="$(pwd)/${s}.build.log"
	test -f ${fbuildlog} && rm -f ${fbuildlog}
	cd ${s}
	./build.sh 2>&1 | tee ${fbuildlog}
	if [ $? -ne 0 ]; then
		echo "Something went wrong during the build of the fonts."
	       	echo "Inspect ${fbuildlog} file!"
		exit 1
	fi
	cd ../
	trg="${s}/target/OTF"
	echo "#######################################"
	echo "The Fonts are ready under: ${trg}"	
	echo "#######################################"
}

build_package () {
	echo "#######################################"
	echo "Building Debian package ..."
	echo "#######################################"
	dpkg-buildpackage
}

main() {
	show_intent
	# fetch official github sources for the fonts:
	binary_prompt_yn "y" "n" "n" "y" "Do you want to continue"
	check_tools
	fetch_fonts_source
	build_fonts
	build_package
	echo "#######################################"
	echo "DONE"
	echo "#######################################"
	exit $?
}


main
