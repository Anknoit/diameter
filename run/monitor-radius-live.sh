#!/bin/bash

# Live RADIUS Traffic Monitor with Decryption
# This script captures and displays RADIUS traffic in real-time with decryption

SHARED_SECRET="root@123"
PORT="1813"

echo "============================================"
echo "RADIUS Live Traffic Monitor (CLI)"
echo "============================================"
echo "Port: $PORT"
echo "Shared Secret: $SHARED_SECRET"
echo "============================================"
echo ""

# Check if tshark is installed
if ! command -v tshark &> /dev/null; then
    echo "❌ tshark not found!"
    echo ""
    echo "Install it with:"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install tshark"
    echo ""
    exit 1
fi

echo "✅ tshark found"
echo ""
echo "📡 Starting live capture on port $PORT..."
echo "   Press Ctrl+C to stop"
echo ""
echo "============================================"
echo ""

# Run tshark with RADIUS decryption
sudo tshark -i lo -f "port $PORT" \
  -o "radius.shared_secret:$SHARED_SECRET" \
  -Y "radius" \
  -T fields \
  -e frame.number \
  -e frame.time \
  -e ip.src \
  -e ip.dst \
  -e radius.code \
  -e radius.id \
  -e radius.User_Name \
  -e radius.Acct_Session_Id \
  -e radius.Acct_Status_Type \
  -e radius.Acct_Session_Time \
  -e radius.Acct_Input_Octets \
  -e radius.Acct_Output_Octets \
  -e radius.NAS_Identifier \
  -E header=y \
  -E separator="|" \
  -E quote=d

echo ""
echo "============================================"
echo "Capture stopped"
echo "============================================"
