#!/bin/bash
#
# This script created by Kingman Tam for Build Script Exercise 3.  Script started on 08/13/22. Script submitted on 8/18/22.
#
# This script will create a user in the group 'GitAcc'
# This script can be run on it's own but will also run at the beginning of 'buildscript3bv2.sh' if both files are placed in the users bin folder
# or if both files are in the same folder but 'buildscript3bv2' is modified.  **See note in 'buildscript3bv2.sh'**
#

echo "--------------------"
echo "This tool will create a user in group 'GitAcc'"
echo "You MUST be a superuser to run this program"
echo "--------------------"
echo "checking for superuser access"
echo "--------------------"

sleep 1

if [ $UID != 0 ]; then 
echo "Superuser not detected.  Exiting command."
echo "--------------------"
exit 1
else
echo "Superuser detected"
echo "--------------------"
echo "Please enter a user name"
echo "--------------------"
read uname
echo "--------------------"
echo "Please enter a password"
echo "--------------------"
read password
echo "--------------------"
echo "You are about to create an account with username:" $uname "and password:" $password
echo "--------------------"
read -p "Press enter to continue or type 'exit' to cancel creating a user" ans1
echo "--------------------"
fi

if [[ $ans1 = "exit" ]]; then
echo "User not created. Exiting command."
echo "--------------------"

exit 0

else 
groupadd -f GitAcc
useradd -m -g GitAcc -s /bin/bash $uname
echo $uname:$password | chpasswd
sleep 1
echo "User: "$uname "created in Group: GitAcc"
echo "--------------------"
echo "Exiting command"
echo "--------------------"
exit 0
fi
