#!/bin/bash

MainMenu(){

resize -s 29 76 &> /dev/null
clear
wmctrl -r :ACTIVE: -N "FrankenScript"

while true
do

while true
do

clear
echo $RED"##############$STAND Main Menu$RED ##############"$STAND
echo $RED"#                                     $RED#"$STAND
echo $RED"# ["$GREEN"1"$RED"]"$GREEN" = Network Attacks               $RED#"$STAND
echo $RED"# ["$GREEN"2"$RED"]"$GREEN" = View Recovered Passkeys       $RED#"$STAND
echo $RED"# ["$GREEN"3"$RED"]"$GREEN" = Script Launcher               $RED#"$STAND
echo $RED"# ["$GREEN"q"$RED"]"$GREEN" = Exit FrankenScript            $RED#"$STAND
echo $RED"#                                     $RED#"$STAND
echo $RED"#######################################"$STAND
echo ""
read -p $GREEN"Please choose an option:$STAND " ChosenOption

case $ChosenOption in
1|2|3|q)
break ;;
*) ;;
esac
done

if [[ $ChosenOption == "1" ]]; then

   Interfaces
   ScanSelection

fi

if [[ $ChosenOption == "2" ]]; then

   RecoveredPasskeys

fi

if [[ $ChosenOption == "3" ]]; then

   ScriptLauncher

fi

case $ChosenOption in
q)
break ;;
*) ;;
esac
done

if [[ $ChosenOption == "q" ]]; then

   ExitFrankenScript

fi

}

Interfaces(){

if [ -f $DIR/TempFolder/WiFiConnection.txt ];
then

   ConnectionInterface=$(cat $DIR/TempFolder/WiFiConnection.txt | awk '{ print $1 }')
   ConnectionESSID=$(cat $DIR/TempFolder/WiFiConnection.txt | awk '{ print $2 }')

   ConnectedInterface=$(/sbin/iw $ConnectionInterface link | grep "Connected to")
   if [[ $ConnectedInterface ]]; then

      echo $RED"Disconnecting$STAND $ConnectionInterface$RED from$STAND $ConnectionESSID$RED, please wait..."$STAND

      ifdown $ConnectionInterface

   fi

fi

MonitorModeCheck=$(cat /proc/net/dev | sed '/FSwlan/!d')
if [[ $MonitorModeCheck ]]; then

   CurrentWiFiDevice=$($DIR/Applications/Old_airmon-ng | sed -e '/FSwlan/!d' -e 's/FS//g' -e 's/mon//g' -e 's/-//g' | column -t | sed 's/  / /g')
   CurrentMonitorInterface=$($DIR/Applications/Old_airmon-ng | sed -e '/FSwlan/!d' -e 's/-//g' | column -t | sed 's/  / /g')

   while true
   do

   clear
   echo $RED"Current WiFi Device:"$STAND
   echo $STAND"$CurrentWiFiDevice"$STAND
   echo ""
   echo $RED"Current Monitor Mode Interface:"$STAND
   echo $STAND"$CurrentMonitorInterface"$STAND
   echo ""
   read -p $GREEN"Would you like to use the interfaces that are listed above?,$STAND y/n: " PreCreatedOption

   case $PreCreatedOption in
   y|n)
   break ;;
   *) echo "Invalid Option, please try again." ;;
   esac
   done

   if [[ $PreCreatedOption == "y" ]]; then

      echo "$CurrentWiFiDevice" > $DIR/TempFolder/WiFiDevice.txt

      echo "$CurrentMonitorInterface" > $DIR/TempFolder/MonitorModeInterface.txt

   fi

   if [[ $PreCreatedOption == "n" ]]; then

      SetupInterfaces

   fi

else

   SetupInterfaces

fi

}

SetupInterfaces(){

while true
do

clear
echo $RED"Networking services need to be stopped so the interfaces can be setup, networking services will be re-enabled within a few seconds."$STAND
echo ""
read -p $GREEN"Is it ok to kill these services?,$STAND y/n: " KillOption

case $KillOption in
y|n)
break ;;
*) echo "Invalid Option, please try again." ;;
esac
done

if [[ $KillOption == "y" ]]; then

   clear
   $DIR/Applications/New_airmon-ng check kill

fi

if [[ $KillOption == "n" ]]; then

   MainMenu

fi

MultipleInterfacesCheck=$($DIR/Applications/Old_airmon-ng | sed -e '/wlan/!d' -e '/FSwlan/d' -e 's/mon//g' | nl -ba -w 1  -s ': ' | grep "2:")
if [[ $MultipleInterfacesCheck ]]; then

   while true
   do

   DetectedWiFiDevices=$($DIR/Applications/Old_airmon-ng | sed -e '/wlan/!d' -e '/FSwlan/d' -e 's/mon//g' -e 's/-//g' | column -t)
   LineCount=$(echo "$DetectedWiFiDevices" | wc -l)

   echo ""
   echo $RED"Detected WiFi Interfaces:$STAND"
   echo ""
   echo "$DetectedWiFiDevices" | nl -ba -w 1  -s ': '
   echo ""
   echo $RED"["$GREEN"1-$LineCount"$RED"]"$GREEN" = Select A WiFi Interface"$STAND
   echo $RED"["$GREEN"m"$RED"]"$GREEN" = Return To The Main Menu"$STAND
   echo $RED"["$GREEN"q"$RED"]"$GREEN" = Exit FrankenScript"$STAND
   echo ""
   echo $RED"NOTE:"$STAND
   echo $RED"The WiFi interface will be used in the iwlist/iw dev scans if you choose to use them."$STAND
   echo ""
   read -p $GREEN"Please input an option:$STAND " WiFiDeviceOption

   if [[ $WiFiDeviceOption == "m" ]]; then

      MainMenu

   fi

   if [[ $WiFiDeviceOption == "q" ]]; then

      ExitFrankenScript

   fi

   ValidOptionCheck=$(echo "$WiFiDeviceOption" | grep "[1-$LineCount]")
   if [[ $ValidOptionCheck ]]; then

      WiFiDeviceDetails=$(echo "$DetectedWiFiDevices" | sed -n ""$WiFiDeviceOption"p")
      echo "$WiFiDeviceDetails" > $DIR/TempFolder/WiFiDevice.txt
      wlanX=$(cat $DIR/TempFolder/WiFiDevice.txt | awk '{ print $1 }')

      OptionCheck=$(echo "PROCEED")

   else

      OptionCheck=$(echo "Invalid Option")

   fi

   case $OptionCheck in
   PROCEED)
   break ;;
   *) echo "Invalid Option, please try again." ;;
   esac
   done

else

   WiFiDeviceDetails=$($DIR/Applications/Old_airmon-ng | sed -e '/wlan/!d' -e 's/mon//g' -e 's/-//g' | column -t)
   echo "$WiFiDeviceDetails" > $DIR/TempFolder/WiFiDevice.txt
   wlanX=$(cat $DIR/TempFolder/WiFiDevice.txt | awk '{ print $1 }')

   echo ""
   echo $RED"Only 1 WiFi interface was found."$STAND
   echo ""
   echo $RED"NOTE:"$STAND
   echo $STAND"$wlanX$RED will be used in the iwlist/iw dev scans if you choose to use them."$STAND
   sleep 3

fi

if [ ! -f /etc/network/interfaces.bak ];
then

   cp /etc/network/interfaces /etc/network/interfaces.bak

fi

echo ""
echo $RED"Changing the mac address for$STAND $wlanX$RED to$STAND 00:11:22:33:44:55."$STAND
ifconfig $wlanX down
macchanger --mac 00:11:22:33:44:55 $wlanX
ifconfig $wlanX up

echo ""
echo $RED"Creating a monitor mode interface$STAND FS"$wlanX"mon."$STAND
iw $wlanX interface add FS"$wlanX"mon type monitor

echo ""
echo $RED"Changing the mac address for$STAND FS"$wlanX"mon$RED to$STAND 00:11:22:33:44:55."$STAND
ifconfig FS"$wlanX"mon down
macchanger --mac 00:11:22:33:44:55 FS"$wlanX"mon
ifconfig FS"$wlanX"mon up

echo ""
echo $RED"Enabling monitor mode on$STAND FS"$wlanX"mon."$STAND
iwconfig FS"$wlanX"mon mode monitor

echo "FS"$wlanX"mon" > $DIR/TempFolder/MonitorModeInterface.txt

echo ""
echo $RED"Blacklisting$STAND $wlanX$RED & $STANDFS"$wlanX"mon."$STAND
echo "" >> /etc/network/interfaces
echo "iface $wlanX inet manual" >> /etc/network/interfaces
echo "iface FS"$wlanX"mon inet manual" >> /etc/network/interfaces

echo ""
echo $RED"Restarting networking services."$STAND

service NetworkManager start

ifconfig $wlanX up &> /dev/null

ConnectedInterface=$(/sbin/iw $wlanX link | grep "Connected to")
if [[ ! $ConnectedInterface ]]; then

   while true
   do

   clear
   echo $RED"Note:"$STAND
   echo $RED"FrankenScript currently only connects to WPA & WPA2 encrypted networks."$STAND
   echo $RED"Internet access would not be available during the network scans."$STAND
   echo $RED"Internet access would only be available during the network attacks."$STAND
   echo $RED"If you have other WiFi devices you can use them with network manager for constant internet access."$STAND
   echo ""
   read -p $GREEN"Do you need to use$STAND $wlanX$GREEN for internet access?,$STAND y/n: " InternetOption

   case $InternetOption in
   y|n)
   break ;;
   *) echo "Invalid Option, please try again." ;;
   esac
   done

   if [[ $InternetOption == "y" ]]; then

      clear
      read -p $GREEN"Input the ESSID of the network you want to connect to$STAND: " NetworkESSID
      echo ""
      read -p $GREEN"Input the passkey of the network you want to connect to$STAND: " NetworkPasskey

      chmod 0600 /etc/network/interfaces

      PSK=$(wpa_passphrase $NetworkESSID $NetworkPasskey | sed -e '/psk=/!d' -e '/#psk=/d' -e 's/psk=//g' -e 's/^[ \t]*//;s/[ \t]*$//' | awk '{ print $1 }')

      echo "

      auto $wlanX
      iface $wlanX inet dhcp
              wpa-ssid $NetworkESSID
              wpa-psk $PSK" >> /etc/network/interfaces

      echo "$wlanX $NetworkESSID" > $DIR/TempFolder/WiFiConnection.txt

   fi

fi

}

