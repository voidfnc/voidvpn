#!/bin/bash
# OpenVPN Setup Script for Ubuntu (Improved)
# voidfnc
# Date: 2025-05-17
# Updated with dynamic interface detection, TCP/UDP fixes, and security enhancements


#### Latest Edits / Updates here:
## 5/17/25 - Run into cipher related errors in your log? Apply this fix in your .ovpn config file and openvpn config file on your server.
## Replace:
# cipher AES-256-CBC  
# With:
##data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305:AES-256-CBC
##data-ciphers-fallback AES-256-CBC

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print colored status messages
print_status() {
    echo -e "${GREEN}[+] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

print_error() {
    echo -e "${RED}[-] $1${NC}"
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root"
   echo "Please run with sudo or as root"
   exit 1
fi

# Detect primary network interface
DEFAULT_INTERFACE=$(ip route | grep default | awk '{print $5}')
if [[ -z "$DEFAULT_INTERFACE" ]]; then
    print_error "Could not detect primary network interface!"
    exit 1
fi

# Get the IP address of the server
IP_ADDRESS=$(ip -4 addr show "$DEFAULT_INTERFACE" | grep inet | awk '{print $2}' | cut -d '/' -f 1)
if [[ -z "$IP_ADDRESS" ]]; then
    IP_ADDRESS=$(curl -s https://api.ipify.org)
fi

# Get user input for configuration
read -p "Enter a name for the client certificate [client]: " CLIENT_NAME
CLIENT_NAME=${CLIENT_NAME:-client}

# Default port
DEFAULT_PORT=1194
read -p "Enter the port for OpenVPN [${DEFAULT_PORT}]: " PORT
PORT=${PORT:-$DEFAULT_PORT}

# Protocol selection
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

# Update system
print_status "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install OpenVPN and Easy-RSA
print_status "Installing OpenVPN and Easy-RSA..."
apt-get install -y openvpn easy-rsa

# Backup existing OpenVPN config (if any)
if [ -d "/etc/openvpn" ]; then
    print_status "Backing up existing OpenVPN configuration..."
    BACKUP_DIR="/etc/openvpn-backup-$(date +%Y%m%d-%H%M%S)"
    cp -r /etc/openvpn "$BACKUP_DIR"
    print_warning "Existing OpenVPN config backed up to $BACKUP_DIR"
fi

# Setup the CA directory
print_status "Setting up Certificate Authority..."
mkdir -p /etc/openvpn/easy-rsa
cp -R /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
cd /etc/openvpn/easy-rsa

# Initialize the PKI
print_status "Initializing PKI..."
./easyrsa init-pki

# Build CA (non-interactive)
print_status "Building Certificate Authority..."
./easyrsa --batch --req-cn="OpenVPN-CA" build-ca nopass

# Generate server certificate and key
print_status "Generating server certificate and key..."
./easyrsa --batch build-server-full server nopass

# Generate client certificate and key
print_status "Generating client certificate and key for $CLIENT_NAME..."
./easyrsa --batch build-client-full "$CLIENT_NAME" nopass

# Generate Diffie-Hellman parameters
print_status "Generating Diffie-Hellman parameters (this may take a while)..."
./easyrsa gen-dh

# Generate TLS-Auth key
print_status "Generating TLS-Auth key..."
openvpn --genkey secret /etc/openvpn/ta.key

# Copy certificates and keys to OpenVPN directory
print_status "Copying certificates and keys..."
cp pki/ca.crt /etc/openvpn/
cp pki/issued/server.crt /etc/openvpn/
cp pki/private/server.key /etc/openvpn/
cp pki/dh.pem /etc/openvpn/

# Create server configuration
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
cipher AES-256-CBC
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

# Enable IP forwarding
print_status "Enabling IP forwarding..."
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-openvpn.conf
sysctl --system

# Configure firewall
print_status "Configuring firewall..."
if command -v ufw > /dev/null; then
    # Configure UFW if it's installed
    apt-get install -y ufw
    ufw allow ssh
    ufw allow $PORT/$PROTOCOL
    
    # Enable forwarding in UFW
    sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw
    
    # Add NAT rules (using detected interface)
    cat > /etc/ufw/before.rules << EOF
# START OPENVPN RULES
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.8.0.0/24 -o $DEFAULT_INTERFACE -j MASQUERADE
COMMIT
# END OPENVPN RULES
EOF
    
    # Enable UFW
    ufw --force enable
else
    # Use iptables if UFW is not installed
    apt-get install -y iptables-persistent
    
    # Allow traffic to OpenVPN port
    iptables -A INPUT -i $DEFAULT_INTERFACE -m state --state NEW -p $PROTOCOL --dport $PORT -j ACCEPT
    
    # Allow forwarding
    iptables -A FORWARD -i tun0 -j ACCEPT
    iptables -A FORWARD -i tun0 -o $DEFAULT_INTERFACE -s 10.8.0.0/24 -j ACCEPT
    iptables -A FORWARD -i $DEFAULT_INTERFACE -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    
    # NAT rules
    iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $DEFAULT_INTERFACE -j MASQUERADE
    
    # Save iptables rules
    netfilter-persistent save
fi

# Start and enable OpenVPN service
print_status "Starting and enabling OpenVPN service..."
systemctl start openvpn@server
systemctl enable openvpn@server

# Create client configuration directory
print_status "Creating client configuration..."
mkdir -p /etc/openvpn/client-configs/files
chmod 700 /etc/openvpn/client-configs/files

# Create client base configuration
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
cipher AES-256-CBC
auth SHA256
key-direction 1
verb 3
EOF

# Create client configuration script
cat > /etc/openvpn/client-configs/make_config.sh << 'EOF'
#!/bin/bash

# First argument: Client name

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

# Secure the client config file
chmod 600 ${OUTPUT_DIR}/${CLIENT}.ovpn
EOF

# Make the script executable
chmod 700 /etc/openvpn/client-configs/make_config.sh

# Generate client config
print_status "Generating client configuration file..."
bash /etc/openvpn/client-configs/make_config.sh "$CLIENT_NAME"

# Set ownership
chown -R root:root /etc/openvpn/client-configs

# Copy client config to the home directory for easier access
cp "/etc/openvpn/client-configs/files/${CLIENT_NAME}.ovpn" "/root/${CLIENT_NAME}.ovpn"
chmod 600 "/root/${CLIENT_NAME}.ovpn"

print_status "OpenVPN setup completed!"
print_status "Your client configuration file is available at: /root/${CLIENT_NAME}.ovpn"
print_status "Copy this file to your client device to connect to the VPN server."
print_status "You can create additional client configurations with:"
print_status "cd /etc/openvpn/easy-rsa/ && ./easyrsa --batch build-client-full CLIENT_NAME nopass && bash /etc/openvpn/client-configs/make_config.sh CLIENT_NAME"

# Check OpenVPN status
print_status "Current OpenVPN status:"
systemctl status openvpn@server
