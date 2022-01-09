#!/bin/bash

#name:		    laptot_backup.sh
#description:	Script for automatic backup of computer, run at init
#date:	     	19 oct 2021
#author:    	rubecons


#algorithm :
#a file saves the user's preferrences
#the script reads the preferrences file, if it exists
#if the file does not exist, popups appear to ask the user the delay between 2 backups, and the backup harddrive
#if the last backup occurred enough time before the current time (>48h ?), or if there was not preferrence file (and thus no date of the last backup)
#then looks if the hard drive is connected
#else exits
#if the hard drive is not connected to the computer, a popup appears and asks the user to connect the harddrive
#the popup disappears automatically if hardrive is connected
#backup starts
#saves the current date of backup in the preferrences file, or creates it if does not exist


#calculation of the very approximative difference  between 2 dates (in hours)
diff_between_date_now_hours()
{
	echo "diff_between_date_now_hours"

	dateTime=`date +%Y-%m-%d-%H-%M`

	yearNow=`echo $dateTime | cut -d - -f 1`
	monthNow=`echo $dateTime | cut -d - -f 2`
	dayNow=`echo $dateTime | cut -d - -f 3`
	hourNow=`echo $dateTime | cut -d - -f 4`
	minuteNow=`echo $dateTime | cut -d - -f 5`

	echo "$yearNow $monthNow $dayNow $hourNow $minuteNow"

	yearPast=`echo "$1" | cut -d - -f 1`
	monthPast=`echo "$1" | cut -d - -f 2`
	dayPast=`echo "$1" | cut -d - -f 3`
	hourPast=`echo "$1" | cut -d - -f 4`
	minutePast=`echo "$1" | cut -d - -f 5`

	echo "$yearPast $monthPast $dayPast $hourPast $minutePast"

	diffYear=`bc <<< $yearNow-$yearPast`
	diffMonth=`bc <<< $monthNow-$monthPast`
	diffDay=`bc <<< $dayNow-$dayPast`
	diffHour=`bc <<< $hourNow-$hourPast`
	diffMinute=`bc <<< $minuteNow-$minutePast`

	#diff totale de minutes c'est = ((((diffYear*12 + diffMonth) * 30.437 + diffDay)*24 + diffHour)*60 +diffMinute)
	#diff totale d'heures, diviser le nombre de minutes par 60

	finalDiffHour=$"`bc <<< "(((((((($diffYear*12)+$diffMonth)*30.437)+$diffDay)*24)+$diffHour)*60)+$diffMinute)/60"`"
	echo finalDiffHour = $finalDiffHour

	return $finalDiffHour
}


#tests the number of parameters
if [ $# -eq 0 ]
then
	echo $0
	echo "no parameters"
else
	# for parameter in `seq 1 $#` do
	# 	case $1 in
	# 		"--install")
	# 		bInstall=1
	# 		;;
	# 		"--include")
	# 		bInclude=1
	# 		;;
	# 		"--exclude")
	# 		bExclude=1
	# 		;;
	# 		*)
	# 		;;
	# 	esac
	# 	shift
	# done
	echo $0
	#--install

	#--include
	#--exclude
fi

#test if the file containing the data of the script exists
if  [ -e save.txt ]
then
	#reads data from the save.txt file
	lastSave=$"`grep lastSave save.txt | cut -d = -f2`"
	hardDriveName=$"`grep hardDriveName save.txt | cut -d = -f2`"
	minDelaySave=$"`grep minDelaySave save.txt | cut -d = -f2`"

	#calculates the hours since the last save, if we are within the delay, nothing to do -> exit
	diff_between_date_now_hours $lastSave
	if [ $? -lt $minDelaySave ]
	then
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

#if the file of the date does not exist, or if the time since the last save is greater than minDelaySave, we first need to see if the drive is connected before starting the save
while [ ! -e $hardDriveName ]
do
	zenity --warning --ellipsize --timeout=3 --title="laptop backup" --text="It is necessary to connect the hard drive to perform the backup"
	#opython3 popupConnectDisc.py
done

notify-send "Starting backup"

#backup
#rsync -avi --stats --exclude-from=excludeRsync --files-from=directoriesToRsync $hardDriveName
rsync -avi --stats --exclude-from=excludeRsync ~/Documents ~/Téléchargements/interessant $hardDriveName


notify-send "Backup completed" "Next backup in $minDelaySave hours, thank you"

#on enregistre la date actuelle comme étant la date de lastSave, et on réécrit le fichier save.txt
lastSave=`date +%Y-%m-%d-%H-%M`
echo "lastSave=$lastSave" > save.txt
echo "hardDriveName=$hardDriveName" >> save.txt
echo "minDelaySave=$minDelaySave" >> save.txt


echo "Backup completed" "Next backup in $minDelaySave hours, thank you"

echo "Press any key to exit the terminal"
read
exit 0



#author : rubecons