ScanSelection(){

resize -s 29 76 &> /dev/null

while true
do

wlanX=$(cat $DIR/TempFolder/WiFiDevice.txt | awk '{ print $1 }')
monX=$(cat $DIR/TempFolder/MonitorModeInterface.txt | awk '{ print $1 }')

CurrentMACwlanX=$(macchanger -s $wlanX)
CurrentMACmonX=$(macchanger -s $monX)

clear
echo $RED"MAC Address For WiFi Device$STAND $wlanX:"$STAND
echo $STAND"$CurrentMACwlanX"$STAND
echo ""
echo $RED"MAC Address For Monitor Mode Interface$STAND $monX:"$STAND
echo $STAND"$CurrentMACmonX"$STAND
echo ""
echo $RED"#################################################"$STAND
echo $RED"###############$STAND Scan Options Menu $RED###############"$STAND
echo $RED"#################################################"$STAND
echo $RED"#                                               $RED#"$STAND
echo $RED"# ["$GREEN"i"$RED"]"$GREEN" = iw dev + iwlist Scan$STAND (open wep wpa wps) $RED#"$STAND
echo $RED"# ["$GREEN"a"$RED"]"$GREEN" = Airodump Scan$STAND (open wep wpa/wpa2)       $RED#"$STAND
echo $RED"# ["$GREEN"w"$RED"]"$GREEN" = Wash Scan$STAND (wps)                         $RED#"$STAND
echo $RED"# ["$GREEN"m"$RED"]"$GREEN" = Return To The Main Menu                 $RED#"$STAND
echo $RED"# ["$GREEN"q"$RED"]"$GREEN" = Exit FrankenScript                      $RED#"$STAND
echo $RED"#                                               $RED#"$STAND
echo $RED"#################################################"$STAND
echo ""
read -p $GREEN"Please choose an option:$STAND " ScanOption

case $ScanOption in
i|w|a|m|q)
break ;;
*) ;;
esac
done

if [[ $ScanOption == "m" ]]; then

   MainMenu

fi

if [[ $ScanOption == "q" ]]; then

   ExitFrankenScript

fi

if [[ $ScanOption == "i" ]]; then

   iwScans

fi

if [[ $ScanOption == "w" ]]; then

   WashScan

fi

if [[ $ScanOption == "a" ]]; then

   AirodumpScan

fi

}

