#!/bin/bash

# Top best public trackers: https://github.com/ngosang/trackerslist

TRANSMISSION_REMOTE='/usr/bin/transmission-remote'
LIVE_TRACKERS_LIST_CMD='curl -s --url https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best_ip.txt'


if [ $# -eq 0 ]; then
    echo -e "\n\nThis script expects some parameter. Usage:"
    echo -e ".addtracker \$number\t-\tAdd tracker to Torrent of $number"
    echo -e ".addtracker \$name\t-\tAdd tracker to the first Torrent with the $name"
    echo -e "\nI have the following Torrents running on Transmission:\n"
    $TRANSMISSION_REMOTE -l | sed -n 's/\(^.\{4\}\).\{64\}/\1/p'
    exit 1
fi

# return number by searching
# transmission-remote -l | grep -i "Girls" | sed -n 's/ *\([0-9]\+\).*/\1/p'

INDEX=$1

if [ "${INDEX//[0-9]}" != "" ] ; then
        TORRENT=`$TRANSMISSION_REMOTE -l|grep -i $1`
        INDEX=`echo $TORRENT | sed -n 's/\([0-9]\+\).*/\1/p'`

        if [ "$INDEX" != "" ] ; then
                echo "I found the following torrent:"
                $TRANSMISSION_REMOTE -l | sed -n 's/\(^.\{4\}\).\{64\}/\1/p' | grep -i $1
        fi

fi

if [ "${INDEX//[0-9]}" != "" -o "$INDEX" = "" ] ; then
        echo "I didn't find a torrent with the text: $1"
        $TRANSMISSION_REMOTE -l | sed -n 's/\(^.\{4\}\).\{64\}/\1/p'
        exit 1
fi

$LIVE_TRACKERS_LIST_CMD | while read TRACKER
do
        if [ "$TRACKER" != "" ]; then
                echo "Adding $TRACKER"
                $TRANSMISSION_REMOTE -t $INDEX -td $TRACKER
        fi
done
