# laptop_backup

## Introduction

Short Bash script for automatic and periodic backups for your computer/laptop

You can - of course - clone this project, and modify it.
If you find intersting ideas / improvments for this project, I am very interested, and please feel free to tell me, I could grant you a push access

If you have any question, please feel free to contact me on github

Thanks

Rubecons

## Functionnalities

- Performs backups of the computer it is installed on, automatically at session start, at a fixed frequency
- Folders/files to backup are defined in a file in project directory
- At session start, a terminal runs the programs, and if the time between the last backup is shorter than the choosen period, then the program terminates, else checks if the harddrive is connected.
- If the harddrive is connected, backup starts, else, a popup appears, and asks the user to connect the harddrive. Once the hardcrive is connected, the popup disappears automatically and backup starts
- Logs and error are stored in files (log.txt and error.txt) located in the project's directory, and renewed at every new backup
- Aliases exist and are automatically set at installation, and allow to call the script directly
    - ***backup*** : runs backup
    - ***backup-log*** : shows the log file of last backup
    - ***backup-error*** : shows the error log file of last backup

### TODO
Add an icon on desktop at installation, to be able to call the script without terminal
add a popup to choose the files to include to bbackup in a GUI

## Options - how to use the script
To use the laptop_backup script, please use the following options

    --install          - The first time you use the script, it will set the automaticity of the script each time you enter the session
    --backup           - To perform the backup
    --include          - To add directories to backup list
    --exclude          - To add directories to exclude list, they won't be backuped
    --log              - To show the log   file of last backup
    --error            - To show the error file of last backup
    --help             - To show this menu


1. To install the project, first clone it on your computer.

2. The first time you use the script, please use the `--install` option. It will set the call of the script at session opening, and create the aliases. it will also ask you to set your preferences
```
./laptop_backup.sh --install
```

3. The preferences the script asks you to set are, the folder representing your hardrive (often located in Linux in /media/<session_name>/<harddrive_name>), and the frequence of backups

4. Then you can use the option `--backup` to peform a backup
```
./laptop_backup.sh --backup
```
Or call directly the alias `backup` from anywhere in you file tree (from a terminal of course) to run a backup