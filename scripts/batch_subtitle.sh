#!/bin/bash

ROOT_DIR=$(dirname $(dirname $(realpath -LP ${0})))
SCRIPT_NAME=$(basename ${0})

function show_usage {
    echo
    echo "Usage: ${SCRIPT_NAME} [-h] show this help info."
    echo "       ${SCRIPT_NAME} [-v] video_list_file [style options]"
    echo "${SCRIPT_NAME} is a wrapper of subtitle.sh to process videos in a batch."
    echo "The input video_list_file contains one or more videos' paths saved"
    echo "as one path per-line. subtitle.sh is called one by one against these paths."
    echo "All options of ${SCRIPT_NAME} are sent transparently to subtitle.sh."
    echo
    echo "  input:"
    echo "  video_list_file   A text file list multiple videos' pathes, one path per line."
    echo
}

# show usage by default
if [ $# -eq 0 ]; then
    show_usage
    exit 0
fi

VERBOSE=""
# Reset in case getopts has been used previously in the shell.
OPTIND=1
while getopts "hv" opt; do
    case ${opt} in
        h ) # process option h
            show_usage
            exit 0
            ;;
        v ) # process option v
            VERBOSE="-v"
            ;;
        \? ) # invalid option
            echo
            show_usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

####################
####    main    ####
####################
INPUT_FILE=$(realpath -LP ${1})
shift
INPUT_FILE_DIR=$(dirname ${INPUT_FILE})
CWD=$(pwd)
STYLE_OPTIONS=${@}

START=$(date +%s)
VIDEO_PATHS=""
while read -r path;
do
    VIDEO_PATHS="${VIDEO_PATHS} ${path}"
done < ${INPUT_FILE}

cd ${INPUT_FILE_DIR}
for path in ${VIDEO_PATHS};
do
    subtitle.sh ${VERBOSE} ${path} ${STYLE_OPTIONS}
done
cd ${CWD}
END=$(date +%s)
COST=$((${END}-${START}))

GREEN='\033[0;32m'
RESET='\033[0m'
printf "${SCRIPT_NAME} cost:  ${GREEN}$((${COST} / 3600))${RESET}hrs ${GREEN}$(((${COST} / 60) % 60))${RESET}min ${GREEN}$((${COST} % 60))${RESET}sec"
