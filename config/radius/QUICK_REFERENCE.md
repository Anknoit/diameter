# RADIUS Testing Environments - Quick Reference

This guide provides a quick reference for both RADIUS authentication and accounting testing environments.

## File Structure

```
/home/ankit/opt/seagull/diameter/
├── config/radius/
│   ├── conf.auth-client.xml          # Authentication client config
│   ├── conf.auth-server.xml          # Authentication server config
│   ├── conf.acct-client.xml          # Accounting client config
│   ├── conf.acct-server.xml          # Accounting server config
│   ├── radius-dictionary.xml         # Shared RADIUS dictionary
│   ├── README.md                     # General RADIUS documentation
│   ├── ACCOUNTING_README.md          # Accounting-specific guide
│   └── WIRESHARK_GUIDE.md           # Wireshark analysis guide
├── scenario/radius/
│   ├── radius-auth.client.xml        # Authentication client scenario
│   ├── radius-auth.server.xml        # Authentication server scenario
│   ├── radius-accounting.client.xml  # Accounting client scenario
│   └── radius-acct.server.xml        # Accounting server scenario
└── run/
    ├── start-radius-auth-client.sh   # Start auth client
    ├── start-radius-auth-server.sh   # Start auth server
    ├── start-radius-acct-client.sh   # Start acct client
    └── start-radius-acct-server.sh   # Start acct server
```

## Quick Start Commands

### Authentication Testing

**Terminal 1 - Start Auth Server:**
```bash
cd /home/ankit/opt/seagull/diameter
./run/start-radius-auth-server.sh
```

**Terminal 2 - Start Auth Client:**
```bash
cd /home/ankit/opt/seagull/diameter
./run/start-radius-auth-client.sh
```

### Accounting Testing

**Terminal 1 - Start Acct Server:**
```bash
cd /home/ankit/opt/seagull/diameter
./run/start-radius-acct-server.sh
```

**Terminal 2 - Start Acct Client:**
```bash
cd /home/ankit/opt/seagull/diameter
./run/start-radius-acct-client.sh
```

### Full AAA Testing (Both)

**Terminal 1 - Auth Server:**
```bash
./run/start-radius-auth-server.sh
```

**Terminal 2 - Acct Server:**
```bash
./run/start-radius-acct-server.sh
```

**Terminal 3 - Auth Client:**
```bash
./run/start-radius-auth-client.sh
```

**Terminal 4 - Acct Client:**
```bash
./run/start-radius-acct-client.sh
```

## Port Configuration

| Service | Port | Protocol |
|---------|------|----------|
| Authentication | 1812 | UDP |
| Accounting | 1813 | UDP |

## Message Types

### Authentication
- **Request**: Access-Request (Code 1)
- **Success**: Access-Accept (Code 2)
- **Failure**: Access-Reject (Code 3)
- **Challenge**: Access-Challenge (Code 11)

### Accounting
- **Request**: Accounting-Request (Code 4)
- **Response**: Accounting-Response (Code 5)

## Status Types (Accounting)

| Value | Type | Description |
|-------|------|-------------|
| 1 | Start | Session started |
| 2 | Stop | Session ended |
| 3 | Interim-Update | Periodic update during session |
| 7 | Accounting-On | NAS is now ready |
| 8 | Accounting-Off | NAS is shutting down |

## Common Attributes

### Authentication Attributes
- User-Name (1)
- User-Password (2)
- NAS-IP-Address (4)
- NAS-Port (5)
- Service-Type (6)
- Framed-IP-Address (8)
- Called-Station-Id (30)
- Calling-Station-Id (31)
- NAS-Identifier (32)

### Accounting Attributes
- Acct-Status-Type (40)
- Acct-Session-Id (44)
- Acct-Session-Time (46)
- Acct-Input-Octets (42)
- Acct-Output-Octets (43)
- Acct-Terminate-Cause (49)
- Acct-Input-Packets (47)
- Acct-Output-Packets (48)

## Wireshark Capture

### Capture Authentication Traffic
```bash
sudo tcpdump -i lo -w radius-auth.pcap port 1812
```

### Capture Accounting Traffic
```bash
sudo tcpdump -i lo -w radius-acct.pcap port 1813
```

### Capture Both
```bash
sudo tcpdump -i lo -w radius-all.pcap 'port 1812 or port 1813'
```

## Log Files

### Authentication Logs
- `logs/radius-auth-client.log`
- `logs/radius-auth-server.log`
- `logs/radius-auth-client-stat.csv`
- `logs/radius-auth-server-stat.csv`

### Accounting Logs
- `logs/radius-acct-client.log`
- `logs/radius-acct-server.log`
- `logs/radius-acct-client-stat.csv`
- `logs/radius-acct-server-stat.csv`

## Typical AAA Flow

```
Client                    Auth Server              Acct Server
  |                            |                         |
  |--Access-Request---------->|                         |
  |<--Access-Accept-----------|                         |
  |                            |                         |
  |--Accounting-Request (Start)----------------------->|
  |<--Accounting-Response---------------------------|
  |                            |                         |
  |    [Session Active]        |                         |
  |                            |                         |
  |--Accounting-Request (Stop)------------------------->|
  |<--Accounting-Response---------------------------|
  |                            |                         |
```

## Customization Tips

### Change Call Rate
Edit the client configuration file:
```xml
<define entity="traffic-param" name="call-rate" value="10"></define>
```

### Modify Session Duration (Accounting)
Edit `scenario/radius/radius-accounting.client.xml`:
```xml
<wait-ms value="5000"></wait-ms>  <!-- 5 seconds -->
```

### Change Destination Server
Edit client configuration:
```xml
open-args="mode=client;dest=192.168.1.100:1812;source=0.0.0.0:0"
```

## Troubleshooting

### Check if Ports are Available
```bash
sudo netstat -ulnp | grep -E '1812|1813'
```

### View Real-time Logs
```bash
tail -f logs/radius-auth-server.log
tail -f logs/radius-acct-server.log
```

### Test Connectivity
```bash
# Test if server is listening
nc -zvu 127.0.0.1 1812  # Auth
nc -zvu 127.0.0.1 1813  # Acct
```

## Common Issues

| Issue | Solution |
|-------|----------|
| Port already in use | Change port in config files or stop conflicting service |
| No response | Ensure server started first, check firewall |
| Permission denied | Run `chmod +x` on start scripts |
| Library not found | Check LD_LIBRARY_PATH in start scripts |

## References

- RFC 2865 - Remote Authentication Dial In User Service (RADIUS)
- RFC 2866 - RADIUS Accounting
- RFC 2869 - RADIUS Extensions
- [Seagull Documentation](http://gull.sourceforge.net/doc/guide.html)
