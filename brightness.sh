#!/bin/bash

#execute the script
#make it executable
#chmode 775 basicscript.sh
#./basicscript.sh
#or just
#bash basicscript.sh

monitorDef="LVDS-1"
textInBright="Input brightnes (ex: 0.5):"

echo "Brightness settings"
echo "Default screen: $monitorDef"
echo "For changing use -s flag (ex: bash brigtness -s)"


function setBrightness() {
	
  #if function exec without arguments
  
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
	
  #check brightness is numeric
	
  if [[ $brightness =~ ^[0-9\.]+$ ]]; then
		echo	"Brightness: $brightness, Monitor: $monitor"
		if ! [ -z "$brightness" ] && ! [ -z "$monitor" ]; then
			xrandr --output $monitor --brightness $brightness
		else
			echo "Not all arguments are set..."		
		fi
	else
		echo "Wrong params. Must be a number or -s."
		exit 1		
	fi
}

#if run script without params ex: bash brightness
#and first argument is empty length

if [ -z "$1" ]; then
	setBrightness
else
  #running script with -s flag(settings)
  
  if [ $1 == "-s" ]; then
		xrandr | grep " connected" | cut -f1 -d " "
		echo "Input monitor name:"
		read monitorNew
		setBrightness
	else
		setBrightness $1
	fi
fi

#second brightness adjustment

echo "OK? y/n"
read answer
if [ $answer == "n" ]; then
	setBrightness
fi

exit 1	