iwScans(){

ifconfig $wlanX up &> /dev/null

clear

resize -s 29 76 &> /dev/null

wlanX=$(cat $DIR/TempFolder/WiFiDevice.txt | awk '{ print $1 }')
InterfaceDetails=$(cat $DIR/TempFolder/WiFiDevice.txt)

wmctrl -r :ACTIVE: -N "iw dev + iwlist Scan ($InterfaceDetails)"

if [ -f $DIR/TempFolder/WiFiConnection.txt ];
then

   ConnectionInterface=$(cat $DIR/TempFolder/WiFiConnection.txt | awk '{ print $1 }')
   ConnectionESSID=$(cat $DIR/TempFolder/WiFiConnection.txt | awk '{ print $2 }')

   ConnectedInterface=$(/sbin/iw $ConnectionInterface link | grep "Connected to")
   if [[ $ConnectedInterface ]]; then

      echo $RED"Disconnecting$STAND $ConnectionInterface$RED from$STAND $ConnectionESSID$RED, please wait..."$STAND

      ifdown $ConnectionInterface

   fi

fi

rm $DIR/TempFolder/ScanResults.txt &> /dev/null
rm $DIR/TempFolder/AP_Details.txt &> /dev/null
rm $DIR/TempFolder/iw_dev_scan.txt &> /dev/null
rm $DIR/TempFolder/iwlist_scan.txt &> /dev/null
rm $DIR/TempFolder/iw_dev_scan_failed.txt &> /dev/null
rm $DIR/TempFolder/iwlist_scan_failed.txt &> /dev/null
rm $DIR/TempFolder/WPS_Networks.txt &> /dev/null
rm $DIR/TempFolder/WPA_Networks.txt &> /dev/null
rm $DIR/TempFolder/WEP_Networks.txt &> /dev/null
rm $DIR/TempFolder/OPEN_Networks.txt &> /dev/null

if [ ! "$(pidof NetworkManager)" ] 
then

   echo $RED"Restarting network manager, please wait..."$STAND
   service network-manager start
   echo ""
   sleep 3

fi

if [ "$(pidof NetworkManager)" ] 
then

   ConnectionCheck=$(nmcli dev | grep "$wlanX" | grep " connected")
   if [[ $ConnectionCheck ]]; then

      clear
      echo $RED"Disconnecting active $STAND$wlanX$RED connections, please wait...$STAND"
      nmcli device disconnect $wlanX
      echo ""

   fi

fi

echo $RED"Starting the iw dev scan, please wait..."$STAND

iw dev $wlanX scan | sed -e 's/* //g' -e 's/^[ \t]*//;s/[ \t]*$//' -e 's/^BSS /\nBSSID/g' > $DIR/TempFolder/iw_dev_scan.txt

IWscanCheck1=$(cat $DIR/TempFolder/iw_dev_scan.txt | grep "SSID:")
if [[ ! $IWscanCheck1 ]]; then

   echo $STAND"The iw dev scan failed."$STAND
   echo $RED"Attempting the scan again, please wait..."$STAND
   sleep 3

   iw dev $wlanX scan | sed -e 's/* //g' -e 's/^[ \t]*//;s/[ \t]*$//' -e 's/^BSS /\nBSSID/g' > $DIR/TempFolder/iw_dev_scan.txt

   IWscanCheck2=$(cat $DIR/TempFolder/iw_dev_scan.txt | grep "SSID:")
   if [[ ! $IWscanCheck2 ]]; then

      echo $STAND"The iw dev scan failed again."$STAND
      echo $RED"Attempting the scan again one more time, please wait..."$STAND
      sleep 3

      iw dev $wlanX scan | sed -e 's/* //g' -e 's/^[ \t]*//;s/[ \t]*$//' -e 's/^BSS /\nBSSID/g' > $DIR/TempFolder/iw_dev_scan.txt

   fi

fi

IWscanCheck=$(cat $DIR/TempFolder/iw_dev_scan.txt | grep "SSID:")
if [[ $IWscanCheck ]]; then

   echo $RED"The iw dev scan was successful."$STAND

   cat $DIR/TempFolder/iw_dev_scan.txt | sed -e '/./{H;$!d;}' -e 'x;/WPS:/!d;' > $DIR/TempFolder/AP_Details.txt
   cat $DIR/TempFolder/iw_dev_scan.txt | sed -e '/./{H;$!d;}' -e 'x;/PSK/b' -e '/TKIP/b' -e '/CCMP/b' -e '/IEEE 802/b' -e d | sed -e '/./{H;$!d;}' -e 'x;/transition/d;' | sed -e '/./{H;$!d;}' -e 'x;/Load/d;' | sed -e '/./{H;$!d;}' -e 'x;/WPS:/d;' >> $DIR/TempFolder/AP_Details.txt

   if [ -f $DIR/TempFolder/iw_dev_scan.txt ];
   then

      rm $DIR/TempFolder/iw_dev_scan.txt

   fi

   WPScheck=$(cat $DIR/TempFolder/AP_Details.txt | sed -e '/./{H;$!d;}' -e 'x;/WPS:/!d;')
   if [[ $WPScheck ]]; then

      cat $DIR/TempFolder/AP_Details.txt | sed -e '/./{H;$!d;}' -e 'x;/WPS:/!d;' | sed -e 's/^BSSID/Print-BSSID-/g' -e 's/^signal: /Print-Signal/g' -e 's/^SSID: /Print-ESSID-/g' -e 's/^DS Parameter set: channel /Print-Channel-/g' -e 's/^Group cipher: /Print-/g' -e 's/^Pairwise ciphers: /Print-/g' -e 's/^Authentication suites: /Print-/g' -e 's/(on wlan.)//g' -e 's/ -- associated//g' | sed -e '/./{H;$!d;}' -e 'x;/transition/d;' | sed -e '/./{H;$!d;}' -e 'x;/Load/d;' | awk '/Print-ESSID-/{gsub(/ /, "+")}; 1' | grep "Print-" | sed -e 's/^Print-BSSID/\nPrint-BSSID/g' | fmt -w 2500 | sed -e 's/Print-//g' -e 's/.00 dBm/.dBm/g' -e 's/ESSID-//g' -e 's/BSSID-//g' -e '/^$/d' | awk '{ while(++i<=NF) printf (!a[$i]++) ? $i FS : ""; i=split("",a); print "" }' | sed -e 's/$/WPS/g' -e 's/PSK WPS/PSK-WPS/g' -e 's/CCMP PSK/CCMP-PSK/g' -e 's/TKIP CCMP/TKIP-CCMP/g' -e 's/TKIP-CCMP-PSK-WPS/WPS-TKIP-CCMP-PSK/g' -e 's/CCMP-PSK-WPS/WPS-CCMP-PSK/g' | awk '{ print $3 " " $1 " " $2 " " $4 " " $5}' | column -t > $DIR/TempFolder/WPS_Networks.txt

   fi

   WPAcheck=$(cat $DIR/TempFolder/AP_Details.txt | sed -e '/./{H;$!d;}' -e 'x;/PSK/b' -e '/TKIP/b' -e '/CCMP/b' -e '/IEEE 802/b' -e d | sed -e '/./{H;$!d;}' -e 'x;/WPS:/d;')
   if [[ $WPAcheck ]]; then

      cat $DIR/TempFolder/AP_Details.txt | sed -e '/./{H;$!d;}' -e 'x;/PSK/b' -e '/TKIP/b' -e '/CCMP/b' -e '/IEEE 802/b' -e d | sed -e '/./{H;$!d;}' -e 'x;/WPS:/d;' | sed -e 's/^BSSID/Print-BSSID-/g' -e 's/^signal: /Print-Signal/g' -e 's/^SSID: /Print-ESSID-/g' -e 's/^DS Parameter set: channel /Print-Channel-/g' -e 's/^Group cipher: /Print-/g' -e 's/^Pairwise ciphers: /Print-/g' -e 's/^Authentication suites: /Print-/g' -e 's/(on wlan.)//g' -e 's/ -- associated//g' | sed -e '/./{H;$!d;}' -e 'x;/transition/d;' | sed -e '/./{H;$!d;}' -e 'x;/Load/d;' | awk '/Print-ESSID-/{gsub(/ /, "+")}; 1' | grep "Print-" | sed -e 's/^Print-BSSID/\nPrint-BSSID/g' | fmt -w 2500 | sed -e 's/Print-//g' -e 's/.00 dBm/.dBm/g' -e 's/ESSID-//g' -e 's/BSSID-//g' -e '/^$/d' | awk '{ while(++i<=NF) printf (!a[$i]++) ? $i FS : ""; i=split("",a); print "" }' | grep -e "TKIP" -e "CCMP" -e "PSK" -e "IEEE 802.1X" | sed -e 's/IEEE 802.1X/IEEE.802.1X/g' -e 's/CCMP IEEE/CCMP-IEEE/g' -e 's/TKIP CCMP/TKIP-CCMP/g' -e 's/CCMP PSK/CCMP-PSK/g' -e 's/TKIP PSK/TKIP-PSK/g' -e 's/TKIP-CCMP-IEEE.802.1X/IEEE.802.1X-TKIP-CCMP/g' -e 's/TKIP-CCMP-PSK/PSK-TKIP-CCMP/g' -e 's/CCMP-PSK/PSK-CCMP/g' | awk '{ print $3 " " $1 " " $2 " " $4 " " $5}' | column -t > $DIR/TempFolder/WPA_Networks.txt

   fi

else

   echo $STAND"All iw dev scan attempts failed."$STAND
   echo "iw dev scan failed" > $DIR/TempFolder/iw_dev_scan_failed.txt

fi

echo ""
echo $RED"Starting the iwlist scan, please wait..."$STAND

iwlist $wlanX scan | sed -e 's/^[ \t]*//;s/[ \t]*$//' -e 's/^Cell /\nCell /g' > $DIR/TempFolder/iwlist_scan.txt

iwlistScanCheck1=$(cat $DIR/TempFolder/iwlist_scan.txt | grep "ESSID:")
if [[ ! $iwlistScanCheck1 ]]; then

   echo $STAND"The iwlist scan failed."$STAND
   echo $RED"Attempting the scan again, please wait..."$STAND
   sleep 3

   iwlist $wlanX scan | sed -e 's/^[ \t]*//;s/[ \t]*$//' -e 's/^Cell /\nCell /g' > $DIR/TempFolder/iwlist_scan.txt

   iwlistScanCheck2=$(cat $DIR/TempFolder/iwlist_scan.txt | grep "ESSID:")
   if [[ ! $iwlistScanCheck2 ]]; then

      echo $STAND"The iwlist scan failed again."$STAND
      echo $RED"Attempting the scan again one more time, please wait..."$STAND
      sleep 3

      iwlist $wlanX scan | sed -e 's/^[ \t]*//;s/[ \t]*$//' -e 's/^Cell /\nCell /g' > $DIR/TempFolder/iwlist_scan.txt

   fi

fi

iwlistScanCheck=$(cat $DIR/TempFolder/iwlist_scan.txt | grep "ESSID:")
if [[ $iwlistScanCheck ]]; then

   echo $RED"The iwlist scan was successful."$STAND

   cat $DIR/TempFolder/iwlist_scan.txt | sed -e '/./{H;$!d;}' -e 'x;/IE: /!d;' | sed -e '/./{H;$!d;}' -e 'x;/Encryption key:on/!d;' | sed -e '/./{H;$!d;}' -e 'x;/PSK/d;' | sed -e '/./{H;$!d;}' -e 'x;/TKIP/d;' | sed -e '/./{H;$!d;}' -e 'x;/CCMP/d;' | sed -e 's/Encryption key:on/Encryption: WEP/g' >> $DIR/TempFolder/AP_Details.txt
cat $DIR/TempFolder/iwlist_scan.txt | sed -e '/./{H;$!d;}' -e 'x;/Encryption key:off/!d;' | sed -e 's/Encryption key:off/Encryption: OPEN/g' >> $DIR/TempFolder/AP_Details.txt

   if [ -f $DIR/TempFolder/iwlist_scan.txt ];
   then

      rm $DIR/TempFolder/iwlist_scan.txt

   fi

   WEPcheck=$(cat $DIR/TempFolder/AP_Details.txt | sed -e '/./{H;$!d;}' -e 'x;/Encryption: WEP/!d;')
   if [[ $WEPcheck ]]; then

      cat $DIR/TempFolder/AP_Details.txt | sed -e '/./{H;$!d;}' -e 'x;/Encryption: WEP/!d;' | sed -e 's/Cell .. - Address: /Print-BSSID-/g' -e 's/Channel:/Print-Channel-/g' -e 's/Encryption: WEP/Print-WEP/g' -e 's/Quality=..\/..  Signal level=-/Print-Signal-/g' -e 's/ dBm/.dBm/g' -e 's/ESSID:/Print-ESSID-/g' -e 's/"//g' | awk '/Print-ESSID-/{gsub(/ /, "+")}; 1' | grep "Print-" | sed -e 's/^Print-BSSID/\nPrint-BSSID/g' | fmt -w 2500 | sed -e 's/Print-//g' -e 's/ESSID-//g' -e 's/BSSID-//g' -e '/^$/d' | awk '{ print $5 " " $1 " " $3 " " $2 " " $4}' | column -t > $DIR/TempFolder/WEP_Networks.txt

   fi

   OPENcheck=$(cat $DIR/TempFolder/AP_Details.txt | sed -e '/./{H;$!d;}' -e 'x;/Encryption: OPEN/!d;')
   if [[ $OPENcheck ]]; then

      cat $DIR/TempFolder/AP_Details.txt | sed -e '/./{H;$!d;}' -e 'x;/Encryption: OPEN/!d;' | sed -e 's/Cell .. - Address: /Print-BSSID-/g' -e 's/Channel:/Print-Channel-/g' -e 's/Encryption: OPEN/Print-OPEN/g' -e 's/Quality=..\/..  Signal level=-/Print-Signal-/g' -e 's/ dBm/.dBm/g' -e 's/ESSID:/Print-ESSID-/g' -e 's/"//g' | awk '/Print-ESSID-/{gsub(/ /, "+")}; 1' | grep "Print-" | sed -e 's/^Print-BSSID/\nPrint-BSSID/g' | fmt -w 2500 | sed -e 's/Print-//g' -e 's/ESSID-//g' -e 's/BSSID-//g' -e '/^$/d' | awk '{ print $5 " " $1 " " $3 " " $2 " " $4}' | column -t > $DIR/TempFolder/OPEN_Networks.txt

   fi

else

   echo $STAND"All iwlist scan attempts failed."$STAND
   echo "iwlist scan failed" > $DIR/TempFolder/iwlist_scan_failed.txt

fi

FailedCheck=$(ls $DIR/TempFolder | sed '/iw_dev_scan_failed.txt/!d; /iwlist_scan_failed.txt/!d')
if [[ $FailedCheck ]]; then

   ScanSelection

else

   cat $DIR/TempFolder/*_Networks.txt | column -t | awk 'NF>=5' | sort -k 5 > $DIR/TempFolder/ScanResults.txt

   rm $DIR/TempFolder/WPS_Networks.txt &> /dev/null
   rm $DIR/TempFolder/WPA_Networks.txt &> /dev/null
   rm $DIR/TempFolder/WEP_Networks.txt &> /dev/null
   rm $DIR/TempFolder/OPEN_Networks.txt &> /dev/null

   ScanResults

fi

ScanSelection

}

WashScan(){

rm $DIR/TempFolder/ScanResults.txt &> /dev/null
rm $DIR/TempFolder/AP_Details.txt &> /dev/null

monX=$(cat $DIR/TempFolder/MonitorModeInterface.txt | awk '{ print $1 }')

wmctrl -r :ACTIVE: -N "Wash WPS Scan ($monX)"

if [ "$(pidof NetworkManager)" ] 
then

   ConnectionCheck=$(nmcli dev | grep "$wlanX" | grep " connected")
   if [[ $ConnectionCheck ]]; then

      clear
      echo $RED"Disconnecting active $STAND$wlanX$RED connections, please wait...$STAND"
      nmcli device disconnect $wlanX
      echo ""

   fi

fi

clear
echo $RED"Wash Scan."$STAND
echo $RED"Using$STAND $monX$RED to scan for targets, press$STAND Ctrl+c$RED to stop scanning."$STAND
sleep 3

resize -s 29 111 &> /dev/null

script -c "wash -i $monX -C" -a $DIR/TempFolder/WashScan.txt

resize -s 29 76 &> /dev/null

sed -i '/..:..:..:..:..:../!d' $DIR/TempFolder/WashScan.txt

cat $DIR/TempFolder/WashScan.txt | awk '!($5="")' | awk '!($4="")' | awk '!($3="")' | awk '!($2="")' | awk '!($1="")' | sed -e 's/^[ \t]*//;s/[ \t]*$//' -e 's/ /+/g' | strings > $DIR/TempFolder/SSIDList.txt

cat $DIR/TempFolder/WashScan.txt | awk '{ print $1 " " $3 " " $5 " " $2}' | sed -e 's/ No /.dBm WPS-Locked-No Channel-/g' -e 's/ Yes /.dBm WPS-Locked-Yes Channel-/g' | strings > $DIR/TempFolder/OtherDetailsList.txt

paste -d, $DIR/TempFolder/SSIDList.txt $DIR/TempFolder/OtherDetailsList.txt | sed -e 's/,/ /g' -e 's/ -/ Signal-/g' | awk '{ print $1 " " $2 " " $3 " " $5 " " $4}' | column -t | sort -k 4 > $DIR/TempFolder/ScanResults.txt

Scan_Check=$(grep "Channel-" $DIR/TempFolder/ScanResults.txt)
if [[ $Scan_Check ]]; then

   rm $DIR/TempFolder/SSIDList.txt &> /dev/null
   rm $DIR/TempFolder/OtherDetailsList.txt &> /dev/null
   rm $DIR/TempFolder/WashScan.txt &> /dev/null

   ScanResults

else

   echo "Scan failed, returning to the scan menu..."
   sleep 3

   rm $DIR/TempFolder/ScanResults.txt &> /dev/null
   rm $DIR/TempFolder/SSIDList.txt &> /dev/null
   rm $DIR/TempFolder/OtherDetailsList.txt &> /dev/null
   rm $DIR/TempFolder/WashScan.txt &> /dev/null

   ScanSelection

fi

}

