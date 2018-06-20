#!/bin/bash
DIR=$(dirname "$0")
cd $DIR

sudo apt update
sudo apt -y dist-upgrade
sudo apt -y install openvpn easy-rsa htop python3-flask python3-requests git curl

sudo cp server.conf /etc/openvpn/
sudo ./create_certs.sh
 
if [ -x /usr/sbin/ufw ] ; then
	sudo sed -i '/### RULES ###/a ### tuple ### allow tcp 8000 0.0.0.0/0 any 0.0.0.0/0 in\n-A ufw-user-input -p tcp --dport 8000 -j ACCEPT\n### tuple ### allow tcp 5000 0.0.0.0/0 any 0.0.0.0/0 in\n-A ufw-user-input -p tcp --dport 5000 -j ACCEPT' /etc/ufw/user.rules
	sudo ufw reload
fi

sudo service openvpn restart

echo "@reboot cd $DIR && python3 ninja_server.py" > /tmp/cron
echo "@reboot cd $DIR && iptables.sh" >> /tmp/cron
sudo crontab -l -u root | cat - /tmp/cron | sudo crontab -u root -

sudo $DIR/iptables.sh

CCIPADDRESS=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
sed -i s/__MYIP__/$CCIPADDRESS/g $DIR/server_config.ini
sed -i s/__MYIP__/$CCIPADDRESS/g $DIR/client-common.txt


cd $DIR && python3 ninja_server.py &
sleep 15
VPNSERVERS=$(curl https://btc.oodi.co.il/netninja/get_servers/100)
IPTOCHECK=$(cat /tmp/current_ip)
echo "VPNSERVERS = $VPNSERVERS"
echo "IPTOCHECK = $IPTOCHECK"
if [[ $VPNSERVERS = *"$IPTOCHECK"* ]]; then
  echo "GOOD!! IP of New VPN Added to VPN lists!"
else
  echo "BAD!! IP not added to VPN lists"
fi
