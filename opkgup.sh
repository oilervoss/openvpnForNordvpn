#!/bin/sh
#
# This will update opkg and upgrade the found upgradable packages 

echo -e "\n\e[36mI will update opkg now \e[32m\n"

opkg update

LIST=`opkg list-upgradable | cut -f 1 -d ' '`

if [ $? -ne 0 -o "$LIST" = "" ]; then
        echo -e "\n\e[0;31mNothing to do.\e[0m\n\n"
        exit
fi

echo -e "\e[36;1mI've found the following as upgradable:\e[0;32m\n$LIST"

echo -en "\e[0;36mAre you sure to upgrade them now (y/\e[4mn\e[0;36m) \e[5m?\e[0m "
read -n 1 OPT
echo
if [ "$OPT" = "y" ]; then
        echo -e "\n\e[0;36;1mI'm going to upgrade the packages now\n\e[0;32m"
        opkg upgrade `echo $LIST|tr '\n' ' '`
fi

echo -e "\e[0m"
