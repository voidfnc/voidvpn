#!/bin/bash
# OpenVPN Setup Script for Ubuntu (Improved)
# voidfnc
# Date: 2025-05-17
# Updated with dynamic interface detection, TCP/UDP fixes, and security enhancements
# 2025-06-11: Updated to use data-ciphers for OpenVPN 2.5+ compatibility

#### Latest Edits / Updates here:
## 2025-06-11 - Now uses data-ciphers and data-ciphers-fallback in both server and client configs for OpenVPN 2.5+ compatibility.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[+] $1${NC}"
}
print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}
print_error() {
    echo -e "${RED}[-] $1${NC}"
}

if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root"
   echo "Please run with sudo or as root"
   exit 1
fi

DEFAULT_INTERFACE=$(ip route | grep default | awk '{print $5}')
if [[ -z "$DEFAULT_INTERFACE" ]]; then
    print_error "Could not detect primary network interface!"
    exit 1
fi

IP_ADDRESS=$(ip -4 addr show "$DEFAULT_INTERFACE" | grep inet | awk '{print $2}' | cut -d '/' -f 1)
if [[ -z "$IP_ADDRESS" ]]; then
    IP_ADDRESS=$(curl -s https://api.ipify.org)
fi

read -p "Enter a name for the client certificate [client]: " CLIENT_NAME
CLIENT_NAME=${CLIENT_NAME:-client}

DEFAULT_PORT=1194
read -p "Enter the port for OpenVPN [${DEFAULT_PORT}]: " PORT
PORT=${PORT:-$DEFAULT_PORT}

echo "Select protocol:"
echo "1) UDP (recommended for performance)"
echo "2) TCP (better for restrictive networks)"
read -p "Protocol [1]: " PROTOCOL_CHOICE
PROTOCOL_CHOICE=${PROTOCOL_CHOICE:-1}
if [[ "$PROTOCOL_CHOICE" == "1" ]]; then
    PROTOCOL="udp"
else
    PROTOCOL="tcp"
fi

print_status "Starting OpenVPN installation and setup..."

print_status "Updating system packages..."
apt-get update
apt-get upgrade -y

print_status "Installing OpenVPN and Easy-RSA..."
apt-get install -y openvpn easy-rsa

if [ -d "/etc/openvpn" ]; then
    print_status "Backing up existing OpenVPN configuration..."
    BACKUP_DIR="/etc/openvpn-backup-$(date +%Y%m%d-%H%M%S)"
    cp -r /etc/openvpn "$BACKUP_DIR"
    print_warning "Existing OpenVPN config backed up to $BACKUP_DIR"
fi

print_status "Setting up Certificate Authority..."
mkdir -p /etc/openvpn/easy-rsa
cp -R /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
cd /etc/openvpn/easy-rsa

print_status "Initializing PKI..."
./easyrsa init-pki

print_status "Building Certificate Authority..."
./easyrsa --batch --req-cn="OpenVPN-CA" build-ca nopass

print_status "Generating server certificate and key..."
./easyrsa --batch build-server-full server nopass

print_status "Generating client certificate and key for $CLIENT_NAME..."
./easyrsa --batch build-client-full "$CLIENT_NAME" nopass

print_status "Generating Diffie-Hellman parameters (this may take a while)..."
./easyrsa gen-dh

print_status "Generating TLS-Auth key..."
openvpn --genkey secret /etc/openvpn/ta.key

print_status "Copying certificates and keys..."
cp pki/ca.crt /etc/openvpn/
cp pki/issued/server.crt /etc/openvpn/
cp pki/private/server.key /etc/openvpn/
cp pki/dh.pem /etc/openvpn/

print_status "Creating server configuration..."
cat > /etc/openvpn/server.conf << EOF
port $PORT
proto $PROTOCOL
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0
data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305:AES-256-CBC
data-ciphers-fallback AES-256-CBC
auth SHA256
user nobody
group nogroup
keepalive 10 120
persist-key
persist-tun
status openvpn-status.log
log-append /var/log/openvpn.log
verb 3
# Only add explicit-exit-notify for UDP
$( [[ "$PROTOCOL" == "udp" ]] && echo "explicit-exit-notify 1" )

# Network configuration
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
EOF

print_status "Enabling IP forwarding..."
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-openvpn.conf
sysctl --system

print_status "Configuring firewall..."
if command -v ufw > /dev/null; then
    apt-get install -y ufw
    ufw allow ssh
    ufw allow $PORT/$PROTOCOL
    sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw
    cat > /etc/ufw/before.rules << EOF
# START OPENVPN RULES
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.8.0.0/24 -o $DEFAULT_INTERFACE -j MASQUERADE
COMMIT
# END OPENVPN RULES
EOF
    ufw --force enable
else
    apt-get install -y iptables-persistent
    iptables -A INPUT -i $DEFAULT_INTERFACE -m state --state NEW -p $PROTOCOL --dport $PORT -j ACCEPT
    iptables -A FORWARD -i tun0 -j ACCEPT
    iptables -A FORWARD -i tun0 -o $DEFAULT_INTERFACE -s 10.8.0.0/24 -j ACCEPT
    iptables -A FORWARD -i $DEFAULT_INTERFACE -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $DEFAULT_INTERFACE -j MASQUERADE
    netfilter-persistent save
fi

print_status "Starting and enabling OpenVPN service..."
systemctl start openvpn@server
systemctl enable openvpn@server

print_status "Creating client configuration..."
mkdir -p /etc/openvpn/client-configs/files
chmod 700 /etc/openvpn/client-configs/files

cat > /etc/openvpn/client-configs/base.conf << EOF
client
dev tun
proto $PROTOCOL
remote $IP_ADDRESS $PORT
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305:AES-256-CBC
data-ciphers-fallback AES-256-CBC
auth SHA256
key-direction 1
verb 3
EOF

cat > /etc/openvpn/client-configs/make_config.sh << 'EOF'
#!/bin/bash
CLIENT=$1
OUTPUT_DIR="/etc/openvpn/client-configs/files"
BASE_CONFIG="/etc/openvpn/client-configs/base.conf"
cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    /etc/openvpn/easy-rsa/pki/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    /etc/openvpn/easy-rsa/pki/issued/${CLIENT}.crt \
    <(echo -e '</cert>\n<key>') \
    /etc/openvpn/easy-rsa/pki/private/${CLIENT}.key \
    <(echo -e '</key>\n<tls-auth>') \
    /etc/openvpn/ta.key \
    <(echo -e '</tls-auth>\nkey-direction 1') \
    > ${OUTPUT_DIR}/${CLIENT}.ovpn
chmod 600 ${OUTPUT_DIR}/${CLIENT}.ovpn
EOF

chmod 700 /etc/openvpn/client-configs/make_config.sh

print_status "Generating client configuration file..."
bash /etc/openvpn/client-configs/make_config.sh "$CLIENT_NAME"

chown -R root:root /etc/openvpn/client-configs
cp "/etc/openvpn/client-configs/files/${CLIENT_NAME}.ovpn" "/root/${CLIENT_NAME}.ovpn"
chmod 600 "/root/${CLIENT_NAME}.ovpn"

print_status "OpenVPN setup completed!"
print_status "Your client configuration file is available at: /root/${CLIENT_NAME}.ovpn"
print_status "Copy this file to your client device to connect to the VPN server."
print_status "You can create additional client configurations with:"
print_status "cd /etc/openvpn/easy-rsa/ && ./easyrsa --batch build-client-full CLIENT_NAME nopass && bash /etc/openvpn/client-configs/make_config.sh CLIENT_NAME"

print_status "Current OpenVPN status:"
systemctl status openvpn@server
