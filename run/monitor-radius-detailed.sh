#!/bin/bash

# Detailed RADIUS Packet Viewer (CLI)
# Shows full packet details with decryption

SHARED_SECRET="root@123"
PORT="1813"

echo "============================================"
echo "RADIUS Detailed Packet Viewer (CLI)"
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
echo "📡 Starting detailed capture on port $PORT..."
echo "   Press Ctrl+C to stop"
echo ""
echo "============================================"
echo ""

# Run tshark with verbose output showing all RADIUS attributes
sudo tshark -i lo -f "port $PORT" \
  -o "radius.shared_secret:$SHARED_SECRET" \
  -Y "radius" \
  -V

echo ""
echo "============================================"
echo "Capture stopped"
echo "============================================"