AirodumpScan(){

rm $DIR/TempFolder/ScanResults.txt &> /dev/null
rm $DIR/TempFolder/AP_Details.txt &> /dev/null

monX=$(cat $DIR/TempFolder/MonitorModeInterface.txt | awk '{ print $1 }')

wmctrl -r :ACTIVE: -N "Airodump-ng Scan ($monX)"

resize -s 29 168 &> /dev/null

clear
echo $RED"Airodump-ng Scan."$STAND
echo $RED"Using$STAND $monX$RED to scan for targets, press$STAND Ctrl+c$RED to stop scanning."$STAND
sleep 3

echo "airodump-ng $monX --manufacturer --wps -w $DIR/TempFolder/Airodump" > $DIR/TempFolder/AirodumpScan.txt

chmod +x $DIR/TempFolder/AirodumpScan.txt

if [ "$(pidof NetworkManager)" ] 
then

   ConnectionCheck=$(nmcli dev | grep "$wlanX" | grep " connected")
   if [[ $ConnectionCheck ]]; then

      clear
      echo $RED"Disconnecting active $STAND$wlanX$RED connections, please wait...$STAND"
      nmcli device disconnect $wlanX
      echo ""

   fi

fi

$DIR/TempFolder/AirodumpScan.txt

cat $DIR/TempFolder/Airodump-01.kismet.netxml | sed -e 's/^[ \t]*//;s/[ \t]*$//' -e 's/<encryption>/PRINT-/g' -e 's/<essid cloaked/PRINT-/g' -e 's/<BSSID>/PRINT-/g' -e 's/<manuf>/PRINT-/g' -e 's/<channel>/PRINT-Channel-/g' -e 's/<max_signal_dbm>/PRINT-Signal/g' | grep "PRINT-" | sed -e 's/<\/max_signal_dbm>/<\/max_signal_dbm>\n/g' -e 's/PRINT-//g' -e 's/="false">//g' -e 's/+/ /g' -e 's/\./ /g' -e 's/,/ /g' -e 's/   / /g' -e 's/  / /g' | sed -e '/./{H;$!d;}' -e 'x;/true/d;' | awk '/essid/{gsub(/ /, "+")}; 1' | awk '/manuf/{gsub(/ /, "_")}; 1' | sed -e 's/<\/encryption>//g' | sed -e '/./{H;$!d;}' -e 'x;/essid/!d;' | sed -e 's/<\/essid>//g' -e 's/<\/BSSID>//g' -e 's/<\/manuf>//g' -e 's/<\/max_signal_dbm>/\.dbm/g' | fmt -w 2500 | sed -e 's/<\/channel> Channel-..<\/channel>//g' -e 's/<\/channel> Channel-.<\/channel>//g' -e 's/<\/channel>//g' -e 's/_ / /g' | awk '{ while(++i<=NF) printf (!a[$i]++) ? $i FS : ""; i=split("",a); print "" }' | sed -e 's/None/OPEN/g' -e 's/WPA TKIP/WPA_TKIP/g' -e 's/WPA PSK/WPA_PSK/g' -e 's/TKIP PSK/TKIP_PSK/g' -e 's/TKIP MGT/TKIP_MGT/g' -e 's/PSK AES/PSK_AES/g' -e 's/MGT AES/MGT_AES/g' -e "s/&apos;/'/g" | awk '{ print $2 " " $3 " " $6 " " $5 " " $1 " " $4}' | column -t | sort -k 5 > $DIR/TempFolder/ScanResults.txt

cp $DIR/TempFolder/Airodump-01.kismet.netxml $DIR/TempFolder/AP_Details.txt
sed -i '1,5d' $DIR/TempFolder/AP_Details.txt
sed -i 's/^[ \t]*//;s/[ \t]*$//' $DIR/TempFolder/AP_Details.txt
sed -i 's/<beaconrate>/PRINT-<beaconrate>/g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<encryption>/PRINT-<encryption>/g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<essid/PRINT-<essid/g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<BSSID>/PRINT-<BSSID>/g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<manuf>/PRINT-<manuf>/g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<channel>/PRINT-<channel>/g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<freqmhz>/PRINT-<freqmhz>/g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<carrier>/PRINT-<carrier>/g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<encoding>/PRINT-<encoding>/g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<last/PRINT-<last/g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<min/PRINT-<min/g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<max/PRINT-<max/g' $DIR/TempFolder/AP_Details.txt
sed -i '/PRINT-<max-rate>/d' $DIR/TempFolder/AP_Details.txt
sed -i '/PRINT/!d' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<beaconrate>/\nPRINT-<beaconrate>/g' $DIR/TempFolder/AP_Details.txt
sed -i '/beaconrate/d' $DIR/TempFolder/AP_Details.txt
sed -i '/maxseenrate/d' $DIR/TempFolder/AP_Details.txt
sed -i '/freqmhz/d' $DIR/TempFolder/AP_Details.txt

sed -i 's/<\/encryption>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<encryption>/Encryption = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/essid>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<essid cloaked="false">/ESSID = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/BSSID>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<BSSID>/BSSID = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/manuf>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<manuf>/Manufacturer = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/channel>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<channel>/Channel = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/carrier>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<carrier>/Carrier = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/encoding>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<encoding>/Encoding = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/last_signal_dbm>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<last_signal_dbm>/Last signal dbm = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/last_noise_dbm>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<last_noise_dbm>/Last noise dbm = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/last_signal_rssi>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<last_signal_rssi>/Last signal rssi = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/last_noise_rssi>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<last_noise_rssi>/Last noise rssi = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/min_signal_dbm>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<min_signal_dbm>/Min signal dbm = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/min_noise_dbm>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<min_noise_dbm>/Min noise dbm = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/min_signal_rssi>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<min_signal_rssi>/Min signal rssi = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/min_noise_rssi>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<min_noise_rssi>/Min noise rssi = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/max_signal_dbm>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<max_signal_dbm>/Max signal dbm = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/max_noise_dbm>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<max_noise_dbm>/Max noise dbm = /g' $DIR/TempFolder/AP_Details.txt
sed -i 's/<\/max_signal_rssi>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<max_signal_rssi>/Max signal rssi = /g' $DIR/TempFolder/AP_Details.txt

sed -i 's/<\/max_noise_rssi>//g' $DIR/TempFolder/AP_Details.txt
sed -i 's/PRINT-<max_noise_rssi>/Max noise rssi = /g' $DIR/TempFolder/AP_Details.txt

Scan_Check=$(grep "Channel-" $DIR/TempFolder/ScanResults.txt)
if [[ $Scan_Check ]]; then

   rm $DIR/TempFolder/*.cap &> /dev/null
   rm $DIR/TempFolder/*.csv &> /dev/null
   rm $DIR/TempFolder/*.netxml &> /dev/null

   ScanResults

else

   echo "Scan_Failed, returning to the scan menu..."
   sleep 3

   rm $DIR/TempFolder/ScanResults.txt &> /dev/null
   rm $DIR/TempFolder/*.cap &> /dev/null
   rm $DIR/TempFolder/*.csv &> /dev/null
   rm $DIR/TempFolder/*.netxml &> /dev/null

   ScanSelection

fi

}

ScanResults(){

clear

rm $DIR/TempFolder/temp.txt &> /dev/null

cat $DIR/TempFolder/ScanResults.txt | awk '{ print $1 }' | sed -e 's/$/.txt/g' > $DIR/TempFolder/Recovered_Passkey_Check.txt

fflist=""
DIR_A="$DIR/Passkeys"
FILELIST="$DIR/TempFolder/Recovered_Passkey_Check.txt"
   
exec 3< $FILELIST
while read file_a <&3; do

if [[ -s "$DIR_A/${file_a}" ]];then

   fflist=" ${fflist} ${file_a}"

fi

done

echo "${fflist}" | sed -e 's/.txt/.txt\n/g' -e 's/.txt//g' | sed -e 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d' > $DIR/TempFolder/ExistingPasskeyCheck1.txt
sed -i "s;^;GOT-N;" $DIR/TempFolder/ScanResults.txt
cp $DIR/TempFolder/ExistingPasskeyCheck1.txt $DIR/TempFolder/ExistingPasskeyCheck2.txt
sed -i "s;^;GOT-N;" $DIR/TempFolder/ExistingPasskeyCheck1.txt
sed -i "s;$;/g' '$DIR/TempFolder/ScanResults.txt';" $DIR/TempFolder/ExistingPasskeyCheck2.txt
sed -i "s;^;/GOT-Y;" $DIR/TempFolder/ExistingPasskeyCheck2.txt
paste $DIR/TempFolder/ExistingPasskeyCheck1.txt $DIR/TempFolder/ExistingPasskeyCheck2.txt > $DIR/TempFolder/ExistingPasskeyCheck.txt
sed -i 's;\s*/;/;g' $DIR/TempFolder/ExistingPasskeyCheck.txt
sed -i "s;^;sed -i 's/;" $DIR/TempFolder/ExistingPasskeyCheck.txt
chmod +x $DIR/TempFolder/ExistingPasskeyCheck.txt
$DIR/TempFolder/ExistingPasskeyCheck.txt

rm $DIR/TempFolder/ExistingPasskeyCheck1.txt &> /dev/null
rm $DIR/TempFolder/ExistingPasskeyCheck2.txt &> /dev/null
rm $DIR/TempFolder/ExistingPasskeyCheck.txt &> /dev/null
rm $DIR/TempFolder/Recovered_Passkey_Check.txt &> /dev/null

while true
do

if [ -f $DIR/ScanBlacklist.txt ];
then

   Blacklist=$(cat $DIR/ScanBlacklist.txt | sed '/#/d' | sed '/^$/d' | sed "s|^|sed -i '/|g" | sed "s|$|/d'|g" | sed "s|$| $DIR/TempFolder/ScanResults.txt|g")

   echo "$Blacklist" > $DIR/TempFolder/Blacklist.txt
   chmod +x $DIR/TempFolder/Blacklist.txt
   $DIR/TempFolder/Blacklist.txt
   rm $DIR/TempFolder/Blacklist.txt &> /dev/null

fi

ScannedTargets=$(cat $DIR/TempFolder/ScanResults.txt | nl -ba -w 1  -s ': ' | column -t | sed -e "s/^/$GREEN/g" -e "s/:  /:$STAND /g" -e 's/+/ /g' -e 's/^[ \t]*//;s/[ \t]*$//' -e "s/GOT-Y/$RED/g" -e "s/GOT-N/$STAND/g")

if [ -f $DIR/TempFolder/Chosen_Target_List.txt ];
then

   sed -i "s/GOT-N//g" $DIR/TempFolder/Chosen_Target_List.txt
   sed -i "s/GOT-Y//g" $DIR/TempFolder/Chosen_Target_List.txt
   TARGET_LIST=$(cat $DIR/TempFolder/Chosen_Target_List.txt | column -t)

fi

if [ -f $DIR/TempFolder/AP_Details.txt ];
then

   WidthCount=$(cat $DIR/TempFolder/ScanResults.txt | wc -L)
   if [ "$WidthCount" -gt "86" ]
   then

      resize -s 29 $WidthCount &> /dev/null

   else

      resize -s 29 86 &> /dev/null

   fi

   LineCount=$(cat $DIR/TempFolder/ScanResults.txt | wc -l)

   clear
   echo $RED"##############################$STAND Scan Results$RED #############################"$STAND
   echo ""
   echo "$ScannedTargets"
   echo ""

   if [ -f $DIR/TempFolder/Chosen_Target_List.txt ];
   then

      EmptyCheck=$(cat $DIR/TempFolder/Chosen_Target_List.txt | grep "Channel")
      if [[ $EmptyCheck ]]; then

         echo $RED"Chosen Target List:"$STAND
         echo "$TARGET_LIST"
         echo ""

      fi

   fi

   if [ $LineCount -gt 9 ]
   then 

      echo $RED"#####################################################################################"$STAND
      echo $RED"# ["$GREEN"1"$RED"-"$GREEN"$LineCount"$RED"]"$GREEN" = Select A Target$STAND (eg: 1) $RED# ["$GREEN"i"$RED"]"$GREEN" = iw dev + iwlist Scan$STAND (WPS WPA/WPA2 WEP)  $RED#"$STAND
      echo $RED"# ["$GREEN"i"$RED"+"$GREEN"1"$RED"-"$GREEN"$LineCount"$RED"]"$GREEN" = View AP Info$STAND (eg: i1) $RED# ["$GREEN"a"$RED"]"$GREEN" = airodump-ng scan$STAND (WPA/WPA2 WEP)          $RED#"$STAND
      echo $RED"# ["$GREEN"d"$RED"]"$GREEN" = Delete A Chosen Target     $RED# ["$GREEN"w"$RED"]"$GREEN" = wash scan$STAND (WPS)                          $RED#"$STAND
      echo $RED"# ["$GREEN"b"$RED"]"$GREEN" = Scan Results Blacklist     $RED# ["$GREEN"s"$RED"]"$GREEN" = Script Launcher                          $RED#"$STAND
      echo $RED"# ["$GREEN"p"$RED"]"$GREEN" = Proceed To Attacks         $RED# ["$GREEN"m"$RED"]"$GREEN" = Return To Main Menu                      $RED#"$STAND
      echo $RED"#####################################################################################"$STAND

   else

      echo $RED"#####################################################################################"$STAND
      echo $RED"# ["$GREEN"1"$RED"-"$GREEN"$LineCount"$RED"]"$GREEN" = Select A Target$STAND (eg: 1)  $RED# ["$GREEN"i"$RED"]"$GREEN" = iw dev + iwlist Scan$STAND (WPS WPA/WPA2 WEP)  $RED#"$STAND
      echo $RED"# ["$GREEN"i"$RED"+"$GREEN"1"$RED"-"$GREEN"$LineCount"$RED"]"$GREEN" = View AP Info$STAND (eg: i1)  $RED# ["$GREEN"a"$RED"]"$GREEN" = airodump-ng scan$STAND (WPA/WPA2 WEP)          $RED#"$STAND
      echo $RED"# ["$GREEN"d"$RED"]"$GREEN" = Delete A Chosen Target     $RED# ["$GREEN"w"$RED"]"$GREEN" = wash scan$STAND (WPS)                          $RED#"$STAND
      echo $RED"# ["$GREEN"b"$RED"]"$GREEN" = Scan Results Blacklist     $RED# ["$GREEN"s"$RED"]"$GREEN" = Script Launcher                          $RED#"$STAND
      echo $RED"# ["$GREEN"p"$RED"]"$GREEN" = Proceed To Attacks         $RED# ["$GREEN"m"$RED"]"$GREEN" = Return To Main Menu                      $RED#"$STAND
      echo $RED"#####################################################################################"$STAND

   fi

   if [ -f $DIR/TempFolder/iw_dev_scan_failed.txt ];
   then

      echo ""
      echo $STAND"iw dev scan failed, WPS & WPA networks are not displayed."$STAND

   fi

   if [ -f $DIR/TempFolder/iwlist_scan_failed.txt ];
   then

      echo ""
      echo $STAND"iwlist scan failed, WEP & OPEN networks are not displayed."$STAND

   fi

   echo ""
   read -p $GREEN"Please choose an option$STAND: " CHOSEN_OPTION


   InfoCheck1=$(echo "$CHOSEN_OPTION" | grep -e 'i[1-9]' -e 'i[1-9][0-9]')
   if [[ $InfoCheck1 ]]; then

      CHOSEN_OPTION=$(echo "$CHOSEN_OPTION" | sed 's/i//g')

      InfoCheck2=$(cat $DIR/TempFolder/ScanResults.txt | sed -n ""$CHOSEN_OPTION"p")
      if [[ $InfoCheck2 ]]; then

         cat $DIR/TempFolder/ScanResults.txt | sed -n ""$CHOSEN_OPTION"p" > $DIR/TempFolder/temp.txt
         TargetMAC=$(cat $DIR/TempFolder/temp.txt | awk '{ print $2 }')
         TargetInfo=$(cat $DIR/TempFolder/AP_Details.txt | awk -v RS='' "/$TargetMAC/")
         clear
         echo "$TargetInfo"
         echo ""
         read -p $GREEN"Press ["$STAND"Enter"$GREEN"] to return to the Scan Results menu."$STAND

         ScanResults

      else

         ScanResults

      fi

   fi

else

   WidthCount=$(cat $DIR/TempFolder/ScanResults.txt | wc -L)
   if [ "$WidthCount" -gt "86" ]
   then

      resize -s 29 $WidthCount &> /dev/null

   else

      resize -s 29 86 &> /dev/null

   fi

   LineCount=$(cat $DIR/TempFolder/ScanResults.txt | wc -l)

   clear
   echo $RED"############################$STAND Wash Scan Results$RED ###########################"$STAND
   echo ""
   echo "$ScannedTargets"
   echo ""

   if [ -f $DIR/TempFolder/Chosen_Target_List.txt ];
   then

      EmptyCheck=$(cat $DIR/TempFolder/Chosen_Target_List.txt | grep "Channel")
      if [[ $EmptyCheck ]]; then

         echo $RED"Chosen Target List:"$STAND
         echo "$TARGET_LIST"
         echo ""

      fi

   fi

   if [ $LineCount -gt 9 ]
   then 

      echo $RED"#####################################################################################"$STAND
      echo $RED"# ["$GREEN"1"$RED"-"$GREEN"$LineCount"$RED"]"$GREEN" = Select A Target$STAND (eg: 1) $RED# ["$GREEN"i"$RED"]"$GREEN" = iw dev + iwlist Scan$STAND (WPS WPA/WPA2 WEP)  $RED#"$STAND
      echo $RED"# ["$GREEN"d"$RED"]"$GREEN" = Delete A Chosen Target     $RED# ["$GREEN"a"$RED"]"$GREEN" = airodump-ng scan$STAND (WPA/WPA2 WEP)          $RED#"$STAND
      echo $RED"# ["$GREEN"b"$RED"]"$GREEN" = Scan Results Blacklist     $RED# ["$GREEN"w"$RED"]"$GREEN" = wash scan$STAND (WPS)                          $RED#"$STAND
      echo $RED"# ["$GREEN"s"$RED"]"$GREEN" = Script Launcher            $RED# ["$GREEN"m"$RED"]"$GREEN" = Return To Main Menu                      $RED#"$STAND
      echo $RED"# ["$GREEN"p"$RED"]"$GREEN" = Proceed To Attacks         $RED#                                                $RED#"$STAND
      echo $RED"#####################################################################################"$STAND

   else

      echo $RED"#####################################################################################"$STAND
      echo $RED"# ["$GREEN"1"$RED"-"$GREEN"$LineCount"$RED"]"$GREEN" = Select A Target$STAND (eg: 1)  $RED# ["$GREEN"i"$RED"]"$GREEN" = iw dev + iwlist Scan$STAND (WPS WPA/WPA2 WEP)  $RED#"$STAND
      echo $RED"# ["$GREEN"d"$RED"]"$GREEN" = Delete A Chosen Target     $RED# ["$GREEN"a"$RED"]"$GREEN" = airodump-ng scan$STAND (WPA/WPA2 WEP)          $RED#"$STAND
      echo $RED"# ["$GREEN"b"$RED"]"$GREEN" = Scan Results Blacklist     $RED# ["$GREEN"w"$RED"]"$GREEN" = wash scan$STAND (WPS)                          $RED#"$STAND
      echo $RED"# ["$GREEN"s"$RED"]"$GREEN" = Script Launcher            $RED# ["$GREEN"m"$RED"]"$GREEN" = Return To Main Menu                      $RED#"$STAND
      echo $RED"# ["$GREEN"p"$RED"]"$GREEN" = Proceed To Attacks         $RED#                                                $RED#"$STAND
      echo $RED"#####################################################################################"$STAND

   fi

   echo ""
   read -p $GREEN"Please choose an option$STAND: " CHOSEN_OPTION

fi

if [[ $CHOSEN_OPTION == "d" ]]; then

   if [ -f $DIR/TempFolder/Chosen_Target_List.txt ];
   then

      DeleteATarget

   else

      ScanResults

   fi

fi

if [[ $CHOSEN_OPTION == "m" ]]; then

   rm $DIR/TempFolder/ScanResults.txt &> /dev/null
   rm $DIR/TempFolder/AP_Details.txt &> /dev/null
   rm $DIR/TempFolder/ChosenInterface.txt &> /dev/null
   rm $DIR/TempFolder/NetworkAttacks-monX.txt &> /dev/null
   rm $DIR/TempFolder/NetworkAttacks-wlanXmon.txt &> /dev/null

   MainMenu

fi

if [[ $CHOSEN_OPTION == "s" ]]; then

   ScriptLauncher

   ScanResults

fi

if [[ $CHOSEN_OPTION == "b" ]]; then

   while true
   do

   clear
   BlacklistResults=$(cat $DIR/ScanBlacklist.txt | sed -n '/#/!p' | sed '/^$/d' | nl -ba -w 1  -s ': ')
   BlacklistFile=$(cat $DIR/ScanBlacklist.txt | sed -n '/#/!p' | sed '/^$/d')
   LineCount=$(echo "$BlacklistFile" | wc -l)
   echo ""
   echo $RED"Blacklist Results:$STAND"
   echo ""
   echo "$BlacklistResults"
   echo ""
   echo $RED"#################################"$STAND
   echo $RED"#                               #"$STAND
   echo $RED"# ["$GREEN"1-$LineCount"$RED"]"$GREEN" = Remove From Blacklist $RED#"$STAND
   echo $RED"# ["$GREEN"a"$RED"]"$GREEN" = Add To Blacklist        $RED#"$STAND
   echo $RED"# ["$GREEN"s"$RED"]"$GREEN" = Return To Scan Results  $RED#"$STAND
   echo $RED"# ["$GREEN"m"$RED"]"$GREEN" = Return To The Main Menu $RED#"$STAND
   echo $RED"# ["$GREEN"q"$RED"]"$GREEN" = Exit FrankenScript      $RED#"$STAND
   echo $RED"#                               #"$STAND
   echo $RED"#################################"$STAND
   echo ""
   read -p $GREEN"Please input an option:$STAND " MenuOption

   if [[ $MenuOption == "s" ]]; then

      ScanResults

   fi

   if [[ $MenuOption == "m" ]]; then

      MainMenu

   fi

   if [[ $MenuOption == "q" ]]; then

      ExitFrankenScript

   fi

   if [[ $MenuOption == "a" ]]; then

      echo ""
      read -p $GREEN"Please input an ESSID, or MAC address, or a PATTERN$STAND: " ScanBlacklist

      echo "$ScanBlacklist" >> $DIR/ScanBlacklist.txt

   fi

   ValidOptionCheck=$(echo "$MenuOption" | grep -e '[1-9]' -e '[1-9][0-9]')
   if [[ $ValidOptionCheck ]]; then

      if [[ "$MenuOption" -le "$LineCount" ]]; then

         RemoveLine=$(echo "$BlacklistFile" | sed -n ""$MenuOption"p")

         sed -i "/$RemoveLine/d" $DIR/ScanBlacklist.txt

      fi

   fi

   done

fi

if [[ $CHOSEN_OPTION == "i" ]]; then

   clear
   iwScans

fi

if [[ $CHOSEN_OPTION == "w" ]]; then

   clear
   WashScan

fi

if [[ $CHOSEN_OPTION == "a" ]]; then

   clear
   AirodumpScan

fi

if [[ $CHOSEN_OPTION == "p" ]]; then

   if [ -f $DIR/TempFolder/Chosen_Target_List.txt ];
   then

      if [ -f $DIR/TempFolder/WiFiConnection.txt ];
      then

         ConnectionInterface=$(cat $DIR/TempFolder/WiFiConnection.txt | awk '{ print $1 }')
         ConnectionESSID=$(cat $DIR/TempFolder/WiFiConnection.txt | awk '{ print $2 }')

         ConnectedInterface=$(/sbin/iw $ConnectionInterface link | grep "Connected to")
         if [[ ! $ConnectedInterface ]]; then

            echo $RED"Connecting to$STAND $ConnectionESSID$RED, please wait..."$STAND

            ifup $ConnectionInterface

         fi

      fi

      LaunchAttackScript

   else

      ScanResults

   fi

fi

ValidOptionCheck=$(echo "$CHOSEN_OPTION" | grep -e '[1-9]' -e '[1-9][0-9]')
if [[ $ValidOptionCheck ]]; then

   if [[ "$CHOSEN_OPTION" -le "$LineCount" ]]; then

      AttackMethod

   else

      ScanResults

   fi

else

   ScanResults

fi

done

}

