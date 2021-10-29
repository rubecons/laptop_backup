#!/bin/bash

#name:		laptot_backup.sh
#description:	Script de sauvegarde automatique de l'ordinateur, lancé à l'init
#date:		19 oct 2021
#author:	rubecons


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


#calcul différence en heures entre 2 dates
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


#test du nombre de paramètres
if [ $# -eq 0 ]
then
	echo $0
	echo "pas de paramètres"
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
	lastSave="jamais"
	zenity --question --ellipsize --title="laptop-backup" --text="Les informations de sauvegarde n'existent pas, voulez-vous renseigner l'emplacement du disque dur sur lequel effectuer la sauvegarde ?"
	if [ $? = 0 ]
	then		
		hardDriveName=$"`zenity --file-selection --directory --title="veuillez choisir le disque dur sur lequel effectuer la sauvegarde"`"
	else
		exit 1
	fi

	let "minDelaySave=24*`zenity --scale --title="laptop backup" --text="veuillez choisir la période des sauvegardes en jours" --value=3 --min-value=1 --max-value=10 --step=1`"
fi

echo "lastSave = $lastSave, hardDriveName = $hardDriveName, minDelaySave = $minDelaySave"

#if the file of the date does not exist, or if the time since the last save is greater than minDelaySave, we first need to see if the drive is connected before starting the save
while [ ! -e $hardDriveName ]
do
	#notify-send "Il est nécessaire de connecter le disc dur pour effectuer la sauvegarde"
	zenity --warning --ellipsize --timeout=3 --title="laptop backup" --text="Il est nécessaire de connecter le disque dur pour effectuer la sauvegarde"
	#opython3 popupConnectDisc.py
done

notify-send "Démarrage de la sauvegarde des documents"

#sauvegarde
rsync -avi --exclude-from=./excludeRsync --files-from=./directoriesToRsync --stats /media/dev/$hardDriveName

notify-send "Sauvegarde terminée" "Prochaine sauvegarde dans $minDelaySave heures, merci"

#on enregistre la date actuelle comme étant la date de lastSave, et on réécrit le fichier save.txt
lastSave=`date +%Y-%m-%d-%H-%M`
echo "lastSave=$lastSave" > save.txt
echo "hardDriveName=$hardDriveName" >> save.txt
echo "minDelaySave=$minDelaySave" >> save.txt


echo "Sauvegarde terminée" "Prochaine sauvegarde dans $minDelaySave heures, merci"

echo "Appuyez sur une touche pour quitter le terminal"
read
exit 0



#author : rubecons