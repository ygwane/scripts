#!/bin/bash
#
# Name: terminal_recording.sh
# Description: Record terminal session
#
######################################

# VAR
TEMP=$(date +%d%m%y%H%M)
DIR=/home/terminal_recording

# FUNCTION
function display_usage()
{
    echo
    echo "Usage: ${0} [name]"
    echo "name: give a name to the session"
    echo "name is facultative. If it is not specified, date will be used to name session."
    echo
}

# Display Usage with -h or --help
if [ "${1}" == "-h" ] || [ "${1}" == "--help" ]
then
    display_usage
    exit 1
fi

# Check that directory to save files exists
if [ -d "${DIR}" ]
then
    echo "Directory ${DIR} exists, continue ..."
else
    echo "Directory ${DIR} doesn't exists, you have to create it !"
    exit 1
fi

# Begin recording session
## No arg
if [ $# -eq 0 ]
then
    echo -e "\033[032mPress enter to begin recording this terminal session as rec_${TEMP}.session or press [CTRL+C] to abort.\033[0m"
    read
    echo "Begin to record this terminal session at $(date +%c). To stop recording, enter: exit"
    script -t 2> ${DIR}/rec_${TEMP}.timing -a ${DIR}/rec_${TEMP}.session
    echo -e "\033[031mTo replay this recorded session enter: scriptreplay ${DIR}/rec_${TEMP}.timing ${DIR}/rec_${TEMP}.session\033[0m"

## One arg (name)
elif [ $# -eq 1 ]
then
    echo -e "\033[032mPress enter to begin recording this terminal session as rec_${1}.session or press [CTRL+C] to abort.\033[0m"
    read
    echo "Begin to record this terminal session at $(date +%c). To stop recording, enter: exit"
    script -t 2> ${DIR}/rec_${1}.timing -a ${DIR}/rec_${1}.session
    echo -e "\033[031mTo replay this recorded session enter: scriptreplay ${DIR}/rec_${1}.timing ${DIR}/rec_${1}.session\033[0m"

## Too many args
elif [ $# -gt 1 ]
then
    echo -e "\033[033mToo many args specified, we must have 0 or 1 argument !\033[0m"
    display_usage
    exit 1
fi

exit 0
# EOS
