#!/bin/bash

TXT_RED="\033[1;31m"
TXT_GREEN="\033[1;32m"
TXT_YELLOW="\033[1;33m"
TXT_BLUE="\033[1;34m"
FANCY_RESET="\033[0m"

set -eu

print_color () {
    echo -e "$1$2$FANCY_RESET"
}

cat > /etc/systemd/network/enp0s2.network << EOF
[Match]
Name=enp0s2

[Network]
DHCP=yes

[DHCPv4]
UseDomains=true
EOF

systemctl enable systemd-networkd
systemctl enable systemd-resolved

ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

systemctl start systemd-networkd
systemctl start systemd-resolved

systemctl daemon-reload

systemctl restart systemd-networkd
systemctl restart systemd-resolved

print_color "$TXT_GREEN" "Internet is set :)"