DeleteATarget(){

if [ -f $DIR/TempFolder/Chosen_Target_List.txt ];
then

   DeleteCheck=$(cat $DIR/TempFolder/Chosen_Target_List.txt | grep "Channel")
   if [[ $DeleteCheck ]]; then

      while true
      do

      TARGET_LIST=$(cat $DIR/TempFolder/Chosen_Target_List.txt | nl -ba -w 1  -s ': ' | column -t | sed -e "s/GOT-N//g" -e "s/GOT-Y//g")

      LineCount=$(cat $DIR/TempFolder/Chosen_Target_List.txt | wc -l)

      clear
      echo $RED"####################$STAND Deletion List$RED ####################"$STAND
      echo ""
      echo "$TARGET_LIST"
      echo ""
      echo $RED"["$GREEN"1-$LineCount"$RED"]"$GREEN" = Delete Target$STAND (eg: 5)"$STAND
      echo $RED"["$GREEN"s"$RED"]"$GREEN" = Return To Scan Results"$STAND
      echo $RED"["$GREEN"m"$RED"]"$GREEN" = Return To Main Menu"$STAND
      echo ""
      read -p $GREEN"Please choose an Option$STAND: " DELETE_OPTION

      if [[ $DELETE_OPTION  == "s" ]]; then

         if [ -f $DIR/TempFolder/ScanResults.txt ];
         then

            Width_Count_Check=$(cat $DIR/TempFolder/ScanResults.txt | wc -L)
            Width_Count_resize=$(($Width_Count_Check))
            resize -s 29 $Width_Count_resize &> /dev/null

         else

            resize -s 29 76 &> /dev/null

         fi

         ScanResults

      fi

      if [[ $DELETE_OPTION == "m" ]]; then

         MainMenu

      fi

      ValidOptionCheck=$(echo "$DELETE_OPTION" | grep -e '[1-9]' -e '[1-9][0-9]')
      if [[ $ValidOptionCheck ]]; then

         if [[ "$DELETE_OPTION" -le "$LineCount" ]]; then

            sed -i "${DELETE_OPTION}d" $DIR/TempFolder/Chosen_Target_List.txt

         fi

      fi

      if [ -f $DIR/TempFolder/Chosen_Target_List.txt ];
      then

         EmptyCheck=$(cat $DIR/TempFolder/Chosen_Target_List.txt | grep "Channel")
         if [[ ! $EmptyCheck ]]; then

            rm $DIR/TempFolder/Chosen_Target_List.txt &> /dev/null

            ScanResults

         fi

      fi

      done

   else

      ScanResults

   fi

else

   ScanResults

fi

}

