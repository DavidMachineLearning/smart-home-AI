from phue import Bridge
import os
import re
import sys


ip = ""
usage = "USAGE:  sudo python3 initial_setup.py [ip address]"

if len(sys.argv) == 2:
    ip = str(sys.argv[1])


elif len(sys.argv) == 1:
    
    print("Searching Philips Hue Bridge IP, this might take up to 1 minute...")
    
    # get Jetson IP address
    ifconfig_output = os.popen("ifconfig").read()
    jetson_ip_match = re.search("192.168.\d+", ifconfig_output)
    
    if jetson_ip_match:
        # search Philips Hue IP address
        jetson_ip = jetson_ip_match.group(0)
        output = os.popen(f"sudo netdiscover -r {jetson_ip}.0/24 -P -N | grep Philips").read()
        match = re.search("[\d\.]+", output)

        if match:
            ip = match.group(0)
            print(f"Found Philips Hue Bridge with IP: {ip}")
        else:
            print("Philips Hue Bridge IP not found, please specify it manually.")
            print(usage)
    else:
        print("Couldn't find jetson IP address, make sure it is connected to a router.")
        print(usage)

else:
    print("Too many arguments passed!")
    print(usage)

if ip:
    input("Press the button on the Philips Hue Bridge and then press enter to continue...")
    hue_bridge = Bridge(ip)
    hue_bridge.connect()
