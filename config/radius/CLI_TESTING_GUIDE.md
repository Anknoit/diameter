# RADIUS CLI Testing Guide

This guide shows how to test and monitor RADIUS traffic directly in the CLI without Wireshark GUI.

## Quick Start - 3 Terminal Setup

### Terminal 1: Monitor Traffic (Live View)

```bash
cd /home/ankit/opt/seagull/diameter
./run/monitor-radius-live.sh
```

This shows a **table view** of RADIUS packets as they arrive.

### Terminal 2: Start RADIUS Server

```bash
cd /home/ankit/opt/seagull/diameter
./run/start-radius-acct-server.sh
```

### Terminal 3: Start RADIUS Client

```bash
cd /home/ankit/opt/seagull/diameter
./run/start-radius-acct-client.sh
```

OR send test with radclient:

```bash
./run/test-radclient-acct.sh
```

## Monitoring Options

### Option 1: Table View (Summary)

**Script**: `./run/monitor-radius-live.sh`

Shows packets in a table format:
```
frame.number|frame.time|ip.src|ip.dst|radius.code|User-Name|Acct-Session-Id|...
1|2026-01-08 16:00:00|127.0.0.1|127.0.0.1|4|S4534553635|test-123|...
2|2026-01-08 16:00:00|127.0.0.1|127.0.0.1|5|||||...
```

**Pros**: 
- ✅ Easy to read
- ✅ See multiple packets at once
- ✅ Good for monitoring traffic flow

### Option 2: Detailed View (Full Packets)

**Script**: `./run/monitor-radius-detailed.sh`

Shows complete packet details:
```
Frame 1: 256 bytes on wire
Internet Protocol Version 4, Src: 127.0.0.1, Dst: 127.0.0.1
User Datagram Protocol, Src Port: 54321, Dst Port: 1813
RADIUS Protocol
    Code: Accounting-Request (4)
    Packet identifier: 0x01
    Length: 228
    Authenticator: 0123456789abcdef...
    [Authenticator Valid: True]
    Attribute Value Pairs
        User-Name: S4534553635
        Acct-Session-Id: test-123
        Acct-Status-Type: Start (1)
        Acct-Session-Time: 990
        ...
```

**Pros**:
- ✅ See all attributes
- ✅ Authenticator validation status
- ✅ Full packet details

### Option 3: Custom tshark Commands

#### Basic Live Capture

```bash
sudo tshark -i lo -f "port 1813" \
  -o "radius.shared_secret:testing123" \
  -Y "radius"
```

#### Show Only Specific Fields

```bash
sudo tshark -i lo -f "port 1813" \
  -o "radius.shared_secret:testing123" \
  -Y "radius" \
  -T fields \
  -e radius.code \
  -e radius.User_Name \
  -e radius.Acct_Session_Id \
  -e radius.Acct_Status_Type
```

#### Count Packets by Type

```bash
sudo tshark -i lo -f "port 1813" \
  -o "radius.shared_secret:testing123" \
  -Y "radius" \
  -T fields \
  -e radius.code | sort | uniq -c
```

#### Filter by Message Type

```bash
# Only Accounting-Request (code 4)
sudo tshark -i lo -f "port 1813" \
  -o "radius.shared_secret:testing123" \
  -Y "radius.code == 4" \
  -V

# Only Accounting-Response (code 5)
sudo tshark -i lo -f "port 1813" \
  -o "radius.shared_secret:testing123" \
  -Y "radius.code == 5" \
  -V
```

## Analyzing Saved Captures

### Save Capture to File

```bash
# Terminal 1: Capture to file
sudo tcpdump -i lo -w /tmp/radius-test.pcap port 1813

# Terminal 2: Run server
./run/start-radius-acct-server.sh

# Terminal 3: Run client
./run/start-radius-acct-client.sh

# Stop capture (Ctrl+C in Terminal 1)
```

### Analyze the Capture

```bash
# Summary view
tshark -r /tmp/radius-test.pcap \
  -o "radius.shared_secret:testing123" \
  -Y "radius"

# Detailed view
tshark -r /tmp/radius-test.pcap \
  -o "radius.shared_secret:testing123" \
  -Y "radius" \
  -V

# Extract specific fields
tshark -r /tmp/radius-test.pcap \
  -o "radius.shared_secret:testing123" \
  -Y "radius" \
  -T fields \
  -e frame.number \
  -e radius.code \
  -e radius.User_Name \
  -e radius.Acct_Session_Id \
  -E header=y
```

### Statistics from Capture

```bash
# Packet count by type
tshark -r /tmp/radius-test.pcap \
  -o "radius.shared_secret:testing123" \
  -Y "radius" \
  -T fields \
  -e radius.code | sort | uniq -c

# Session summary
tshark -r /tmp/radius-test.pcap \
  -o "radius.shared_secret:testing123" \
  -Y "radius" \
  -T fields \
  -e radius.Acct_Session_Id \
  -e radius.Acct_Status_Type \
  -e radius.Acct_Session_Time | column -t
```

## Complete Testing Workflow

