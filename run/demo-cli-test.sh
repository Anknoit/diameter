#!/bin/bash

# All-in-One RADIUS CLI Test
# This script demonstrates the complete workflow

echo "============================================"
echo "RADIUS CLI Testing - Complete Demo"
echo "============================================"
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command -v tshark &> /dev/null; then
    echo "❌ tshark not found. Install with: sudo apt-get install tshark"
    exit 1
fi

if ! command -v radclient &> /dev/null; then
    echo "⚠️  radclient not found. Install with: sudo apt-get install freeradius-utils"
    echo "    (Optional - you can still use Seagull client)"
fi

echo "✅ Prerequisites OK"
echo ""

# Instructions
echo "============================================"
echo "📋 Test Instructions"
echo "============================================"
echo ""
echo "This demo requires 3 terminals:"
echo ""
echo "Terminal 1 (THIS ONE): Will show instructions"
echo "Terminal 2: Run the monitoring script"
echo "Terminal 3: Run the server"
echo ""
echo "Press Enter to continue..."
read

clear

echo "============================================"
echo "STEP 1: Start Traffic Monitor"
echo "============================================"
echo ""
echo "In Terminal 2, run:"
echo ""
echo "  cd /home/ankit/opt/seagull/diameter"
echo "  ./run/monitor-radius-live.sh"
echo ""
echo "This will show RADIUS packets in a table format."
echo ""
echo "Press Enter when Terminal 2 is ready..."
read

clear

echo "============================================"
echo "STEP 2: Start RADIUS Server"
echo "============================================"
echo ""
echo "In Terminal 3, run:"
echo ""
echo "  cd /home/ankit/opt/seagull/diameter"
echo "  ./run/start-radius-acct-server.sh"
echo ""
echo "The server will start listening on port 1813."
echo ""
echo "Press Enter when Terminal 3 is ready..."
read

clear

echo "============================================"
echo "STEP 3: Send Test Requests"
echo "============================================"
echo ""
echo "Now we'll send test requests from THIS terminal."
echo ""
echo "Watch Terminal 2 to see the packets!"
echo ""
echo "Press Enter to send test..."
read

echo ""
echo "📤 Sending Accounting-Request (Start)..."
echo ""

echo "Acct-Status-Type=Start,\
Acct-Terminate-Cause=Admin-Reset,\
NAS-IP-Address=127.0.0.1,\
User-Name=CLI-TEST-USER,\
Acct-Session-Id=cli-demo-$(date +%s),\
Acct-Session-Time=100,\
Acct-Input-Octets=1000,\
Acct-Output-Octets=2000,\
NAS-Identifier=cli-test-nas" | \
radclient -x 127.0.0.1:1813 acct testing123 2>&1 | grep -A 20 "Sending\|Received"

echo ""
echo "✅ Request sent!"
echo ""
echo "Press Enter to send Stop request..."
read

echo ""
echo "📤 Sending Accounting-Request (Stop)..."
echo ""

echo "Acct-Status-Type=Stop,\
Acct-Terminate-Cause=Admin-Reset,\
NAS-IP-Address=127.0.0.1,\
User-Name=CLI-TEST-USER,\
Acct-Session-Id=cli-demo-$(date +%s),\
Acct-Session-Time=500,\
Acct-Input-Octets=5000,\
Acct-Output-Octets=10000,\
NAS-Identifier=cli-test-nas" | \
radclient -x 127.0.0.1:1813 acct testing123 2>&1 | grep -A 20 "Sending\|Received"

echo ""
echo "✅ Request sent!"
echo ""

clear

echo "============================================"
echo "✅ Demo Complete!"
echo "============================================"
echo ""
echo "What you should see:"
echo ""
echo "Terminal 2 (Monitor):"
echo "  - Table showing 4 packets:"
echo "    1. Accounting-Request (Start)"
echo "    2. Accounting-Response"
echo "    3. Accounting-Request (Stop)"
echo "    4. Accounting-Response"
echo ""
echo "Terminal 3 (Server):"
echo "  - Incoming calls: 2"
echo "  - Successful calls: 2"
echo "  - No errors"
echo ""
echo "============================================"
echo "📚 Next Steps"
echo "============================================"
echo ""
echo "1. Try the Seagull client:"
echo "   ./run/start-radius-acct-client.sh"
echo ""
echo "2. View detailed packets:"
echo "   ./run/monitor-radius-detailed.sh"
echo ""
echo "3. Read the full guide:"
echo "   cat config/radius/CLI_TESTING_GUIDE.md"
echo ""
echo "4. Capture to file for later analysis:"
echo "   sudo tcpdump -i lo -w test.pcap port 1813"
echo ""
echo "============================================"
echo ""
echo "Press Ctrl+C in Terminals 2 and 3 to stop."
echo ""
