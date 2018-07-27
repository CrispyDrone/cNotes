#!/bin/bash

# ============
# Introduction
# ============
# This script is used to compile notes from certain subdirectories in a general "NOTES" containing directory, or optionally notes can be piped through from a "grep-like" command such as vimgrep (not yet supported). The script compiles markdown files into pdf files with tables of contents for quick navigation (currently no global toc yet...). The main directory can be set as an environment variable called $NOTES_DIR or supplied to the script through an optional flag "-i DIRECTORY".
# enable extended pattern matching
shopt -s extglob

set -x
trap read debug
# only read commands (testing stage)
# set -n
# If an error occurs, exit script
set -e
# man page
man() {
	cat << EOF
Introduction:

	This script is used to compile notes from certain subdirectories in a general "NOTES" containing directory, or optionally notes can be piped through from a "grep-like" command such as vimgrep. The script compiles markdown files into one pdf file with a table of contents for quick navigation. The main directory is an environment variable called $NOTES_DIR and can be set manually or supplied to the script through an optional flag "-i DIRECTORY" (warning: this will create an environment variable!). A pdf is created in each final directory ("the leaves") unless this is turned off through the -r flag, and one combination pdf ("the root") at the main directory ($NOTES_DIR in case of "all").

Commands:

	notes [-i DIRECTORY] [-r] all

		Compiles all notes from the $NOTES_DIR directory.

	notes [-i DIRECTORY] [-r] (SUB)DIRECTORY [[,...n] | [...n] [int [[,...n] | [-int]]]]

		Compiles all notes from the (SUB)DIRECTORY contained in $NOTES_DIR. Multiple directories can be included by separating them with a comma, or the compilation can be excluded to an other subdirectory level by providing additional subdirectories in a space separated list. An optional integer, integer list, or integer range can also be supplied in this latter case to limit the compilation to those folders ending in an integer that's included in the supplied collection.

	[vim]grep {pattern} | notes

		NOTE: NOT YET SUPPORTED Pipe [vim]grep output to the notes script. Any note files (markdown files) will be compiled.

	notes man

		Opens this manual page.

Syntax:

	-i DIRECTORY

		Sets the $NOTES_DIR environment variable.

	-r

		Root only, only generate master pdf.

EOF
}

# gets all notes from a specific directory, later on add support for the option to search recursively or not ? (for now it IS recursively)
getnotes() {
	find . -type f -name "*.markdown" -o -name "*.md" -o -name "*.mkd" | \
		while read line
		do
			echo "$line"
		done
}

# compiles a pdf from markdown to latex, with table of contents and provided font (not yet supported)
makepdf() {
	pandoc -f markdown -t latex --toc -o "${1}.pdf" $2 && echo "Created ${1}.pdf"
}