AttackMethod(){

CHOSEN_TARGET_Line=$(cat $DIR/TempFolder/ScanResults.txt | sed -n ""$CHOSEN_OPTION"p" | sed -e "s/GOT-N//g" -e "s/GOT-Y//g")

if [ -f $DIR/TempFolder/AP_Details.txt ];
then

   cat $DIR/TempFolder/ScanResults.txt | sed -n ""$CHOSEN_OPTION"p" > $DIR/TempFolder/temp.txt
   TargetMAC=$(cat $DIR/TempFolder/temp.txt | awk '{ print $2 }')
   TargetInfo=$(cat $DIR/TempFolder/AP_Details.txt | awk -v RS='' "/$TargetMAC/")
   clear
   echo "$TargetInfo"

else

   clear
   echo "$CHOSEN_TARGET_Line" | column -t | sed "s/  / /g"

fi

WEP_ATTACK=$(echo "$CHOSEN_TARGET_Line" | grep "WEP")
if [[ $WEP_ATTACK ]]; then

   cat $DIR/TempFolder/ScanResults.txt | sed -n ""$CHOSEN_OPTION"p" | awk '{ print $1 " " $2 " " $3 " " $4}' | sed "s/$/ Attack_WEP/" >> $DIR/TempFolder/Chosen_Target_List.txt

else

   WPS_ATTACK=$(echo "$CHOSEN_TARGET_Line" | grep "WPS")
   if [[ $WPS_ATTACK ]]; then

      while true
      do

      echo ""
      echo $RED"["$GREEN"1"$RED"]"$GREEN" = WPS Attacks"$STAND
      echo $RED"["$GREEN"2"$RED"]"$GREEN" = WPA/WPA2 Handshake Capture"$STAND
      echo $RED"["$GREEN"s"$RED"]"$GREEN" = Return To Scan Results"$STAND
      echo $RED"["$GREEN"m"$RED"]"$GREEN" = Return To Main Menu"$STAND
      echo ""
      read -p $GREEN"Please choose an option$STAND: " ATTACK_METHOD

      case $ATTACK_METHOD in
      1|2|s|m)
      break ;;
      *) ;;
      esac
      done

      if [[ $ATTACK_METHOD  == "s" ]]; then

         if [ -f $DIR/TempFolder/ScanResults.txt ];
         then

            Width_Count_Check=$(cat $DIR/TempFolder/ScanResults.txt | wc -L)
            Width_Count_resize=$(($Width_Count_Check))
            resize -s 29 $Width_Count_resize &> /dev/null

         else

            resize -s 29 76 &> /dev/null

         fi

         ScanResults

      fi

      if [[ $ATTACK_METHOD == "m" ]]; then

         MainMenu

      fi

      if [[ $ATTACK_METHOD == "1" ]]; then

         cat $DIR/TempFolder/ScanResults.txt | sed -n ""$CHOSEN_OPTION"p" | awk '{ print $1 " " $2 " " $3 " " $4}' | sed "s/$/ Attack_WPS/" >> $DIR/TempFolder/Chosen_Target_List.txt

      fi

      if [[ $ATTACK_METHOD == "2" ]]; then

         cat $DIR/TempFolder/ScanResults.txt | sed -n ""$CHOSEN_OPTION"p" | awk '{ print $1 " " $2 " " $3 " " $4}' | sed "s/$/ Attack_WPA/" >> $DIR/TempFolder/Chosen_Target_List.txt

      fi

   else

      OPEN_ATTACK=$(echo "$CHOSEN_TARGET_Line" | grep "OPEN")
      if [[ $OPEN_ATTACK ]]; then

         cat $DIR/TempFolder/ScanResults.txt | sed -n ""$CHOSEN_OPTION"p" | awk '{ print $1 " " $2 " " $3 " " $4}' | sed "s/$/ Attack_WPA/" >> $DIR/TempFolder/Chosen_Target_List.txt

      else

         while true
         do

         echo ""
         echo $RED"["$GREEN"1"$RED"]"$GREEN" = WPA/WPA2 Handshake Capture"$STAND
         echo $RED"["$GREEN"2"$RED"]"$GREEN" = WPS Attacks"$STAND
         echo $RED"["$GREEN"s"$RED"]"$GREEN" = Return To Scan Results"$STAND
         echo $RED"["$GREEN"m"$RED"]"$GREEN" = Return To Main Menu"$STAND
         echo ""
         read -p $GREEN"Please choose an option$STAND: " ATTACK_METHOD

         case $ATTACK_METHOD in
         1|2|s|m)
         break ;;
         *) ;;
         esac
         done

         if [[ $ATTACK_METHOD  == "s" ]]; then

            if [ -f $DIR/TempFolder/ScanResults.txt ];
            then

               Width_Count_Check=$(cat $DIR/TempFolder/ScanResults.txt | wc -L)
               Width_Count_resize=$(($Width_Count_Check))
               resize -s 29 $Width_Count_resize &> /dev/null

            else

               resize -s 29 76 &> /dev/null

            fi

            ScanResults

         fi

         if [[ $ATTACK_METHOD == "m" ]]; then

            MainMenu

         fi

         if [[ $ATTACK_METHOD == "1" ]]; then

            cat $DIR/TempFolder/ScanResults.txt | sed -n ""$CHOSEN_OPTION"p" | awk '{ print $1 " " $2 " " $3 " " $4}' | sed "s/$/ Attack_WPA/" >> $DIR/TempFolder/Chosen_Target_List.txt

         fi

         if [[ $ATTACK_METHOD == "2" ]]; then

            cat $DIR/TempFolder/ScanResults.txt | sed -n ""$CHOSEN_OPTION"p" | awk '{ print $1 " " $2 " " $3 " " $4}' | sed "s/$/ Attack_WPS/" >> $DIR/TempFolder/Chosen_Target_List.txt

         fi

      fi

   fi

fi

}

