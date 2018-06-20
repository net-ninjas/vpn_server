#!/bin/bash

if [ -z "$1" ]
  then
    echo "No argument supplied..."
    echo "Usage: generateNewClient <clientA>"
        exit 1
fi

cd /etc/openvpn/easy-rsa/
./easyrsa build-client-full $1 nopass


# Generates the custom client.ovpn
cp $(dirname "$0")/client-common.txt /tmp/$1.ovpn
echo "<ca>" >> /tmp/$1.ovpn
cat /etc/openvpn/ca.crt >> /tmp/$1.ovpn
echo "</ca>" >> /tmp/$1.ovpn
echo "<cert>" >> /tmp/$1.ovpn
cat /etc/openvpn/issued/$1.crt >> /tmp/$1.ovpn
echo "</cert>" >> /tmp/$1.ovpn
echo "<key>" >> /tmp/$1.ovpn
cat /etc/openvpn/private/$1.key >> /tmp/$1.ovpn
echo "</key>" >> /tmp/$1.ovpn
echo "<tls-auth>" >> /tmp/$1.ovpn
cat /etc/openvpn/ta.key >> /tmp/$1.ovpn
echo "</tls-auth>" >> /tmp/$1.ovpn

cat /tmp/$1.ovpn
