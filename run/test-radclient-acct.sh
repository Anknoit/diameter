#!/bin/bash

# RADIUS Accounting Test with radclient
# This script sends accounting requests to the Seagull RADIUS server

RADIUS_SERVER="156.238.98.73"
RADIUS_PORT="1813"
SHARED_SECRET="root@123"

echo "============================================"
echo "RADIUS Accounting Test with radclient"
echo "============================================"
echo "Server: $RADIUS_SERVER:$RADIUS_PORT"
echo "Shared Secret: $SHARED_SECRET"
echo "============================================"
echo ""

# Check if radclient is installed
if ! command -v radclient &> /dev/null; then
    echo "❌ radclient not found!"
    echo ""
    echo "Install it with:"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install freeradius-utils"
    echo ""
    exit 1
fi

echo "✅ radclient found"
echo ""

# Test 1: Accounting Start
echo "📤 Sending Accounting-Request (Start)..."
echo "----------------------------------------"

echo "Acct-Status-Type=Start,\
Acct-Terminate-Cause=Admin-Reset,\
NAS-IP-Address=127.0.0.1,\
Acct-Delay-Time=0,\
User-Name=S4534553635,\
Service-Type=Callback-NAS-Prompt,\
Framed-Protocol=PPP,\
Framed-IP-Address=172.23.17.104,\
Framed-IP-Netmask=255.255.255.240,\
NAS-Identifier=bgl-cpf-dell-bgl-01,\
Acct-Session-Id=radclient-test-$(date +%s),\
Acct-Multi-Session-Id=Y000000D3BBD4A04C000000D2,\
Acct-Authentic=RADIUS,\
Acct-Session-Time=990,\
Acct-Input-Octets=6990,\
Acct-Output-Octets=7990,\
Calling-Station-Id=lag-10:3051.148" | \
radclient -x $RADIUS_SERVER:$RADIUS_PORT acct $SHARED_SECRET

echo ""
echo "----------------------------------------"

# Wait a bit
sleep 2

# Test 2: Accounting Stop
echo ""
echo "📤 Sending Accounting-Request (Stop)..."
echo "----------------------------------------"

echo "Acct-Status-Type=Stop,\
Acct-Terminate-Cause=Admin-Reset,\
NAS-IP-Address=127.0.0.1,\
Acct-Delay-Time=0,\
User-Name=S4534553635,\
Service-Type=Callback-NAS-Prompt,\
Framed-Protocol=PPP,\
Framed-IP-Address=172.23.17.104,\
Framed-IP-Netmask=255.255.255.240,\
NAS-Identifier=bgl-cpf-dell-bgl-01,\
Acct-Session-Id=radclient-test-$(date +%s),\
Acct-Multi-Session-Id=Y000000D3BBD4A04C000000D2,\
Acct-Authentic=RADIUS,\
Acct-Session-Time=1490,\
Acct-Input-Octets=13980,\
Acct-Output-Octets=15980,\
Calling-Station-Id=lag-10:3051.148" | \
radclient -x $RADIUS_SERVER:$RADIUS_PORT acct $SHARED_SECRET

echo ""
echo "----------------------------------------"
echo ""
echo "✅ Test completed!"
echo ""
echo "💡 Tips:"
echo "  - Use -x flag for debug output"
echo "  - Capture with: sudo tcpdump -i lo -w radius.pcap port 1813"
echo "  - View in Wireshark with shared secret: $SHARED_SECRET"
echo ""
