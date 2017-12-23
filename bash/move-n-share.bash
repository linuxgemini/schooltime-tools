#!/bin/bash

# Move&Share Script v0.1.0 by linuxgemini
# Moves files in the format specified and runs a server daemon.
# Leaves no traces after using "stop" option.
# (Deletes the files in the destination folder (OPTIONAL) and stops the daemon)

SERVICE=vsftpd
SOURCE=/path/to/source/folder/
DEST=/path/to/destination/folder/
FORMAT=mp4

# DO NOT EDIT THE CODE BELOW #
topkek="*."

if [[ -z "$SERVICE" ||  -z "$SOURCE" || -z "$DEST" || -z "$FORMAT" ]]; then
    printf "\nOne or more setting(s) are not defined.\nOpen your favourite text editor and make sure that the settings are defined.\nThe settings are in between line 7 and 12.\n\n"
    exit
fi

if [[ ! -d "$SOURCE" ]]; then
    printf "\nSource folder is not a valid folder.\n\n"
    exit
fi

if [[ ! -d "$DEST" ]]; then
    printf "\nDestination folder is not a valid folder.\n\n"
    exit
fi

callthehouse=`ls $SOURCE$topkek$FORMAT 2> /dev/null | wc -l`
callthepolice=`ls $DEST$topkek$FORMAT 2> /dev/null | wc -l`

if [[ $EUID -ne 0 ]]; then
    printf "\nCan you run me as root?\n\n"
    exit
fi

case $1 in
    start )
        if [ $callthepolice != "0" ]; then
            printf "\nThere are other $FORMAT files in the transfer folder, beware.\n"
            if [[ -z $(pgrep $SERVICE) ]]; then
                printf "\n$SERVICE is not running. Starting $SERVICE again.\n"
                service $SERVICE start
            fi
        fi

        if [ $callthehouse != "0" ]; then
            mv $SOURCE$topkek$FORMAT $DEST
            if [ $callthehouse = "1" ]; then
                printf "\n$callthehouse $FORMAT file is moved to \"$DEST\".\n"
            else
                printf "\n$callthehouse $FORMAT files are moved to \"$DEST\".\n"
            fi
            if [[ -z $(pgrep $SERVICE) ]]; then
                printf "\n$SERVICE is not running.\n"
                service $SERVICE start
            else
                printf "\n$SERVICE is already running.\n"
            fi
            printf "\nOperation complete. Exiting...\n\n"
            exit
        else
            printf "\nThere is nothing to move. Exiting...\n\n"
            exit
        fi
        ;;
    stop )
        if [[ -z $(pgrep $SERVICE) ]]; then
            printf "\n$SERVICE is not running.\n\n"
        else
            echo
            service $SERVICE stop
            printf "$SERVICE is stopped.\n\n"
        fi

        while [ $callthepolice != "0" ]; do
            read -p "Do you wish to nuke $callthepolice $FORMAT file(s) that was moved before? [y/n] " yn
            case $yn in
                [Yy]* )
                    rm $DEST$topkek$FORMAT
                    if [ $callthepolice = "1" ]; then
                        printf "\n$callthepolice $FORMAT file on $DEST is deleted.\n\n"
                    else
                        printf "\n$callthepolice $FORMAT files on $DEST are deleted.\n\n"
                    fi
                    printf "Operation complete. Exiting...\n\n"
                    exit
                    ;;
                [Nn]* )
                    printf "\nNo $FORMAT files on $DEST are deleted.\n\nOperation complete. Exiting...\n\n"
                    exit
                    ;;
                * )
                    printf "\nPlease answer yes or no.\n\n"
                    ;;
            esac
        done

        printf "Operation complete. Exiting...\n\n"
        exit
        ;;
    * )
        printf "\nUsage: $0 [start|stop]\n" 
        exit
        ;;
esac