# takes *, path and int list, or directory list
# output all directories that contained notes
makenotes() {
	isNotEmptyRegex="[[:alnum:]]"
	if [ "$1" = '*' ]
	then
		cd $NOTES_DIR &>/dev/null
		# compile notes from all directories in $NOTES_DIR
		for folder in *
		do
			if [ -d "$folder" ]
			then
				cd $folder &>/dev/null
				# how to write a proper regex?? I need to match as soon as there's a single character different from a space, tab, newline (line feed/carriage return),... basically if ntoes is note EMPTY!
				notes=$(getnotes)
				# if [ $? -eq 0 ] # would have to change find return code...
				if [[ "$notes" =~ $isNotEmptyRegex ]]
				then
					#output_file="$folder/"$(basename "$folder")
					output_file=$(basename "$folder")
					oldIfs=$IFS
					IFS=$'\n'
					makepdf "$output_file" "$notes"
					IFS=$oldIfs
					compiledFiles+=("$folder/${output_file}.pdf")
					unset notes output_file oldIfs
				fi
				cd - &>/dev/null
			fi
		done
	else
		dirPath="$1"
		hasInts=false
		# $1 is a directory, following arguments are either also directories, or integers
		# check whether there are ints

		while [ ! $# -eq 0 ]
		do
			case "$1" in
				# a directory
				+([^0-9]))
					shift
					;;
				# an int
				+([0-9]))
					hasInts=true
					break
					;;
			esac
		done
		
		while [ ! $# -eq 0 ]
		do
			# get notes and makepdf for each directory
			case "$1" in
				# an actual directory
				+([^0-9]))
					if [ "$hasInts" = "false" ]
					then
						# in this case, we can change to those directories and get the notes
						cd $NOTES_DIR/$1/ &>/dev/null
						output_file="$NOTES_DIR/$1/"$(basename "$NOTES_DIR/$1")
					fi
					;;
				# an int
				+([0-9]))
					# how to make this work in a single statement??
					cd "$NOTES_DIR/$dirPath" &>/dev/null #*"$1" &>/dev/null
					cd *$1 &>/dev/null
					# output_file="$NOTES_DIR/$dirPath/*$1/"$(basename "$NOTES_DIR/$dirPath/*$1")
					output_file="$PWD/"$(basename "$PWD")
					;;
			esac
			# get notes and make pdf
			notes=$(getnotes)
			# if [ $? -eq 0 ] # would have to change find return code...
			if [[ "$notes" =~ $isNotEmptyRegex ]]
			then
				oldfIfs=$IFS
				IFS=$'\n'
				makepdf "$output_file" "$notes"
				IFS=$oldIfs
				compiledFiles+=("${output_file}.pdf")
				unset notes output_file oldIfs
			fi
			shift
			cd - &>/dev/null
		done
		cd $NOTES_DIR/$dirPath/ &>/dev/null
		# if no integers, then multiple directories were supplied, the master pdf should be at the parent directory in that case
		if [ "$hasInts" = false ]
		then
			cd ..
		fi
	fi
	# make master pdf
	echo "Compiling master pdf..."
	gswin64c -sDEVICE=pdfwrite -dQUIET -o "master.pdf" ${compiledFiles[@]}
	cd - &>/dev/null
}

