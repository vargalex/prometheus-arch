#!/bin/bash

function testServer() {
   if [ -f "/usr/bin/curl" ]; then
      curl -Is -o /dev/null $1
   else
      if [ -f "/usr/bin/wget" ]; then
         wget --spider -o /dev/null $1
      else
         echo "No download utility (curl/wget) installed! Exiting."
         exit 0
      fi
   fi
}

RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;36m'
YELLOW='\033[1;33m'
NONE='\033[0m'
RED0='\033[0;31m'
GREEN0='\033[0;32m'
PROMETHEUS="$BLUE--------------------------------------------------------------------$NONE$GREEN
    0000  0000  00000 0    0 00000 00000 0   0 00000 0   0 00000
    0   0 0   0 0   0 00  00 0       0   0   0 0     0   0 0     
    0000  0000  0   0 0 00 0 00000   0   00000 00000 0   0 00000 
    0     0  0  0   0 0    0 0       0   0   0 0     0   0     0 
    0     0   0 00000 0    0 00000   0   0   0 00000 00000 00000$NONE
$BLUE-------------------------------------------------------------------- $NONE"
PROMETHEUS2="update script"  
clear
echo -e "$PROMETHEUS"
echo
DIRP=`pwd`
export DIRP
# Prepare directories
rm -R $DIRP/scripts &>/dev/null
mkdir $DIRP/scripts
rm -R $DIRP/configs &>/dev/null
mkdir $DIRP/configs
rm -R $DIRP/files &>/dev/null
mkdir $DIRP/files
rm -R $DIRP/logs &>/dev/null
mkdir $DIRP/logs


   testServer http://google.com

   if [ $? -eq 0 ]; then
       internet_connection=ok
   else
       internet_connection=error
   fi
   if [ "$internet_connection" == "error" ]
   then
      echo -e "$RED Maybe there is no internet connection! $NONE"
      while true; do
         read -p " Continue anyway? " yn
         case $yn in
            [Yy]* ) echo -e "$NONE"; break;;
            [Nn]* ) echo -e "$NONE"; exit;;
                * ) echo -e " Please enter yes or no.";;
         esac
      done
   fi

   testServer http://pm.freize.net

   if [ $? -eq 0 ]; then
       internet_connection2=ok
   else
       internet_connection2=error
   fi

   if [ "$internet_connection2" == "error" ]
   then
      echo "$RED The remote server pm.freize.net) not responding! $NONE"
      while true; do
         read -p " Continue anyway? " yn
         case $yn in
            [Yy]* ) echo -e "$NONE"; break;;
            [Nn]* ) echo -e "$NONE"; exit;;
                * ) echo -e " Please enter yes or no.";;
         esac
      done
   fi
   #check the dependencies and exit if everything is installed
   requiredPackages="ca-certificates gawk texinfo pkgconf gettext automake libtool bison flex zlib gmp mpfr libmpc git zip sshpass mc curl python expect bc inetutils openssh tftp-hpa libid3tag gperf libtool perl-archive-zip python-docutils help2man ncurses gnu-netcat doxygen graphviz"
   missingPackages=""
   #pacman -Qi ca-certificates gawk texinfo pkgconf gettext automake libtool bison flex zlib gmp mpfr libmpc git zip sshpass mc curl python expect bc inetutils openssh tftp-hpa libid3tag gperf libtool perl-archive-zip python-docutils help2man ncurses gnu-netcat >/dev/null 2>&1 && break 
   #sudo pacman -S ca-certificates gawk texinfo pkgconf gettext automake libtool bison flex zlib gmp mpfr libmpc git zip sshpass mc curl python expect bc inetutils openssh tftp-hpa libid3tag gperf libtool perl-archive-zip python-docutils help2man ncurses gnu-netcat
   for package in $(pacman -Q $requiredPackages 2>&1 > /dev/null | cut -f 2 -d "'")
   do
      missingPackages="$missingPackages$package "
   done
   if [ "$missingPackages" != "" ]; then
      echo -e "${YELLOW} Missing packages$NONE: $RED$missingPackages$NONE"
      echo -e "$YELLOW Install the software, you need to enter a password from $NONE"
      echo -e "$YELLOW your Linux account to install packages. $NONE"
      sudo pacman -S $missingPackages
      if [ $? -ne 0 ]; then 
         exit 0
      fi
   fi
   wget -O update.tar http://pm.freize.net/scripts/update.tar &>/dev/null
   wget -O files/loki.tar http://pm.freize.net/scripts/loki.tar &>/dev/null
   tar -xvf $DIRP/files/loki.tar configs/git.sh -C configs >/dev/null 2>&1
   tar -xvf $DIRP/files/loki.tar configs/uboot.sh -C configs >/dev/null 2>&1
   tar -xvf update.tar
   rm -f update.tar
   #./scripts/up2.sh
   echo "#!/bin/sh" > ./scripts/up2.sh
   echo -e "$BLUE Script :$NONE$GREEN      OK $NONE"
   sleep 0.1
   exec ./start.sh
