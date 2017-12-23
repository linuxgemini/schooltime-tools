#!/bin/bash

# HLS re-streamer by linuxgemini, released under MIT license
#
# Requires:
#     a web server
#     streamlink (a powerful stream fetcher)
#     ffmpeg
#     screen
#
# Usage (if you set the chmod and path right):
#     ./re-streamer.bash <stream link> <optional, stream quality>
#

DEST=/path/to/web/server/
streamName=streamname

# DON'T EDIT THE CODE BELOW IF YOU DON'T KNOW WHAT YOU ARE DOING
topkek="*."
FORMAT=m3u8
FORMAT2=ts

if [[ -z "$DEST" || -z "$streamName" ]]; then
    printf "\nOne or more setting(s) are not defined.\nOpen your favourite text editor and make sure that the settings are defined.\nThe settings are in between line 7 and 12.\n\n"
    exit
fi

if [[ ! -d "$DEST" ]]; then
    printf "\nDestination folder is not a valid folder.\n\n"
    exit
fi

function find_screen {
    if screen -ls "$1" | grep -o "^\s*[0-9]*\.$1[ "$'\t'"](" --color=NEVER -m 1 | grep -oh "[0-9]*\.$1" --color=NEVER -m 1 -q >/dev/null; then
        screen -ls "$1" | grep -o "^\s*[0-9]*\.$1[ "$'\t'"](" --color=NEVER -m 1 | grep -oh "[0-9]*\.$1" --color=NEVER -m 1 2>/dev/null
        return 0
    else
        echo "$1"
        return 1
    fi
}

callthepolice=`ls $DEST$topkek$FORMAT 2> /dev/null | wc -l`
callthehouse=`ls $DEST$topkek$FORMAT2 2> /dev/null | wc -l`

case $1 in
	start )
		if [ -z $2 ]; then
			printf "\nNo link is specified.\n\nUsage: $0 start <link> <optional-quality>"
			exit
		fi

		if [ -z $3  ]; then
			quality=best
		else
			quality=$3
		fi

		if [ ! -z $(pgrep streamlink) ] || [ ! -z $(pgrep ffmpeg) ]; then
			printf "\nNecessary services are already running. Exiting...\n\n"
			exit
		fi

		if find_screen "streamers" >/dev/null; then
			screen -S streamers -X stuff "^Mexit^M"
			sleep 1
		fi

		screen -dmS streamers bash -c 'echo Startup!;  exec bash'
		sleep 1
		screen -S streamers -X stuff $"streamlink -O $2 $quality | ffmpeg -v verbose -i pipe:0 -c:v libx264 -c:a aac -ac 1 -crf 23 -profile:v baseline -maxrate 400k -bufsize 1835k -pix_fmt yuv420p -flags -global_header -hls_time 10 -hls_list_size 6 -hls_wrap 10 -start_number 1 $DEST$streamName.m3u8\n"
		printf "\nStartup initiated.\n\n"
	;;
	stop )
        if [ ! -z $(pgrep streamlink) ] && [ ! -z $(pgrep ffmpeg) ]; then
            if find_screen "streamers" >/dev/null; then
             	if [ ! -z $(pgrep ffmpeg) ]; then
					kill $(pgrep ffmpeg)
					printf "\nWaiting for graceful quit for 10 seconds..."
					sleep 10
				fi

				if [ ! -z $(pgrep streamlink) ]; then
					kill $(pgrep streamlink)
				fi

				screen -S streamers -X stuff "^Mexit^M"

				if [ $callthepolice != "0" ]; then
					rm $DEST$topkek$FORMAT
				fi

				if [ $callthehouse != "0" ]; then
					rm $DEST$topkek$FORMAT2
				fi

				printf "\nStream stopped.\n\n"
            fi
        fi
	;;
	* )
		exit
	;;
esac
