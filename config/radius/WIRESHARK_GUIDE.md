# Testing RADIUS Messages with Wireshark

## Quick Start

### 1. Start Wireshark Capture

```bash
# Option 1: Capture on loopback interface (since we're using 127.0.0.1)
sudo wireshark -i lo -k -f "udp port 1812"

# Option 2: Using tcpdump first, then open in Wireshark
sudo tcpdump -i lo -w /tmp/radius-capture.pcap udp port 1812
```

### 2. Start Your RADIUS Test

**Terminal 1 - Start Server:**
```bash
cd /home/ankit/opt/seagull/diameter
./run/start-radius-auth-server.sh
```

**Terminal 2 - Start Client:**
```bash
cd /home/ankit/opt/seagull/diameter
./run/start-radius-auth-client.sh
```

### 3. View Captured Traffic

If you used tcpdump, open the capture file:
```bash
wireshark /tmp/radius-capture.pcap
```

## Wireshark Display Filters

Use these filters to focus on specific RADIUS traffic:

### Basic Filters
```
# All RADIUS traffic
radius

# Only Access-Request messages
radius.code == 1

# Only Access-Accept messages
radius.code == 2

# Only Access-Reject messages
radius.code == 3

# Filter by specific user
radius.User_Name contains "user1001"

# Filter by NAS identifier
radius.NAS_Identifier == "seagull-test-nas"
```

### Advanced Filters
```
# Show only authentication (not accounting)
udp.port == 1812

# Show only accounting
udp.port == 1813

# Show request/response pairs
radius.id == 1

# Show messages with specific attributes
radius.Framed_IP_Address
```

## What to Look For

### Access-Request Packet
You should see:
- **Code**: 1 (Access-Request)
- **Identifier**: Incrementing number (1, 2, 3...)
- **Length**: Total packet length
- **Authenticator**: 16-byte random value
- **Attributes**:
  - User-Name (1): user1001@example.com, user1002@example.com, etc.
  - User-Password (2): password123 (encrypted in real RADIUS)
  - NAS-IP-Address (4): 127.0.0.1
  - NAS-Port (5): 0
  - Service-Type (6): 2 (Framed)
  - NAS-Identifier (32): seagull-test-nas
  - Called-Station-Id (30): 00-11-22-33-44-55
  - Calling-Station-Id (31): AA-BB-CC-DD-EE-FF

### Access-Accept Packet
You should see:
- **Code**: 2 (Access-Accept)
- **Identifier**: Same as request
- **Length**: Total packet length
- **Authenticator**: MD5 hash (response authenticator)
- **Attributes**:
  - Service-Type (6): 2 (Framed)
  - Framed-IP-Address (8): 10.0.0.1
  - Framed-IP-Netmask (9): 255.255.255.0
  - Framed-MTU (12): 1500
  - Session-Timeout (27): 3600
  - Idle-Timeout (28): 600
  - Reply-Message (18): "Welcome! Authentication successful."

## Analyzing the Packet Flow

### Expected Sequence
```
Client (127.0.0.1:random) → Server (127.0.0.1:1812)
    Access-Request (Code=1, ID=1)
    
Server (127.0.0.1:1812) → Client (127.0.0.1:random)
    Access-Accept (Code=2, ID=1)

Client (127.0.0.1:random) → Server (127.0.0.1:1812)
    Access-Request (Code=1, ID=2)
    
Server (127.0.0.1:1812) → Client (127.0.0.1:random)
    Access-Accept (Code=2, ID=2)
```

### Timing Analysis
- Right-click on a packet → "Follow" → "UDP Stream" to see the conversation
- Statistics → "Flow Graph" to visualize the message flow
- Statistics → "I/O Graph" to see traffic patterns over time

## Troubleshooting

### No Packets Captured?

1. **Check if traffic is on loopback:**
   ```bash
   sudo tcpdump -i lo -n udp port 1812
   ```

2. **Verify server is listening:**
   ```bash
   sudo netstat -ulnp | grep 1812
   # or
   sudo ss -ulnp | grep 1812
   ```

3. **Check firewall:**
   ```bash
   sudo iptables -L -n | grep 1812
   ```

### Wireshark Not Decoding as RADIUS?

1. Right-click packet → "Decode As..."
2. Select "UDP port 1812"
3. Choose "RADIUS" from the list

### Permission Issues?

```bash
# Add your user to wireshark group
sudo usermod -a -G wireshark $USER

# Or run with sudo
sudo wireshark
```

## Export Options

### Save Specific Packets
1. Apply filter (e.g., `radius`)
2. File → Export Specified Packets
3. Choose format (pcap, pcapng, etc.)

### Export as Text
```bash
# Export to text file
tshark -r /tmp/radius-capture.pcap -V > radius-packets.txt

# Export specific fields
tshark -r /tmp/radius-capture.pcap -T fields \
  -e frame.number \
  -e radius.code \
  -e radius.id \
  -e radius.User_Name
```

## Statistics and Analysis

### RADIUS Statistics in Wireshark
1. Statistics → Protocol Hierarchy
2. Statistics → Conversations (UDP tab)
3. Statistics → Endpoints (UDP tab)

### Command-Line Analysis
```bash
# Count packets by type
tshark -r /tmp/radius-capture.pcap -q -z radius,tree

# Show timing between request/response
tshark -r /tmp/radius-capture.pcap -T fields \
  -e frame.time_relative \
  -e radius.code \
  -e radius.id

# Extract all usernames
tshark -r /tmp/radius-capture.pcap -T fields \
  -e radius.User_Name | sort -u
```

## Real-Time Monitoring

```bash
# Monitor in terminal with tshark
sudo tshark -i lo -f "udp port 1812" -V

# Compact view
sudo tshark -i lo -f "udp port 1812" \
  -T fields \
  -e frame.time \
  -e ip.src \
  -e ip.dst \
  -e radius.code \
  -e radius.id \
  -e radius.User_Name
```

## Tips

1. **Color Rules**: Wireshark automatically colors RADIUS packets
   - Green: Access-Accept
   - Red: Access-Reject
   - Light blue: Access-Request

2. **Packet Details**: Expand the "Remote Authentication Dial-In User Service" section to see all attributes

3. **Compare Packets**: Select two packets, right-click → "Compare" to see differences

4. **Time Display**: View → Time Display Format → Seconds Since Previous Displayed Packet (useful for latency analysis)

5. **Follow Conversation**: Right-click → Follow → UDP Stream to see all packets in that session
