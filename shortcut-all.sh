#!/bin/bash

#Variable for PS4
COL_NORM="$(tput setaf 9)"
COL_GREEN="$(tput setaf 2)"
T_BOLD="$(tput bold)"
COL_NORMAL="\033[0m"
BOLD="\033[1;33m"
BLINK="$(tput blink)"

#set -x (echo the command), PS4 (change default prompt statement + to green >>>)
PS4="\n${T_BOLD}${COL_GREEN}${BLINK}>>> ${COL_NORMAL}"; set -x

#Variable for dialog
DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0
CHOICE_HEIGHT=4

#Variable Dialog options
#You can modify, add next options
BACKTITLE="Linux Shortcut"
TITLE="Menu"
MENU="Choose one of the following options:"
OPTIONS=(1 "Show Linux Version"
         2 "Show RAM & HD Size"
         3 "Show File Size"
         4 "ZeroFree Hardisk (Use in safemode)")

#Function display result of command
#Height & Width "-1" value to max 100% display area 
display_result() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result" -1 -1
}

#Function display result of command
#Height & Width "0" value to fluid 
display_result_fluid() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result" 0 0
}

#Show Start Dialog & go back after done
while true; do
  exec 3>&1
  selection=$(dialog \
    --backtitle "$BACKTITLE" \
    --title "$TITLE" \
    --clear \
    --cancel-label "Exit" \
    --menu "$MENU"\
     $HEIGHT $WIDTH $CHOICE_HEIGHT \
     "${OPTIONS[@]}" \
     2>&1 1>&3)
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL)
      clear
      echo "Program terminated."
      exit
      ;;
    $DIALOG_ESC)
      clear
      echo "Program aborted." >&2
      exit 1
      ;;
  esac
  
  #Add custom command (shortcut) here
  case $selection in
    1 )
      result=$(cat /proc/version)
      display_result "System Information"
      result=$(cat /etc/issue)
      display_result "System Information"
      ;;
    2 )
      result=$(free -m)
      display_result "Show RAM Size"
      result=$(df -h)
      display_result "Show DISK Size"
      ;;
    3 )
        user_input=$(\
        dialog --title "Chose Location" \
               --inputbox "Enter File/Directory Location:" 8 40 "/" \
               3>&1 1>&2 2>&3 3>&- \
        )
      result=$(du -ha -d 1 "$user_input" | sort -hr)
      display_result_fluid "Show File Size"
      ;;
    4 )
        user_input=$(\
        dialog --title "Chose Location" \
               --inputbox "Enter File/Directory Location:" 8 40 "/" \
               3>&1 1>&2 2>&3 3>&- \
        )
        result=$(systemctl stop systemd-journald.socket)
        display_result_fluid "ZeroFree Hardisk A"
        result=$(systemctl stop systemd-journald.service)
        display_result_fluid "ZeroFree Hardisk B"
        result=$(swapoff -a)
        display_result_fluid "ZeroFree Hardisk C"
        result=$(mount -n -o remount,ro -t ext2 "$user_input" /)
        display_result_fluid "ZeroFree Hardisk D"
        result=$(zerofree -v "$user_input")
        display_result_fluid "ZeroFree Hardisk E"
      ;;
  esac
done
