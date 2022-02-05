#!/bin/bash

#name:          laptot_backup.sh
#description:   Script for automatic backup of computer, run at init
#date:          19 oct 2021
#author:        rubecons


#algorithm :
# a file saves the user's preferrences
# the script reads the preferrences file, if it exists
# if the file does not exist, popups appear to ask the user the delay between 2 backups, and the backup harddrive
# if the last backup occurred enough time before the current time (>48h ?), or if there was not preferrence file (and thus no date of the last backup)
# then looks if the hard drive is connected
# else exits
# if the hard drive is not connected to the computer, a popup appears and asks the user to connect the harddrive
# the popup disappears automatically if hardrive is connected
# backup starts
# saves the current date of backup in the preferrences file, or creates it if does not exist

#TODO
#allow to add include files in the include list (with an HMI)
#allow to add exclude files in the exclude list (with an HMI)
#add an icon in desktop and/or menu and/or topbar
#
#
#
#calculation of the very approximative difference between 2 dates (in hours)
diff_between_date_now_hours()
{
	#echo "diff_between_date_now_hours"

	dateTime=`date +%Y-%m-%d-%H-%M`

	yearNow=`echo $dateTime | cut -d - -f 1`
	monthNow=`echo $dateTime | cut -d - -f 2`
	dayNow=`echo $dateTime | cut -d - -f 3`
	hourNow=`echo $dateTime | cut -d - -f 4`
	minuteNow=`echo $dateTime | cut -d - -f 5`

	#echo "$yearNow $monthNow $dayNow $hourNow $minuteNow"

	yearPast=`echo "$1" | cut -d - -f 1`
	monthPast=`echo "$1" | cut -d - -f 2`
	dayPast=`echo "$1" | cut -d - -f 3`
	hourPast=`echo "$1" | cut -d - -f 4`
	minutePast=`echo "$1" | cut -d - -f 5`

	#echo "$yearPast $monthPast $dayPast $hourPast $minutePast"

	diffYear=`bc <<< $yearNow-$yearPast`
	diffMonth=`bc <<< $monthNow-$monthPast`
	diffDay=`bc <<< $dayNow-$dayPast`
	diffHour=`bc <<< $hourNow-$hourPast`
	diffMinute=`bc <<< $minuteNow-$minutePast`

	#diff total of minutes it is = ((((diffYear*12 + diffMonth) * 30.437 + diffDay)*24 + diffHour)*60 +diffMinute)
	#diff total of hours, divide the number of minutes by 60

	finalDiffHour=$"`bc <<< "(((((((($diffYear*12)+$diffMonth)*30.437)+$diffDay)*24)+$diffHour)*60)+$diffMinute)/60"`"
	echo $finalDiffHour
	#return "$finalDiffHour"
}



#############################################################
#############################################################

bInstall=0
bBackup=0
bInclude=0
bExclude=0
bHelp=0

scriptPath="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
logFile='log.txt'
logErrorFile='error.txt'

#tests the number of parameters
if [ $# -eq 0 ]
then
	echo $0
	echo "To use the laptop_backup script, please use the following options"
	echo "--install          - The first time you use the script, it will set the automaticity of the script each time you enter the session"
	echo "--backup           - To perform the backup"
	echo "--include          - To add directories to backup list"
	echo "--exclude          - To add directories to exclude list, they won't be backuped"
	echo "--help              - To show this menu"
	
	exit 0
else
	 for parameter in $*
	 do
	 	case $parameter in
	 		"--install")
	 		bInstall=1
	 		;;
	 		"--backup")
	 		bBackup=1
	 		;;
			"--include")
			bInclude=1
	 		echo TODO
			;;
			"--exclude")
			bExclude=1
	 		echo TODO
			;;
			"--help")
	 		bHelp=1
			;;
	 		*)
	 		echo "unknown parameter: " $parameter
	 		;;
	 	esac
		shift
	done
fi

#--help
if [ $bHelp -eq 1 ]
then
	echo "To use the laptop_backup script, please use the following options"
	echo "--install          - The first time you use the script, it will set the automaticity of the script each time you enter the session"
	echo "--backup           - To perform the backup"
	echo "--include          - To add directories to backup list"
	echo "--exclude          - To add directories to exclude list, they won't be backuped"
	echo "--help              - To show this menu"
	
	exit 0
fi

