#! /bin/bash
## git-report by @palomaclaud
## Paloma Claudino <paloma.claud@gmail.com>

## INSTRUCTIONS:
## Run on current git respoitory with $ sh ./git-report.sh

## START GIT-REPORT SHELL SCRIPT
clear

## File definitions
REPOSITORY_NAME=`dirs|awk -F"/" '{print $NF}'`
TEMP_FILE=TEMP_REPORT.txt
GIT_LOG_FILE=GIT_LOG_REPORT.txt
CSV_FILE=${REPOSITORY_NAME^^}_REPORT.csv
# first line of csv file
HEADER="Hash;Comment;Status;File;Info;\n"

## Filters
USER_FILTER="Paloma\|Claudino"
COMMENT_FILTER=""

## Functions
generate_git_log() {
	#--author	Limit the commits output to ones with author header lines that match the specified pattern
	#--grep		Limit the commits output to ones with reflog entries that match the specified pattern
	#--reverse	Output the commits chosen to be shown in reverse order
	#--name-status	Show only names and status of changed files	
	git log --author=$USER_FILTER --grep=$COMMENT_FILTER --reverse --name-status --pretty=oneline > $TEMP_FILE
	
	# replace tab to ;
	cat $TEMP_FILE | tr "	" ";" > $GIT_LOG_FILE
}

generate_header() {
	printf $HEADER > $CSV_FILE
}

format_status() {
	STATUS_LETTER_02="${LINE:0:2}"
	STATUS_LETTER_04="${LINE:0:4}"
	STATUS_LETTER_05="${LINE:0:5}"
	NEW_LINE=false
	
	if [[ $STATUS_LETTER_04 == "C75;" ]]; then
		FORMATTED_LINE=${LINE//$STATUS_LETTER_04/Copied;}
	elif [[ $STATUS_LETTER_05 == "R100;" ]]; then
		FORMATTED_LINE=${LINE//$STATUS_LETTER_05/Renamed;}
	elif [[ $STATUS_LETTER_02 =~ ^(A;|C;|D;|M;|R;|T;|U;|X;|B;) ]]; then
		case $STATUS_LETTER_02 in
			"A;") FORMATTED_LINE=${LINE//$STATUS_LETTER_02/Added;} ;;
			"C;") FORMATTED_LINE=${LINE//$STATUS_LETTER_02/Copied;} ;;
			"D;") FORMATTED_LINE=${LINE//$STATUS_LETTER_02/Deleted;} ;;
			"M;") FORMATTED_LINE=${LINE//$STATUS_LETTER_02/Modified;} ;;
			"R;") FORMATTED_LINE=${LINE//$STATUS_LETTER_02/Renamed;} ;;
			"T;") FORMATTED_LINE=${LINE//$STATUS_LETTER_02/Have their type (mode) changed;} ;;
			"U;") FORMATTED_LINE=${LINE//$STATUS_LETTER_02/Unmerged;} ;;
			"X;") FORMATTED_LINE=${LINE//$STATUS_LETTER_02/Unknown;} ;;
			"B;") FORMATTED_LINE=${LINE//$STATUS_LETTER_02/Have had their pairing Broken;} ;;
			   *) FORMATTED_LINE=${LINE//$STATUS_LETTER_02/All-or-none;} ;;
		esac
	else
		NEW_LINE=true
	fi
}

generate_lines() {
	FORMATTED_LINE=""
	CONTENT=""
	COMMIT=""

	while read LINE
	do
		format_status
		if $NEW_LINE; then
			HASH=${LINE:0:40}
			MSG=${LINE:41}
			COMMIT="$HASH;$MSG"
			CONTENT="$COMMIT"
		else
			printf "$CONTENT;$FORMATTED_LINE;\n" >> $CSV_FILE
		fi
	done < $GIT_LOG_FILE
}

remove_files() {
	rm $TEMP_FILE
	rm $GIT_LOG_FILE
}

## Generate report
echo "Generating git log report from repository" ${REPOSITORY_NAME^^}
generate_git_log
generate_header
generate_lines
echo "Report generated successfully!" $CSV_FILE

remove_files

exit 0
## FINISHED
