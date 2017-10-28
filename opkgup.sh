#!/bin/sh
#

echo -e "\n\e[36mI will update opkg now \e[32m\n"

opkg update

LIST=`opkg list-upgradable | sed -n 's/\([^ ]*\) -.*/\1/p'`

if [ "$LIST" = "" ] || [ $? -ne 0  ]; then
	echo -e "\n\e[31mNothing to do.\e[0m\n\n"
	exit
fi

echo -e "\e[36m\e[1mI've found upgradable the following:\e[21m\n$LIST"

echo -en "\e[36mAre you shure to upgrade now (y/\e[4mn\e[24m) \e[5m?\e[0m "
read -n 1 OPT
echo
if [ "$OPT" = "y" ]; then
	opkg upgrade `echo $LIST|tr '\n' ' '`
fi