LaunchAttackScript(){

CHOSEN_TARGET_LIST=$(cat $DIR/TempFolder/Chosen_Target_List.txt)

while true
do

clear
CHOSEN_TARGET_LINE=$(echo "$CHOSEN_TARGET_LIST" | sed q)
ATTACK_METHOD=$(echo "$CHOSEN_TARGET_LINE" | awk '{ print $5 }')
TargetSSID=$(echo "$CHOSEN_TARGET_LINE" | awk '{ print $1 }')

clear
echo $RED"Proceeding to attack target: $STAND$CHOSEN_TARGET_LINE"$STAND
sleep 2

resize -s 29 76 &> /dev/null

if [[ $ATTACK_METHOD == "Attack_WPA" ]]; then

   chmod +x $DIR/Applications/attack_wpa.sh
   echo "$CHOSEN_TARGET_LINE" > $DIR/TempFolder/Chosen_Target_Line.txt

   $DIR/Applications/attack_wpa.sh

fi

if [[ $ATTACK_METHOD == "Attack_WEP" ]]; then

   chmod +x $DIR/Applications/attack_wep.sh
   echo "$CHOSEN_TARGET_LINE" > $DIR/TempFolder/Chosen_Target_Line.txt

   $DIR/Applications/attack_wep.sh

fi

if [[ $ATTACK_METHOD == "Attack_WPS" ]]; then

   chmod +x $DIR/Applications/attack_wps.sh
   echo "$CHOSEN_TARGET_LINE" > $DIR/TempFolder/Chosen_Target_Line.txt

   $DIR/Applications/attack_wps.sh

fi

CHOSEN_TARGET_LIST=$(echo "$CHOSEN_TARGET_LIST" | sed '1d')
TARGET_LIST_CHECK=$(echo "$CHOSEN_TARGET_LIST" | grep ":")
if [[ ! $TARGET_LIST_CHECK ]]; then

   rm $DIR/TempFolder/Chosen_Target_Line.txt &> /dev/null
   rm $DIR/TempFolder/Chosen_Target_List.txt &> /dev/null

   clear
   echo $RED"Target list is empty, returning to$STAND Scan Results."$STAND
   sleep 3

   resize -s 29 $Width_Count_resize &> /dev/null

   ScanResults

fi

rm $DIR/TempFolder/Chosen_Target_Line.txt &> /dev/null

while true
do

NextTarget=$(echo "$CHOSEN_TARGET_LIST" | head -1)

clear
echo $RED"Next Target:$STAND $NextTarget"$STAND
echo ""
echo $RED"["$GREEN"c"$RED"]"$GREEN" = Attack The Next Target"$STAND
echo $RED"["$GREEN"s"$RED"]"$GREEN" = Return To Scan Results"$STAND
echo $RED"["$GREEN"m"$RED"]"$GREEN" = Return To Main Menu"$STAND
echo ""
read -p $GREEN"Please choose an option:$STAND " ContinueOption
echo ""

if [[ $ContinueOption  == "s" ]]; then

   if [ -f $DIR/TempFolder/ScanResults.txt ];
   then

      resize -s 29 $Width_Count_resize &> /dev/null

   else

      resize -s 29 76 &> /dev/null

   fi

   ScanResults

fi

if [[ $ContinueOption  == "m" ]]; then

   MainMenu

fi

case $ContinueOption in
c)
break ;;
*) ;;
esac
done

done

}

ScriptLauncher(){

while true
do

AvailableScripts=$(ls -l $DIR/ScriptLauncher | sed -e '/~/d' -e '/total/d' | awk '{print substr($0, index($0, $9))}' | nl -ba -w 1 -s ': ')
LineCount=$(echo "$AvailableScripts" | wc -l)
clear
echo $RED"Available Scripts."
echo "##################"$STAND
echo ""
echo "$AvailableScripts"
echo ""
echo $RED"["$GREEN"1-$LineCount"$RED"]"$GREEN" = Choose A Script.$STAND"
echo ""
read -p $GREEN"Please choose an option:$STAND " ScriptOption

ValidOptionCheck=$(echo "$ScriptOption" | grep -e '[1-9]' -e '[1-9][0-9]')
if [[ $ValidOptionCheck ]]; then

   if [[ "$ScriptOption" -le "$LineCount" ]]; then

      ChosenScript=$(echo "$AvailableScripts" | sed -n ""$ScriptOption"p" | awk '{print substr($0, index($0, $2))}' | sed 's/^[ \t]*//;s/[ \t]*$//')
      ValidOptionCheck=$(echo "Continue")

   fi

fi

case $ValidOptionCheck in
Continue)
break ;;
*) ;;
esac
done

while true
do

clear
read -p $GREEN"Does the script require a monitor mode interface?,$STAND y/n:$STAND " MonitorModeOption
echo ""

case $MonitorModeOption in
y|n)
break ;;
*) ;;
esac
done

if [[ $MonitorModeOption  == "y" ]]; then

   while true
   do

   DetectedMonitorInterfaces=$(cat /proc/net/dev | sed '/mon/!d' | sed 's/://g' | awk '{ print $1 }' | sort)

   clear
   echo $RED"Detected Monitor Mode Interfaces:$STAND"
   echo ""
   echo "$DetectedMonitorInterfaces"
   echo ""
   read -p $GREEN"Would you like to create a monitor mode interface?,$STAND y/n:$STAND " CreateAmountOption

   case $CreateAmountOption in
   y|n)
   break ;;
   *) echo "Invalid Option, please try again." ;;
   esac
   done

   if [[ $CreateAmountOption == "y" ]]; then

      while true
      do

      clear
      echo $RED"Networking services need to be stopped so the interfaces can be setup, networking services will be re-enabled within a few seconds."$STAND
      echo ""
      read -p $GREEN"Is it ok to kill these services?,$STAND y/n: " KillOption

      case $KillOption in
      y|n)
      break ;;
      *) echo "Invalid Option, please try again." ;;
      esac
      done

      if [[ $KillOption == "y" ]]; then

         clear
         $DIR/Applications/New_airmon-ng check kill

      fi

      if [[ $KillOption == "n" ]]; then

         MainMenu

      fi

      while true
      do

      echo ""
      read -p $GREEN"How many monitor mode interfaces do you want to create?:$STAND " CreateAmount

      ValidOptionCheck1=$(echo "$CreateAmount" | grep -e "[1-9]" -e "[1-9][0-9]")
      if [[ $ValidOptionCheck1 ]]; then

         ValidOptionCheck2=$(echo "$ValidOptionCheck1" | grep "[a-zA-Z]")
         if [[ ! $ValidOptionCheck2 ]]; then

            OptionCheck=$(echo "PROCEED")

         else

            OptionCheck=$(echo "Invalid Option")

         fi

      else

         OptionCheck=$(echo "Invalid Option")

      fi

      case $OptionCheck in
      PROCEED)
      break ;;
      *) echo "Invalid Option, please try again." ;;
      esac
      done

      MultipleInterfacesCheck=$($DIR/Applications/Old_airmon-ng | sed -e '/wlan/!d' -e '/FSwlan/d' -e 's/mon//g' | nl -ba -w 1  -s ': ' | grep "2:")
      if [[ $MultipleInterfacesCheck ]]; then

         while true
         do

         DetectedWiFiDevices=$($DIR/Applications/Old_airmon-ng | sed -e '/wlan/!d' -e '/FSwlan/d' -e 's/mon//g' -e 's/-//g' | column -t)
         LineCount=$(echo "$DetectedWiFiDevices" | wc -l)

         echo ""
         echo $RED"Detected WiFi Interfaces:$STAND"
         echo ""
         echo "$DetectedWiFiDevices" | nl -ba -w 1  -s ': '
         echo ""
         echo $RED"["$GREEN"1-$LineCount"$RED"]"$GREEN" = Select A WiFi Interface."$STAND
         echo $RED"["$GREEN"m"$RED"]"$GREEN" = Return To The Main Menu."$STAND
         echo $RED"["$GREEN"q"$RED"]"$GREEN" = Exit FrankenScript."$STAND
         echo ""
         echo $RED"NOTE:"$STAND
         echo $RED"The WiFi device will be used to create monitor mode interfaces."$STAND
         echo ""
         read -p $GREEN"Please input an option:$STAND " WiFiDeviceOption

         if [[ $WiFiDeviceOption == "m" ]]; then

            MainMenu

         fi

         if [[ $WiFiDeviceOption == "q" ]]; then

            ExitFrankenScript

         fi

         ValidOptionCheck=$(echo "$WiFiDeviceOption" | grep "[1-$LineCount]")
         if [[ $ValidOptionCheck ]]; then

            CreationDevice=$(echo "$DetectedWiFiDevices" | sed -n ""$WiFiDeviceOption"p" | awk '{ print $1 }')

            OptionCheck=$(echo "PROCEED")

         else

            OptionCheck=$(echo "Invalid Option")

         fi

         case $OptionCheck in
         PROCEED)
         break ;;
         *) echo "Invalid Option, please try again." ;;
         esac
         done

      else

         CreationDevice=$($DIR/Applications/Old_airmon-ng | sed -e '/wlan/!d' -e '/FSwlan/d' -e 's/mon//g' | column -t | awk '{ print $1 }')

         echo ""
         echo $RED"Only 1 WiFi interface was found."$STAND
         echo ""
         echo $RED"NOTE:"$STAND
         echo $RED"The WiFi device$STAND $CreationDevice$RED will be used to create the monitor mode interfaces."$STAND
         sleep 3

      fi

      echo ""
      echo $RED"Changing the mac address for$STAND $CreationDevice$RED to$STAND 00:11:22:33:44:55."$STAND
      ifconfig $CreationDevice down
      macchanger --mac 00:11:22:33:44:55 $CreationDevice
      ifconfig $CreationDevice up

      if [ ! -f /etc/network/interfaces.bak ];
      then

         cp /etc/network/interfaces /etc/network/interfaces.bak

      fi

      MonitorModeCreation=$(for i in `seq $CreateAmount`; do echo "$DIR/Applications/Old_airmon-ng start $CreationDevice";done)
      echo "$MonitorModeCreation" > $DIR/TempFolder/MonitorModeCreation.txt
      chmod +x $DIR/TempFolder/MonitorModeCreation.txt
      $DIR/TempFolder/MonitorModeCreation.txt

      MonitorModeBlacklist=$($DIR/Applications/Old_airmon-ng | grep "^mon" | awk '{ print $1 }' | sed -e 's/^/iface /g' | sed 's/$/ inet manual/g')
      echo "" >> /etc/network/interfaces
      echo "$MonitorModeBlacklist" >> /etc/network/interfaces

      DownInterfaces=$($DIR/Applications/Old_airmon-ng | grep "^mon" | awk '{ print $1 }' | sed -e 's/^/ifconfig /g' | sed 's/$/ down/g')
      echo "$DownInterfaces" > $DIR/TempFolder/DownInterfaces.txt

      ChangeMACs=$($DIR/Applications/Old_airmon-ng | grep "^mon" | awk '{ print $1 }' | sed -e 's/^/macchanger --mac 00:11:22:33:44:55 /g')
      echo "$ChangeMACs" > $DIR/TempFolder/ChangeMACs.txt

      UpInterfaces=$($DIR/Applications/Old_airmon-ng | grep "^mon" | awk '{ print $1 }' | sed -e 's/^/ifconfig /g' | sed 's/$/ up/g')
      echo "$UpInterfaces" > $DIR/TempFolder/UpInterfaces.txt

      chmod +x $DIR/TempFolder/DownInterfaces.txt
      chmod +x $DIR/TempFolder/ChangeMACs.txt
      chmod +x $DIR/TempFolder/UpInterfaces.txt

      $DIR/TempFolder/DownInterfaces.txt
      $DIR/TempFolder/ChangeMACs.txt
      $DIR/TempFolder/UpInterfaces.txt

      rm $DIR/TempFolder/ChangeMACs.txt
      rm $DIR/TempFolder/DownInterfaces.txt
      rm $DIR/TempFolder/MonitorModeCreation.txt
      rm $DIR/TempFolder/UpInterfaces.txt

      echo ""
      echo $RED"Restarting networking services."$STAND

      service NetworkManager start

      ifconfig $wlanX up &> /dev/null

      DetectedMonitorInterfaces=$(cat /proc/net/dev | sed '/mon/!d' | sed 's/://g' | awk '{ print $1 }' | sort)

   fi

