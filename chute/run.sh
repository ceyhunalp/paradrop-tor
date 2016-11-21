#!/bin/bash

# Get wlan0 IP addr

wlanAddr=''
while [ "$wlanAddr" == "" ]; do
    sleep 1
    #wlanAddr=$(ifconfig -a | grep -A 2 "wlan0\." | grep 'inet addr:192.168' | awk '{print $2}' | awk -F':' '{print $2}')
    wlanAddr=$(ifconfig -a | grep 'inet addr:192.168' | awk '{print $2}' | awk -F':' '{print $2}')
done

# Write tor config
echo "Log notice file /var/log/tor/notices.log" >> /etc/tor/torrc
echo "VirtualAddrNetwork 10.192.0.0/10" >> /etc/tor/torrc
echo "AutomapHostsSuffixes .onion,.exit" >> /etc/tor/torrc
echo "AutomapHostsOnResolve 1" >> /etc/tor/torrc
echo "TransPort 9040" >> /etc/tor/torrc
echo "TransListenAddress $wlanAddr" >> /etc/tor/torrc
echo "DNSPort 53" >> /etc/tor/torrc
echo "DNSListenAddress $wlanAddr" >> /etc/tor/torrc

# Modify /etc/resolv.conf so that DNS queries go through Tor

rm /etc/resolv.conf
echo "nameserver 127.0.0.1" >> /etc/resolv.conf

# iptables configuration
iptables -F
iptables -t nat -F
iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 22 -j REDIRECT --to-ports 22
iptables -t nat -A PREROUTING -i wlan0 -p udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -i wlan0 -p tcp --syn -j REDIRECT --to-ports 9040

# Transparently redirect any traffic destined for the Tor virtual address space through the Tor transport port we designated above
iptables -A INPUT -p tcp --dport 9040 -j ACCEPT
iptables -t nat -A PREROUTING -i wlan0 -p tcp -d 10.192.0.0/11 -j REDIRECT --to-port 9040
iptables -t nat -A OUTPUT -p tcp -d 10.192.0.0./10 -j REDIRECT --to-ports 9040

# Redirect HTTP traffic to the proxy.
iptables -A PREROUTING -t nat -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 8080

# Required for forwarding everything else (e.g. DNS).
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Start tor service
service tor start

# Start the proxy.
#service privoxy force-reload
#service dansguardian start

while true; do
    sleep 300
done

# If execution reaches this point, the chute will stop running.
exit 0