#--install
if [ $bInstall -eq 1 ]
then
	# if install option, the script adds a line in .profile script that runs this script at session opening
	scriptName=`echo $0 | cut -d / -f 2`
	echo $scriptPath
	echo $scriptName
	
	isPresentInProfile=`grep -rn "$scriptName" /home/$USER/.profile | wc -l`
	
	if [ $isPresentInProfile -eq 0 ]
	then
		echo "script is not present in .profile/.bashrc"
		echo "exec gnome-terminal -e \"$scriptPath/$scriptName --backup 1>$scriptPath/$logFile 2>$scriptPath/$logErrorFile \"&" >> /home/$USER/.profile
		echo "script has been added in .profile/.bashrc"
	else
		echo "script is already present in profile/bashrc"
	fi
fi

#--include
if [ $bInclude -eq 1 ]
then
	python3 $scriptPath/popupInclude.py /home/$USER
fi

#--exclude

#--backup
if [ $bBackup -eq 1 ]
then
	#test if the file containing the data of the script exists
	if  [ -e $scriptPath/save.txt ]
	then
		#reads data from the save.txt file
		lastSave=$"`grep lastSave $scriptPath/save.txt | cut -d = -f 2`"
		hardDriveName=$"`grep hardDriveName $scriptPath/save.txt | cut -d = -f 2`"
		minDelaySave=$"`grep minDelaySave $scriptPath/save.txt | cut -d = -f 2`"

		echo "lastSave = $lastSave"
		echo "hardDriveName = $hardDriveName"
		echo "minDelaySave = $minDelaySave"
		
		#calculates the hours since the last save, if we are within the delay, nothing to do -> exit
		#diff_between_date_now_hours $lastSave
		
		#resultDiff=$?
		resultDiff=$(diff_between_date_now_hours $lastSave)
		echo "$resultDiff"
		if [ "$resultDiff" -lt "$minDelaySave" ]
		then
			echo "exit, last backup is too recent"
			echo "Press any key to exit the terminal"
			read
			exit 0
		fi
	else
		lastSave="never"
		zenity --question --ellipsize --title="laptop-backup" --text="Backup data does not exist, do you want to fill in the location of the hard drive to back up?"
		if [ $? = 0 ]
		then		
			hardDriveName=$"`zenity --file-selection --directory --title="Please choose the hard drive to back up to"`"
		else
			exit 1
		fi

		let "minDelaySave=24*`zenity --scale --title="laptop backup" --text="Please choose the backup period in days" --value=3 --min-value=1 --max-value=10 --step=1`"
	fi

	echo "lastSave = $lastSave, hardDriveName = $hardDriveName, minDelaySave = $minDelaySave"

    isHardriveConnected=1
	
    if [ ! -e $hardDriveName ]
    then
        #if the file of the date does not exist, or if the time since the last save is greater than minDelaySave, we first need to see if the drive is connected before starting the save
        # popupConnectDisc.py returns 0 if the hardrive is connected else 1
        python3 $scriptPath/popupConnectDisc.py $hardDriveName
        isHardriveConnected=$?
    fi

    if [ 0 -eq $isHardriveConnected ]
    then

        #backup will start so we can delete the log files of last backup, thus, these files are never backuped
        echo "Deletion of log and error files : $logFile , $logErrorFile"
        rm $scriptPath/$logFile
        rm $scriptPath/$logErrorFile

        notify-send "Starting backup"
        echo "Starting backup"
        echo "Please wait..."
        
        # backup
        # rsync output and errors are saved in log files. These files are located in the script directory, and will be deleted before next backup
        rsync -avi --stats --recursive --exclude-from="$scriptPath/excludeRsync.txt" --files-from="$scriptPath/directoriesToRsync.txt" /home/$USER $hardDriveName 1>$scriptPath/$logFile 2>$scriptPath/$logErrorFile

        
        if [ $? -eq "0" ]
        then
            notify-send "Backup completed" "Next backup in $minDelaySave hours, thank you"

            #saves the current date as the lastSave date, and re-write the save.txt file
            lastSave=`date +%Y-%m-%d-%H-%M`
            echo "lastSave=$lastSave" > $scriptPath/save.txt
            echo "hardDriveName=$hardDriveName" >> $scriptPath/save.txt
            echo "minDelaySave=$minDelaySave" >> $scriptPath/save.txt


            echo "Backup completed" "Next backup in $minDelaySave hours, thank you"
        else
            echo "backup failed"
            echo "log files (log.txt and error.txt) are loctaed in $scriptPath/"
        fi
    else
        echo "Not Now"
    fi
	
	echo "Press any key to exit the terminal"
	read
fi

exit 0



#author : rubecons
