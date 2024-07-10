#!/bin/bash

ln -s /dev/null /etc/systemd/network/99-default.link

cat > /etc/systemd/network/10-ether0.link << "EOF"
[Match]
# Changez l'adresse MAC comme il faut pour votre périphérique réseau
MACAddress=12:34:45:78:90:AB

[Link]
Name=ether0
EOF

cat > /etc/systemd/network/10-eth-static.network << "EOF"
[Match]
Name=<network-device-name>

[Network]
Address=192.168.0.2/24
Gateway=192.168.0.1
DNS=192.168.0.1
Domains=<Your Domain Name>
EOF

cat > /etc/systemd/network/10-eth-dhcp.network << "EOF"
[Match]
Name=<network-device-name>

[Network]
DHCP=ipv4

[DHCPv4]
UseDomains=true
EOF

cat > /etc/resolv.conf << "EOF"
# Début de /etc/resolv.conf

domain <Votre nom de domaine>
nameserver <Adresse IP du DNS primaire>
nameserver <Adresse IP du DNS secondaire>

# Fin de /etc/resolv.conf
EOF

# U can use any other hostname here 
echo "jbettini" > /etc/hostname