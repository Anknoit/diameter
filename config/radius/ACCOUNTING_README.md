# RADIUS Accounting Testing Environment

This directory contains a complete RADIUS accounting testing environment using Seagull, similar to the authentication setup.

## Overview

The accounting test environment simulates RADIUS accounting sessions with Start and Stop requests/responses. This is used for testing accounting functionality in RADIUS servers and clients.

## Components

### Configuration Files
- **conf.acct-client.xml** - Client configuration (connects to port 1813)
- **conf.acct-server.xml** - Server configuration (listens on port 1813)

### Scenario Files
- **scenario/radius/radius-accounting.client.xml** - Client scenario (sends Start/Stop accounting requests)
- **scenario/radius/radius-acct.server.xml** - Server scenario (responds to accounting requests)

### Start Scripts
- **run/start-radius-acct-client.sh** - Starts the accounting client
- **run/start-radius-acct-server.sh** - Starts the accounting server

## Port Configuration

- **Authentication**: Port 1812 (UDP)
- **Accounting**: Port 1813 (UDP)

## Quick Start

### 1. Start the Accounting Server

In one terminal:
```bash
cd /home/ankit/opt/seagull/diameter
./run/start-radius-acct-server.sh
```

The server will:
- Listen on port 1813
- Wait for accounting requests
- Respond with Accounting-Response messages

### 2. Start the Accounting Client

In another terminal:
```bash
cd /home/ankit/opt/seagull/diameter
./run/start-radius-acct-client.sh
```

The client will:
- Send Accounting-Request (Start) messages
- Wait 500ms
- Send Accounting-Request (Stop) messages
- Receive Accounting-Response messages

## Accounting Flow

The client simulates a complete accounting session:

1. **Accounting Start**
   - Client sends Accounting-Request with Acct-Status-Type = 1 (Start)
   - Server responds with Accounting-Response
   
2. **Wait Period**
   - Client waits 500ms to simulate session duration
   
3. **Accounting Stop**
   - Client sends Accounting-Request with Acct-Status-Type = 2 (Stop)
   - Server responds with Accounting-Response

## Key Attributes

### Accounting-Request Attributes
- **Acct-Session-Id**: Unique session identifier
- **Acct-Status-Type**: 1 (Start), 2 (Stop), 3 (Interim-Update)
- **NAS-Identifier**: Network Access Server identifier
- **User-Name**: Username (optional)
- **Acct-Session-Time**: Session duration in seconds (for Stop)
- **Acct-Input-Octets**: Bytes received (for Stop)
- **Acct-Output-Octets**: Bytes sent (for Stop)

### Accounting-Response
- Echoes back Acct-Session-Id and Acct-Status-Type
- Confirms receipt of accounting data

## Logs

Logs are stored in the `logs/` directory:
- `radius-acct-client.log` - Client execution log
- `radius-acct-server.log` - Server execution log
- `radius-acct-client-stat.csv` - Client statistics
- `radius-acct-server-stat.csv` - Server statistics
- `radius-acct-client-protocol-stat.csv` - Client protocol statistics
- `radius-acct-server-protocol-stat.csv` - Server protocol statistics

## Wireshark Capture

To capture RADIUS accounting traffic:

```bash
sudo tcpdump -i lo -w radius-acct.pcap port 1813
```

Then open `radius-acct.pcap` in Wireshark to analyze the accounting messages.

## Customization

### Modify Call Rate
Edit `conf.acct-client.xml` and change:
```xml
<define entity="traffic-param" name="call-rate" value="1"></define>
```

### Change Session Duration
Edit `scenario/radius/radius-accounting.client.xml` and modify:
```xml
<wait-ms value="500"></wait-ms>
```

### Add More Attributes
Edit the scenario files to include additional accounting attributes like:
- Acct-Input-Packets
- Acct-Output-Packets
- Acct-Terminate-Cause
- Framed-IP-Address

## Troubleshooting

### Port Already in Use
If port 1813 is already in use, modify the port in both configuration files:
- Client: `conf.acct-client.xml` - change `dest=127.0.0.1:1813`
- Server: `conf.acct-server.xml` - change `source=0.0.0.0:1813`

### No Response Received
1. Ensure server is running first
2. Check firewall settings
3. Verify port configuration matches in client and server
4. Check logs for error messages

## Testing with Real RADIUS Server

To test against a real RADIUS accounting server, modify `conf.acct-client.xml`:

```xml
open-args="mode=client;dest=<SERVER_IP>:1813;source=0.0.0.0:0"
```

Replace `<SERVER_IP>` with your RADIUS server's IP address.

## Related Files

- **radius-dictionary.xml** - RADIUS protocol dictionary
- **README.md** - General RADIUS testing documentation
- **WIRESHARK_GUIDE.md** - Guide for analyzing RADIUS traffic

## Differences from Authentication

| Feature | Authentication | Accounting |
|---------|---------------|------------|
| Port | 1812 | 1813 |
| Request Type | Access-Request | Accounting-Request |
| Response Type | Access-Accept/Reject | Accounting-Response |
| Flow | Single request/response | Start → Stop (or Interim) |
| Purpose | User authentication | Session tracking/billing |
