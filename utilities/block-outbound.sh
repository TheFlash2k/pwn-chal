#!/bin/sh

# Only delete this if there's KERNEL isn't set.
if [ -z "$KERNEL" ]; then rm -- "$0"; fi

iptables -F
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT DROP

# This will allow inbound traffic if it was established sucessfully.
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# This will specifically block connections to the host network (trying to access the flag generating server)
iptables -A OUTPUT -d 172.17.0.1 -j DROP