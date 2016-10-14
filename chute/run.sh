#!/bin/bash

# Get wlan0 IP addr
wlanAddr = $(ifconfig -a | grep 'inet addr:192.168' | awk '{print $2}' | awk -F':' '{print $2}')

# Write tor config


# Redirect HTTP traffic to the proxy.
#iptables -A PREROUTING -t nat -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 8080

# Required for forwarding everything else (e.g. DNS).
#iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Start the proxy.
#service privoxy force-reload
#service dansguardian start

while true; do
    sleep 300
done

# If execution reaches this point, the chute will stop running.
exit 0