### Full Test with CLI Monitoring

```bash
# Terminal 1: Start monitoring
cd /home/ankit/opt/seagull/diameter
./run/monitor-radius-live.sh

# Terminal 2: Start server
cd /home/ankit/opt/seagull/diameter
./run/start-radius-acct-server.sh

# Terminal 3: Send test requests
cd /home/ankit/opt/seagull/diameter

# Option A: Use Seagull client
timeout 5 ./run/start-radius-acct-client.sh

# Option B: Use radclient
./run/test-radclient-acct.sh

# Option C: Manual radclient
echo "Acct-Status-Type=Start,User-Name=testuser,Acct-Session-Id=abc123" | \
radclient -x 127.0.0.1:1813 acct testing123
```

### What You'll See in Terminal 1

```
frame.number|frame.time|ip.src|ip.dst|radius.code|radius.id|radius.User_Name|radius.Acct_Session_Id|radius.Acct_Status_Type|...
1|16:00:01|127.0.0.1|127.0.0.1|4|1|S4534553635|31|1|990|6990|7990|bgl-cpf-dell-bgl-01
2|16:00:01|127.0.0.1|127.0.0.1|5|1|||1||||
3|16:00:02|127.0.0.1|127.0.0.1|4|2|S4534553635|32|2|1490|13980|15980|bgl-cpf-dell-bgl-01
4|16:00:02|127.0.0.1|127.0.0.1|5|2|||2||||
```

**Interpretation**:
- Packet 1: Accounting-Request (Start) from client
- Packet 2: Accounting-Response from server
- Packet 3: Accounting-Request (Stop) from client
- Packet 4: Accounting-Response from server

## Useful Filters

### Display Filters (for analysis)

```bash
# Show only requests
-Y "radius.code == 4"

# Show only responses
-Y "radius.code == 5"

# Show specific user
-Y "radius.User_Name == \"S4534553635\""

# Show Start requests
-Y "radius.Acct_Status_Type == 1"

# Show Stop requests
-Y "radius.Acct_Status_Type == 2"

# Show packets with bad authenticator
-Y "radius.authenticator_valid == 0"

# Show high traffic sessions (>1000 seconds)
-Y "radius.Acct_Session_Time > 1000"
```

### Capture Filters (for tcpdump/tshark)

```bash
# RADIUS accounting only
-f "port 1813"

# RADIUS authentication only
-f "port 1812"

# Both ports
-f "port 1812 or port 1813"

# Specific host
-f "host 127.0.0.1 and port 1813"
```

## Verification Checklist

When monitoring, verify:

- ✅ **Authenticator Valid**: Should be "True" with correct shared secret
- ✅ **Request/Response Pairs**: Each request should have a matching response
- ✅ **Identifier Matching**: Response ID should match request ID
- ✅ **Session Continuity**: Same Acct-Session-Id for Start and Stop
- ✅ **Increasing Counters**: Stop should have higher values than Start

## Troubleshooting

### No Packets Captured

```bash
# Check if server is running
ps aux | grep seagull

# Check if port is listening
sudo netstat -ulnp | grep 1813

# Test with ping
ping 127.0.0.1

# Check interface
ip addr show lo
```

### Bad Authenticator

```bash
# Verify shared secret
grep "shared_secret" ~/.config/wireshark/radius_secrets

# Should show:
# 127.0.0.1,1813,testing123

# Test with correct secret
tshark -r test.pcap -o "radius.shared_secret:testing123" -Y "radius" -V
```

### Permission Denied

```bash
# Add user to wireshark group (one-time)
sudo usermod -a -G wireshark $USER

# Or run with sudo
sudo tshark -i lo -f "port 1813"
```

## Scripts Reference

| Script | Purpose | Output |
|--------|---------|--------|
| `monitor-radius-live.sh` | Live table view | Summary table |
| `monitor-radius-detailed.sh` | Live detailed view | Full packets |
| `test-radclient-acct.sh` | Send test requests | radclient output |
| `setup-wireshark-radius.sh` | Configure secrets | Setup confirmation |

## Quick Commands Cheat Sheet

```bash
# Live monitoring (table)
./run/monitor-radius-live.sh

# Live monitoring (detailed)
./run/monitor-radius-detailed.sh

# Capture to file
sudo tcpdump -i lo -w test.pcap port 1813

# Analyze file (summary)
tshark -r test.pcap -o "radius.shared_secret:testing123" -Y "radius"

# Analyze file (detailed)
tshark -r test.pcap -o "radius.shared_secret:testing123" -Y "radius" -V

# Send test
./run/test-radclient-acct.sh

# Manual test
echo "Acct-Status-Type=Start,User-Name=test" | radclient 127.0.0.1:1813 acct testing123
```

## Next Steps

1. ✅ Start monitoring in Terminal 1
2. ✅ Start server in Terminal 2
3. ✅ Send requests in Terminal 3
4. 📊 Analyze the output
5. 💾 Save captures for later analysis
6. 🔍 Use filters to focus on specific traffic

All tools are ready for CLI-based RADIUS testing and monitoring!
