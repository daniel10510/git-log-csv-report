#! /bin/bash
# git-report by @palomaclaud
# Paloma Claudino <paloma.claud@gmail.com>

# INSTRUCTIONS:
# Run on current git respoitory with $ sh ./git-report.sh

# START GIT-REPORT SHELL SCRIPT
clear

# File definitions
REPOSITORY_NAME=`dirs|awk -F"/" '{print $NF}'`
TEMP_FILE=TEMP_REPORT.txt
GIT_LOG_FILE=GIT_LOG_REPORT.txt
CSV_FILE=${REPOSITORY_NAME^^}_REPORT.csv
HEADER="Hash;Comment;Status;File;\n"

# Filters
USER_FILTER=""
COMMENT_FILTER=""

# Functions
generate_git_log() {
	git log --author=$USER_FILTER --grep=$COMMENT_FILTER --reverse --name-status --pretty=oneline > $TEMP_FILE
	cat $TEMP_FILE | tr "	" ";" > $GIT_LOG_FILE
}

generate_header() {
	printf $HEADER > $CSV_FILE
}

format_status() {
	case $STATUS_LETTER in
		"A;") FORMATTED_LINE=${LINE//$STATUS_LETTER/Added;} ;;
		"C;") FORMATTED_LINE=${LINE//$STATUS_LETTER/Copied;} ;;
		"D;") FORMATTED_LINE=${LINE//$STATUS_LETTER/Deleted;} ;;
		"M;") FORMATTED_LINE=${LINE//$STATUS_LETTER/Modified;} ;;
		"R;") FORMATTED_LINE=${LINE//$STATUS_LETTER/Renamed;} ;;
		"T;") FORMATTED_LINE=${LINE//$STATUS_LETTER/Have their type (mode) changed;} ;;
		"U;") FORMATTED_LINE=${LINE//$STATUS_LETTER/Unmerged;} ;;
		"X;") FORMATTED_LINE=${LINE//$STATUS_LETTER/Unknown;} ;;
		"B;") FORMATTED_LINE=${LINE//$STATUS_LETTER/Have had their pairing Broken;} ;;
		   *) FORMATTED_LINE=${LINE//$STATUS_LETTER/All-or-none;} ;;
	esac
}

generate_lines() {
	FORMATTED_LINE=""
	CONTENT=""
	COMMIT=""

	while read LINE
	do
		STATUS_LETTER="${LINE:0:2}"
		if 	[[ $STATUS_LETTER =~ ^(A;|C;|D;|M;|R;|T;|U;|X;|B;)$ ]] ; then
			format_status
			printf "$CONTENT;$FORMATTED_LINE;\n" >> $CSV_FILE
		else
			HASH=${LINE:0:40}
			MSG=${LINE:41}
			COMMIT="$HASH;$MSG"
			CONTENT="$COMMIT"
		fi
	done < $GIT_LOG_FILE
}

remove_files() {
	rm $TEMP_FILE
	rm $GIT_LOG_FILE
}

# Generate report
echo "Generating git log report from repository" ${NOME_REPOSITORIO^^}
generate_git_log
generate_header
generate_lines
echo "Report generated successfully!" $CSV_FILE

remove_files

exit 0
# FINISHED