# parse directories
parseDirectories() {
	# If no arguments, exit with error
	if [ $# -eq 0 ]
	then
		echo "No directories listed" >&2
		exit 1
	fi

	# change working directory (hardcoded value for now if $NOTES_DIR is not defined)
	cd ${NOTES_DIR:-"$HOME/Dropbox/Notes"} &>/dev/null

	# If only 1 argument, must be comma separated list of directories to include, else it will be a "path" with optional ints listing
	if [ $# -eq 1 ]
	then
		# subdirectories, possibly separated by commas, no subsubdirectories or ints allowed
		validDirectories=()
		# split based on commas
		IFS=',' read -ra possibleDirectories <<< "$1"
		for dir in "${possibleDirectories[@]}"
		do
		# check which are valid directories, continue with the valid ones
			if [ -d "$dir" ]
			then
				validDirectories+=("$dir")
			fi
		done
		echo "${validDirectories[@]}"
		exit 0
	else
		# narrowing of subdirectory to specific subsubdirectories, possibly also int listing
		# combine all directories into a "path", check whether it is valid
		# if ints are supplied, check whether directories ending in a number exist
		# if not exit with error
		# else put in some sort of array, or could just pipe it

		path=""
		#numberOfDirs=0

		while [ ! $# -eq 0 ]
		do
			case "$1" in
				# is a number, comma separated number list or number range; reached end of directory list, break
				+([0-9])*([^0-9][0-9]))
					break
					;;
				# not a number, should be a directory, append to path
				+([^0-9]))
					path="$path""$1"\\
					#numberOfDirs=$((numberOfDirs + 1))
					shift
					;;
			esac
		done

		# check if path exists, else exit with error
		if [ -d "$path" ]
		then
			# echo it
			echo "$path" #/"$numberOfDirs"
			exit 0
		fi

		# not an existing path, exit with error
		exit 1
	fi
}

# parse optional int listing, also check whether they exist, if not exist with error
parseInts() {
	# If no arguments, exit with error
	if [ $# -eq 0 ]
	then
		echo "No arguments supplied" >&2
		exit 1
	fi

	# remove directory arguments
	# finalDirectory=""
	path=""

	while [ $# -gt 0 ]
	do
		case "$1" in
			+([^0-9]))
				path="$path""$1"\\
				#finalDirectory="$1"
				shift
				;;
			+([0-9])*([^0-9][0-9]))
				break
				;;
		esac
	done

	if [ $# -eq 0 ]
	then
		echo "No integers supplied" >&2
		exit 1
	fi

	# only 1 argument left, either a single integer (1), a comma separated list (1,2,4), or a range (1-10) (without parentheses)
	# check whether it has a dash, or commas in it

	# bug 1) dash not allowed? bad regex?

	if [[ "$1" = *-* ]]
	then
		# range, grap both numbers
		lowerLimit=$(echo "$1" | sed 's/\([0-9]\+\)-[0-9]*/\1/')
		upperLimit=$(echo "$1" | sed 's/[0-9]\+-\([0-9]*\)/\1/')
		if [ "$lowerLimit" -gt "$upperLimit" ]
		then
			# if lowerlimit > upperlimit exit with error
			exit 1
		fi

		for ((i=lowerLimit; i<=upperLimit; i++))
		do
			integers+=("$i")
		done
	
	# bug 2) bad regex??
	elif [[ "$1" = *,* ]]
	then
		# comma separated list, split into array
		integers=($(echo "$1" | tr ',' "\n"))
	elif [[ "$1" =~ ^[0-9]+$ ]]
	then
		# single number
		integers+=("$1")
	else
		# wrong input, exit with error
		exit 1
	fi

	# check whether each directory exists of name *integers[i]
	cd "$NOTES_DIR"/"$path"
	for i in "${integers[@]}"
	do
		# bug 3) find proper regex for this
		endsInIntegerRegex="$i/$"
		for folder in */ #"${finalDirectory}"/
		do
			if [[ "$folder" =~ $endsInIntegerRegex ]]
			then
				echo "$i"
			fi
		done
	done
	cd - &>/dev/null
	# echo "$integers"
}

cleanDirectories() {
	while [ ! $# -eq 0 ]
	do
		rm -f "$1"
		shift
	done
}

main() {
	arr_dir_name=$2[@]
	arr_ints_name=$3[@]
	directoriesToSearch=("${!arr_dir_name}")
	intsToSearch=("${!arr_ints_name}")

	# if first element is ...
	case "${directoriesToSearch[0]}" in
		\*)
			# literal *
			echo "Compiling all notes..."
			makenotes '*'
			;;
		+(?)'\')
			# path, can have int list
			echo "Compiling notes in $NOTES_DIR/${directoriesToSearch[0]}..."
			makenotes "${directoriesToSearch[0]}" "${intsToSearch[@]}"
			;;
		*)
			# array, no int list possible
			echo "Compiling notes for ${directoriesToSearch[@]}..."
			makenotes "${directoriesToSearch[@]}"
			;;
	esac
	
	# if -r cleanup directories
	if [ "$1" = "true" ]
	then
		echo "Cleaning up directories..." && cleanDirectories "${compiledFiles[@]}"
	fi
}


# variables list
# Only generate master pdf = false
rootOnly=false
directories=()
integers=()
compiledFiles=()

# this doesn't work the way I want it to... I don't want people to be able to add man somewhere in the middle of a command and have it show the man page... I want it to report an error in that case. So I'll have to use a different construct than this while loop
while [ ! $# -eq 0 ]
do
	case "$1" in 
		man)
			#Show man page
			man
			exit 0;;
		-i)
			#Check whether $2 is actually a valid directory
			if [ -d "$2" ]
			then
				setx NOTES_DIR "$2"
				#export NOTES_DIR="$2"
				shift 2
			else
				echo "$2 is not a directory!"
				exit 1
			fi
			;;
		-r)
			# Only generate master pdf = true
			rootOnly=true
			shift
			;;
		all)
			# Compile all notes in all subdirectories
			# All directories of $NOTES_DIR need to be searched
			directories+=(\*)
			integers+=(\*)
			break
			;;
		*)
			# Parse directories, and optional ints listing
			mapfile -t directories < <(parseDirectories "$@")
			mapfile -t integers < <(parseInts "$@")
			# directories=$(parseDirectories "$@") # | sed 's/^\(.*\)\/[0-9]+$/\1/')
			# integers=$(parseInts "$@")
			break
			;;
	esac
done

main "$rootOnly" directories integers