fi

if [[ $DetectedMonitorInterfaces ]]; then

   clear
   echo $RED"Available Monitor Modes:"$STAND
   echo $STAND"$DetectedMonitorInterfaces"$STAND
   echo ""
   echo $RED"Chosen Script:"$STAND
   echo $STAND"$ChosenScript"$STAND

else

   clear
   echo $RED"Chosen Script:"$STAND
   echo $STAND"$ChosenScript"$STAND

fi

while true
do

echo ""
read -p $GREEN"Would you like to add any arguments/commands,$STAND y/n:$STAND " ArgumentsOption

case $ArgumentsOption in
y|n)
break ;;
*) ;;
esac
done

if [[ $ArgumentsOption == "y" ]]; then

   while true
   do

   clear

   if [[ $DetectedMonitorInterfaces ]]; then

      echo $RED"Available Monitor Modes:"$STAND
      echo $STAND"$DetectedMonitorInterfaces"$STAND
      echo ""
      echo $RED"Chosen Script:"$STAND
      echo $STAND"$ChosenScript"$STAND

   else

      echo $RED"Chosen Script:"$STAND
      echo $STAND"$ChosenScript"$STAND

   fi

   echo ""
   echo $RED"Note:"$STAND
   echo $RED"To add to the beginning input$STAND START=<arguments/commands>"$STAND
   echo $RED"To add to the end input$STAND END=<arguments/commands>"$STAND
   echo $RED"Input example:$STAND START=python END=-1 -W"$STAND
   echo ""
   read -p $GREEN"Please input the script arguments/commands:$STAND " ScriptArguments

   ArgumentsCheck1=$(echo "$ScriptArguments" | sed '/START=/!d; /END=/!d')
   if [[ $ArgumentsCheck1 ]]; then

      StartOfScript=$(echo "$ScriptArguments" | sed 's/END.*//' | sed 's/START=//g' | sed 's/^[ \t]*//;s/[ \t]*$//')
      EndOfScript=$(echo "$ScriptArguments" | grep -o 'END.*' | sed 's/END=//g' | sed 's/^[ \t]*//;s/[ \t]*$//')
      ScriptAndArguments=$(echo "$StartOfScript $ChosenScript $EndOfScript")

   else

      ArgumentsCheck2=$(echo "$ScriptArguments" | sed '/START=/!d')
      if [[ $ArgumentsCheck2 ]]; then

         StartOfScript=$(echo "$ScriptArguments" | grep -o 'START=.*' | sed 's/START=//g' | sed 's/^[ \t]*//;s/[ \t]*$//')
         ScriptAndArguments=$(echo "$StartOfScript $ChosenScript")

      else

         ArgumentsCheck3=$(echo "$ScriptArguments" | sed '/END=/!d')
         if [[ $ArgumentsCheck3 ]]; then

            EndOfScript=$(echo "$ScriptArguments" | grep -o 'END.*' | sed 's/END=//g' | sed 's/^[ \t]*//;s/[ \t]*$//')
            ScriptAndArguments=$(echo "$ChosenScript $EndOfScript")

         fi

      fi

   fi

   echo ""
   echo "$ScriptAndArguments"
   echo ""
   read -p $GREEN"Are the above details correct?,$STAND y/n:$STAND " ConfirmOption

   if [[ $ConfirmOption == "y" ]]; then

      ContinueCheck=$(echo "PROCEED")

   fi

   case $ContinueCheck in
   PROCEED)
   break ;;
   *) ;;
   esac
   done

   ScriptAndArguments=$(echo "$ScriptAndArguments" | sed "s|$ChosenScript|$DIR/ScriptLauncher/$ChosenScript|g")
   echo "$ScriptAndArguments" > $DIR/TempFolder/ScriptAndArguments.txt

fi

if [[ $ArgumentsOption == "n" ]]; then

   echo "$DIR/ScriptLauncher/$ChosenScript" > $DIR/TempFolder/ScriptAndArguments.txt


fi

chmod +x $DIR/TempFolder/ScriptAndArguments.txt
gnome-terminal --execute bash -c "$DIR/TempFolder/ScriptAndArguments.txt; bash"

}

RecoveredPasskeys(){

PasskeysCheck=$(ls $DIR/Passkeys | grep ".txt")
if [[ $PasskeysCheck ]]; then

   while true
   do

   Passkeys=$(ls -l $DIR/Passkeys | grep ".txt" | sed -e '/txt~/d' | rev | awk '{ print $1 }' | rev)
   Passkeys_List=$(echo "$Passkeys" | nl -ba -w 1 -s ': ' | column -t)
   LineCount=$(echo "$Passkeys_List" | wc -l)

   clear
   echo $RED"Recovered Passkey's:"
   echo "####################"$STAND
   echo ""
   echo "$Passkeys_List"
   echo ""
   echo $RED"################################"$STAND
   echo $RED"#                              #"$STAND
   echo $RED"# ["$GREEN"1-$LineCount"$RED"]"$GREEN" = Display Paskey File $RED#"$STAND
   echo $RED"# ["$GREEN"m"$RED"]"$GREEN" = Return To Main Menu    $RED#"$STAND
   echo $RED"#                              #"$STAND
   echo $RED"################################"$STAND
   echo ""
   read -p $GREEN"Input an Option$STAND: " ChosenOption

   if [[ $ChosenOption == "m" ]]; then

      MainMenu

   fi

   ValidOptionCheck=$(echo "$ChosenOption" | grep -e '[1-9]' -e '[1-9][0-9]' -e '[1-9][0-9][0-9]')
   if [[ $ValidOptionCheck ]]; then

      if [[ "$ChosenOption" -le "$LineCount" ]]; then

         ChosenPasskeyFile=$(echo "$Passkeys" | sed -n ""$ChosenOption"p")
         DisplayPasskeyFile=$(cat $DIR/Passkeys/$ChosenPasskeyFile)
         clear
         echo "$DisplayPasskeyFile"
         echo ""
         read -p $GREEN"Press $RED[Enter]$GREEN to continue."$STAND
         clear

      fi

   fi

   done

else

   clear
   echo $RED"No recovered passkeys were found."$STAND
   echo ""
   read -p $GREEN"Press $RED[Enter]$GREEN to continue."$STAND
   clear

fi

}

ExitFrankenScript(){

if [ -f $DIR/TempFolder/WiFiConnection.txt ];
then

   ConnectionInterface=$(cat $DIR/TempFolder/WiFiConnection.txt | awk '{ print $1 }')
   ConnectionESSID=$(cat $DIR/TempFolder/WiFiConnection.txt | awk '{ print $2 }')

   ConnectedInterface=$(/sbin/iw $ConnectionInterface link | grep "Connected to")
   if [[ $ConnectedInterface ]]; then

      echo $RED"Disconnecting$STAND $ConnectionInterface$RED from$STAND $ConnectionESSID$RED, please wait..."$STAND

      ifdown $ConnectionInterface

   fi

   rm $DIR/TempFolder/WiFiConnection.txt

fi

if [ -f /etc/network/interfaces.bak ];
then

   rm /etc/network/interfaces
   cp /etc/network/interfaces.bak /etc/network/interfaces

   if [ -f /etc/network/interfaces ];
   then

      rm /etc/network/interfaces.bak

   fi

fi

MonitorModeCheck=$($DIR/Applications/Old_airmon-ng | grep -e "^mon" -e "FSwlan")
if [[ $MonitorModeCheck ]]; then

   service NetworkManager stop

   FSwlanXmonKill=$($DIR/Applications/Old_airmon-ng | grep -e "^mon" -e "FSwlan" | awk '{ print $1 }' | sed -e 's/^/iw /g' -e 's/$/ del/g')

   echo "$FSwlanXmonKill" > $DIR/TempFolder/RemoveMonitorModes
   chmod +x $DIR/TempFolder/RemoveMonitorModes
   $DIR/TempFolder/RemoveMonitorModes
   rm $DIR/TempFolder/RemoveMonitorModes

   service NetworkManager start

fi

rm $DIR/TempFolder/*.txt &> /dev/null

exit

}

RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
STAND=$(tput sgr0 && tput bold)

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

chmod +x $DIR/Applications/*

wmctrlCheck=$(dpkg --get-selections | grep "^wmctrl")
if [[ ! $wmctrlCheck ]]; then

   while true
   do

   clear
   echo $RED"wmctrl is required but doesn't appear to be installed in Kali."$STAND
   echo ""
   echo $RED"["$GREEN"1"$RED"]"$GREEN" = Install wmctrl"$STAND
   echo $RED"["$GREEN"q"$RED"]"$GREEN" = Exit FrankenScript"$STAND
   echo ""
   read -p $GREEN"Please choose an option:$STAND " ChosenOption

   case $ChosenOption in
   1|q)
   break ;;
   *) ;;
   esac
   done

   if [[ $ChosenOption == "1" ]]; then

      ArchitectureType=$(uname -m | grep "x86_64")
      if [[ $ArchitectureType ]]; then

         dpkg -i $DIR/Archives/wmctrl_1.07-7_amd64.deb

      else

         dpkg -i $DIR/Archives/wmctrl_1.07-7_i386.deb

      fi

   fi

   if [[ $ChosenOption == "q" ]]; then

      exit

   fi

fi

if [ -f $DIR/TempFolder/WiFiConnection.txt ];
then

   ConnectionInterface=$(cat $DIR/TempFolder/WiFiConnection.txt | awk '{ print $1 }')
   ConnectionESSID=$(cat $DIR/TempFolder/WiFiConnection.txt | awk '{ print $2 }')

   ConnectedInterface=$(/sbin/iw $ConnectionInterface link | grep "Connected to")
   if [[ $ConnectedInterface ]]; then

      echo $RED"Disconnecting$STAND $ConnectionInterface$RED from$STAND $ConnectionESSID$RED, please wait..."$STAND

      ifdown $ConnectionInterface

   fi

   rm $DIR/TempFolder/WiFiConnection.txt

fi

rm $DIR/TempFolder/*.txt &> /dev/null
rm $DIR/TempFolder/*.csv &> /dev/null
rm $DIR/TempFolder/*.cap &> /dev/null
rm $DIR/TempFolder/*.netxml &> /dev/null

MainMenu
