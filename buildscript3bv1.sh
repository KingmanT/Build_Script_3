#!/bin/bash
#
# This script was created by Kingman Tam for Build Script Exercise 3.  Script started on 8/15/22
#
# This script will search a document for sensitive information (phone number, SSN, emails) before adding and commiting it to a GitHub Repo
#
# Update 8/16/22- added Error Handling.  If file cannot be added or committed to Git, user will be notified and script will exit.
# Update 8/17/22- added Error Handling.  If file does not exist, user will be notified and script will exit.
#
# Issues: Error handling for 'git push' doesn't work.  Successful push still returns errors (tested with: "git push 2> error.txt") will revisit in later version
# 	  Next version will incorporate buildscript3av1

echo "--------------------"
echo "This tool will check your file for sensitive"
echo "information before uploading it to GitHub"
echo "--------------------"
echo "Please enter the location and name of the file"
echo "you would like to to commit (absolute path)"
echo "--------------------"
read file
echo "--------------------"
echo "Checking file for sensitive data. Please wait.."
echo "--------------------"
sleep 1

phone1=`grep -Eo '[[:digit:]]{3}\-[[:digit:]]{4}' $file`
phone2=`grep -Eo '[[:digit:]]{3} [[:digit:]]{4}' $file`
phone3=`grep -Eo '[[:digit:]]{10}' $file`
phone4=`grep -Eo '[[:digit:]]{7}' $file`
ssn1=`grep -Eo '[[:digit:]]{9}' $file`
ssn2=`grep -Eo '[[:digit:]]{3}\-[[:digit:]]{2}\-[[:digit:]]{4}' $file`
email=`grep -Eo '[[:alnum:]]+\@[[:alnum:]]+\.+[[:alpha:]]+' $file`

if [[ -n $phone1 || -n $phone2 || -n $phone3 || -n $phone4 ]]; then
echo "Search results:"
grep -Eo '[[:digit:]]{3}\-[[:digit:]]{4}' $file
grep -Eo '[[:digit:]]{3} [[:digit:]]{4}' $file
grep -Eo '[[:digit:]]{10}' $file
grep -Eo '[[:digit:]]{7}' $file
echo "--------------------"
echo "Above results match a pattern associated with phone numbers"
echo "Please be aware that sending sensitive information can result in security vulnerabilities."
echo "--------------------"
echo "Please enter 'continue' to verify that you want to continue with the upload process or 'exit' to cancel"
echo "--------------------"
read confirm
echo "--------------------"
fi 

if [[ -n $ssn1 || -n $ssn2 ]]; then
echo "Search results:"
grep -Eo '[[:digit:]]{9}' $file
grep -Eo '[[:digit:]]{3}\-[[:digit:]]{2}\-[[:digit:]]{4}' $file
echo "--------------------"
echo "Above results match a pattern associated with Social Security Numbers"
echo "Please be aware that sending sensitive information can result in security vulnerabilities."
echo "--------------------"
echo "Please enter 'continue' to verify that you want to continue with the upload process or 'exit' to cancel"
echo "--------------------"
read confirm
echo "--------------------"
fi

if [[ -n $email ]]; then
echo "Search results:"
grep -Eo '[[:alnum:]]+\@[[:alnum:]]+\.+[[:alpha:]]+' $file
echo "--------------------"
echo "Above results match a pattern associated with emails"
echo "Please be aware that sending sensitive information can result in security vulnerabilities."
echo "--------------------"
echo "Please enter 'continue' to verify that you want to continue with the upload process or 'exit' to cancel"
echo "--------------------"
read confirm
echo "--------------------"
fi

greperr=`grep [[:alnum:]] $file 2>&1> /dev/null`
	if [[ -n $greperr ]]; then
	echo "--------------------"
	echo "Error searching for file.  Please check file name and path and try again."
	echo "Exiting command"
	echo "--------------------"
	exit 1
	fi

if [[ -z $phone1 && -z $phone2 && -z $phone3 && -z $phone4 && -z $ssn1 && -z $ssn2 && -z $email ]]; then
echo "No content matching sensitive data found in file"
echo "--------------------"
echo "Please enter 'continue' to verify that you want to continue with the upload process or 'exit' to cancel"
echo "--------------------"
read confirm
echo "--------------------"
fi

if [[ $confirm = "exit" ]]; then
echo "Exiting command"
echo "--------------------"
exit 0

elif [[ $confirm = "continue" ]]; then
echo "Please wait while" $file "is added to the Git Stage.."
echo "--------------------"
sleep 1
git add $file
echo "--------------------"
adderr=`git add $file 2>&1> /dev/null`

	if [[ -n $adderr ]]; then
	echo "Unable to add '"$file"' to stage. Please check if file is in the proper Git Directory and try again."
	echo "Exiting command"
	echo "--------------------"
	exit 1
	else
	echo $file "successfully added to stage"
	echo "--------------------"
	fi

echo "Please enter short description of file or change to be committed."
echo "--------------------"
read commsg
echo "--------------------"
echo "Please wait while" $file "is being committed.."
echo "--------------------"
sleep 1
git commit -m "$commsg"
echo "--------------------"
comerr=`git commit -m "$commsg" 2>&1> /dev/null`

	if [[ -n $comerr ]]; then
	echo "--------------------"
	echo "Unable to commit '"$file"'. Please check Git Status and try again."
	echo "Exiting command"
	echo "--------------------"
	exit 1
	else
	echo $file "successfully committed"
	echo "--------------------"
	fi

echo "Would you like to push your file into the remote repository? (yes/no)"
echo "--------------------"
read gpush
echo "--------------------"
gpushc1=`echo $gpush | cut -c 1 | tr [[:upper:]] [[:lower:]]`

if [[ $gpushc1 = "y" ]]; then
echo "Preparing to push" $file "to remote repository.."
echo "--------------------"
git push
echo "--------------------"
sleep 1
#gpusherr=`git push 2>&1> /dev/null`

#	if [[ -n $gpusherr ]]; then
#	echo "--------------------"
#	echo "unable to push '"$file"'. Please check Git Status and try again."
#	echo "Exiting command"
#	exit 1
#	else
	echo $file "successfully pushed to remote repository.  Exiting command"
	echo "--------------------"
	exit 0
	fi

else
echo $file "not pushed to remote repository.  Exiting command"
echo "--------------------"
exit 0
fi

else
echo "Invalid option. Exiting command"
echo "--------------------"

exit 0
fi
