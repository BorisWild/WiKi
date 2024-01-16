#!/bin/bash

#execute the script
#make it executable
#chmod 775 basicscript.sh
#./basicscript.sh
#or just
#bash basicscript.sh

monitorDef="LVDS-1"
textInBright="Input brightnes (ex: 0.5):"

echo "Brightness settings"
echo "Default screen: $monitorDef"
echo "For changing use -s flag (ex: bash brigtness -s)"

#on load set default brightness=0.5
echo	"Setting brightness: 0.5 , Monitor: $monitorDef"
xrandr --output $monitorDef --brightness 0.5
	
function setBrightness() {
	if [ -z "$1" ]; then
		echo $textInBright
		read brightness
	else
		brightness=$1
	fi

	#set monitor
	if [ -z "$monitorNew" ]; then
		monitor=$monitorDef
	else
		monitor=$monitorNew
	fi
		
	#if brightness not set, default brightness=0.5
	if [ -z "$brightness" ] && ! [ -z "$monitor" ]; then
		echo	"Brightness: 0.5 , Monitor: $monitor"
		xrandr --output $monitor --brightness 0.5
	else
		#check brightness is numeric
		if [[ $brightness =~ ^[0-9\.]+$ ]]; then
			echo	"Brightness: $brightness, Monitor: $monitor"
			xrandr --output $monitor --brightness $brightness
		else
			echo "Wrong params. Must be a number or add argument -s."
			exit 1		
		fi
	fi
}

#if run without params ex: bash brightness
#and first argument is empty length
if [ -z "$1" ]; then
	setBrightness
else
	if [ $1 == "-s" ]; then
		xrandr | grep " connected" | cut -f1 -d " "
		echo "Input monitor name:"
		read monitorNew
		setBrightness
	else
		setBrightness $1
	fi
fi

echo "OK? y/n"
read answer
if [ $answer == "n" ]; then
	setBrightness
fi

exit 1	
