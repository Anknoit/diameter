# RADIUS Shared Secret - Complete Setup Guide

## Overview

This setup enables RADIUS packet decryption in Wireshark and CLI tools using a shared secret.

**Shared Secret**: `root@123`

## Quick Start

### 1. Configure Wireshark (One-time setup)

```bash
cd /home/ankit/opt/seagull/diameter
./run/setup-wireshark-radius.sh
```

Then in Wireshark:
- **Edit → Preferences → Protocols → RADIUS**
- **Shared Secret List File**: `/home/ankit/.config/wireshark/radius_secrets`
- Click **OK**

### 2. Test with CLI (radclient)

```bash
# Terminal 1: Start RADIUS server
cd /home/ankit/opt/seagull/diameter
./run/start-radius-acct-server.sh

# Terminal 2: Send test request
./run/test-radclient-acct.sh
```

### 3. Capture and View in Wireshark

```bash
# Terminal 1: Start capture
sudo tcpdump -i lo -w /tmp/radius-test.pcap port 1813

# Terminal 2: Start server
./run/start-radius-acct-server.sh

# Terminal 3: Send requests
./run/test-radclient-acct.sh

# Stop capture (Ctrl+C in Terminal 1)
# Open in Wireshark
wireshark /tmp/radius-test.pcap
```

## What You'll See

### Without Shared Secret
- ❌ "Bad Authenticator" warnings
- ❌ Cannot verify message integrity
- ✅ Most attributes still visible (accounting data is not encrypted)

### With Shared Secret
- ✅ Authenticator validated
- ✅ Message integrity verified
- ✅ User-Password decrypted (if present)
- ✅ All attributes properly decoded

## Command Reference

### Using tshark (Command Line)

```bash
# Live capture with decryption
sudo tshark -i lo -f "port 1813" \
  -o "radius.shared_secret:root@123" \
  -Y "radius" -V

# Decrypt existing capture
tshark -r /tmp/radius-test.pcap \
  -o "radius.shared_secret:root@123" \
  -Y "radius" -V | less
```

### Using radclient

```bash
# Accounting request
echo "Acct-Status-Type=Start,User-Name=testuser,Acct-Session-Id=123" | \
radclient -x 127.0.0.1:1813 acct root@123

# Authentication request (with encrypted password)
echo "User-Name=testuser,User-Password=secret123" | \
radclient -x 127.0.0.1:1812 auth root@123
```

## Files Created

| File | Purpose |
|------|---------|
| `config/radius/SHARED_SECRET_SETUP.md` | Detailed documentation |
| `run/setup-wireshark-radius.sh` | Wireshark configuration script |
| `run/test-radclient-acct.sh` | Test script using radclient |
| `~/.config/wireshark/radius_secrets` | Wireshark secrets file |

## Testing Workflow

### Complete Test Scenario

```bash
# 1. Setup Wireshark (one-time)
./run/setup-wireshark-radius.sh

# 2. Start packet capture
sudo tcpdump -i lo -w radius-complete-test.pcap port 1813 &
TCPDUMP_PID=$!

# 3. Start RADIUS server
./run/start-radius-acct-server.sh &
SERVER_PID=$!
sleep 2

# 4. Send test requests
./run/test-radclient-acct.sh

# 5. Also test with Seagull client
timeout 3 ./run/start-radius-acct-client.sh

# 6. Stop capture
kill $TCPDUMP_PID
kill $SERVER_PID

# 7. View in Wireshark with decryption
wireshark radius-complete-test.pcap
```

## Wireshark Filters

Useful display filters for analyzing RADIUS traffic:

```
# Show only accounting requests
radius.code == 4

# Show only accounting responses  
radius.code == 5

# Show specific user
radius.User_Name == "S4534553635"

# Show Start requests
radius.Acct_Status_Type == 1

# Show Stop requests
radius.Acct_Status_Type == 2

# Show packets with bad authenticator
radius.authenticator_valid == 0
```

## Troubleshooting

### Issue: "Bad Authenticator" in Wireshark

**Cause**: Shared secret mismatch or not configured

**Solution**:
1. Verify secret in Wireshark: Edit → Preferences → Protocols → RADIUS
2. Check it matches: `root@123`
3. Reload the capture file

### Issue: radclient not found

**Solution**:
```bash
sudo apt-get update
sudo apt-get install freeradius-utils
```

### Issue: No packets captured

**Solution**:
```bash
# Check server is running
ps aux | grep seagull

# Check port is listening
sudo netstat -ulnp | grep 1813

# Verify firewall
sudo ufw status
```

## Security Notes

⚠️ **Important**:
- `root@123` is for **testing only**
- Use strong secrets in production (20+ random characters)
- RADIUS encryption is weak - use RadSec (RADIUS over TLS) for production
- Never transmit RADIUS over untrusted networks without VPN/IPsec

## Next Steps

1. ✅ Configure Wireshark with shared secret
2. ✅ Test with radclient
3. ✅ Capture and analyze traffic
4. 📚 Read `SHARED_SECRET_SETUP.md` for detailed information
5. 🔧 Customize for your environment

## Support

For more information, see:
- `config/radius/SHARED_SECRET_SETUP.md` - Detailed guide
- `config/radius/ACCOUNTING_ATTRIBUTES.md` - Attribute reference
- `config/radius/QUICK_REFERENCE.md` - Quick command reference
