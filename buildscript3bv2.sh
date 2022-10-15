#!/bin/bash
#
# This script was created by Kingman Tam for Build Script Exercise 3.  Script started on 8/15/22.  Script submitted on 8/18/22.
#
# This script will search a document for sensitive information (phone number, SSN, emails) before adding and commiting it to a GitHub Repo
#
# Update 8/16/22- added Error Handling.  If file cannot be added or committed to Git, user will be notified and script will exit.
# Update 8/17/22- added Error Handling.  If file does not exist, user will be notified and script will exit.
# Update 8/18/22- added comments along script for readability and understanding.
#
# UPDATE V2- Added option to run buildscript3av1.sh at the beginning of script.
#
# !!!!!!NOTE!!!!!!
# both buildscript3bv2 AND buildscript3av1.sh MUST BE PUT INTO USERS BIN FOLDER!!!
# for testing purposes please put both .sh files into the same directory and then change line 31 to "sudo ./buildscript3av1.sh"
#
# Issues: - Error handling for 'git push' doesn't work.  Successful push still returns errors (tested with: "git push 2> error.txt") will revisit in later version
#	  - If multiple types of sensitive info (eg, SSN AND Email) are found, "exit" command won't terminate the script until the last one is displayed.  Caused by
# 	    shared '$confirm' 'if statement' at end of all searches.


## The script will first ask the user if they want to create a new user in the 'GitAcc' group and run 'buildscript3av1.sh' if they answer 'yes' ##

echo "--------------------"
echo "Would you like to create a user in the 'GitAcc' group? (yes/no)"
echo "--------------------"
read create
createc1=`echo $create | cut -c 1 | tr [[:upper:]] [[:lower:]]`

if [[ $createc1 = "y" ]]; then
sudo ~/bin/buildscript3av1.sh ## PLEASE CHANGE THIS LINE TO "sudo ./buildscript3av1.sh" FOR TESTING PURPOSES IF IT WILL NOT BE IN USERS BIN!!!
read -p "Please press enter to continue with file checker."
fi

## After the user is created (or not) the script continues and asks for a file to be checked ##

echo "--------------------"
echo "This tool will check your file for sensitive"
echo "information before uploading it to GitHub"
echo "--------------------"
echo "Please enter the location and name of the file"
echo "you would like to to commit"
echo "(absolute path unless file is in current directory)"
echo "--------------------"
read file
echo "--------------------"
echo "Checking file for sensitive data. Please wait.."
echo "--------------------"
sleep 1

## Variables were created for the different types of sensitive data AND the different ways that they can be formatted ##

phone1=`grep -Eo '[[:digit:]]{3}\-[[:digit:]]{4}' $file`
phone2=`grep -Eo '[[:digit:]]{3}\s[[:digit:]]{4}' $file`
phone3=`grep -Eo '[[:digit:]]{10}' $file`
phone4=`grep -Eo '[[:digit:]]{7}' $file`
ssn1=`grep -Eo '[[:digit:]]{9}' $file`
ssn2=`grep -Eo '[[:digit:]]{3}\-[[:digit:]]{2}\-[[:digit:]]{4}' $file`
ssn3=`grep -Eo '[[:digit:]]{3}\s[[:digit:]]{2}\s[[:digit:]]{4}' $file`
email=`grep -Eo '[[:alnum:]]+\@[[:alnum:]]+\.+[[:alpha:]]+' $file`

## First search is for phone numbers.  User will be notified if any are found and asked if they still want to continue ##

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

## Next search is for Social Security Numbers.  Users will be notified if any are found and asked if they still want to continue ##

if [[ -n $ssn1 || -n $ssn2 || -n $ssn3 ]]; then
echo "Search results:"
grep -Eo '[[:digit:]]{9}' $file
grep -Eo '[[:digit:]]{3}\-[[:digit:]]{2}\-[[:digit:]]{4}' $file
grep -Eo '[[:digit:]]{3}\s[[:digit:]]{2}\s[[:digit:]]{4}' $file
echo "--------------------"
echo "Above results match a pattern associated with Social Security Numbers"
echo "Please be aware that sending sensitive information can result in security vulnerabilities."
echo "--------------------"
echo "Please enter 'continue' to verify that you want to continue with the upload process or 'exit' to cancel"
echo "--------------------"
read confirm
echo "--------------------"
fi

## Last search is for E-Mails.  User will be notified if any are found and asked if they still want to continue ##

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

## 'grep' error handing added in case user enters a file name or path that does not exist ##

greperr=`grep [[:alnum:]] $file 2>&1> /dev/null`
	if [[ -n $greperr ]]; then
	echo "--------------------"
	echo "Error searching for file.  Please check file name and path and try again."
	echo "Exiting command"
	echo "--------------------"
	exit 1
	fi

## If no sensitive data is found in the file, user will be asked if they want to proceed with the upload process (add/commit/merge) ##

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

## If the user chooses to 'continue' the file will be added to the git stage ##

elif [[ $confirm = "continue" ]]; then
echo "Please wait while" $file "is added to the Git Stage.."
echo "--------------------"
sleep 1
git add $file
echo "--------------------"
adderr=`git add $file 2>&1> /dev/null`

## 'git add' error handing added in case the file fails to be added to the staging area ##

	if [[ -n $adderr ]]; then
	echo "Unable to add '"$file"' to stage. Please check if you and the file are in the proper Git Directory and try again."
	echo "Exiting command"
	echo "--------------------"
	exit 1
	else
	echo $file "successfully added to stage"
	echo "--------------------"
	fi

## After file is successfully added, user is prompted for a commit message before file is committed ##

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

## 'git commit' error handing added in case the file fails to be committed to the branch in the local repository ##

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

## After file is committed, user is asked if they want to push their local repository to the remote repository ##

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

## 'git push' error handing added in case there is an error with pushing the file.  Function does not work well enough yet but will be fixed in later update.  See 'Issues' section above. ##

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

if [[ $gpushc1 != "y" ]]; then
echo $file "not pushed to remote repository.  Exiting command"
echo "--------------------"
exit 0
fi

else
echo "Invalid option. Exiting command"
echo "--------------------"

exit 0
fi
