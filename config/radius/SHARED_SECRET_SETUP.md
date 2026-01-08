# RADIUS Shared Secret Configuration

This guide shows how to use a shared secret with RADIUS for encryption and how to decrypt the data in Wireshark and CLI tools.

## Shared Secret

**Secret Key**: `testing123`

This shared secret is used to:
1. Encrypt the `User-Password` attribute
2. Calculate the Response Authenticator
3. Verify message integrity

## Testing with radclient (CLI)

### Install radclient (if not installed)

```bash
sudo apt-get update
sudo apt-get install freeradius-utils
```

### Test Accounting with radclient

```bash
# Send Accounting-Request (Start) to the Seagull server
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
Acct-Session-Id=test-session-12345,\
Acct-Multi-Session-Id=Y000000D3BBD4A04C000000D2,\
Acct-Authentic=RADIUS,\
Acct-Session-Time=990,\
Acct-Input-Octets=6990,\
Acct-Output-Octets=7990,\
Calling-Station-Id=lag-10:3051.148" | \
radclient -x 127.0.0.1:1813 acct testing123
```

### Test Authentication with radclient

```bash
# Send Access-Request with encrypted password
echo "User-Name=testuser,\
User-Password=mypassword123,\
NAS-IP-Address=127.0.0.1,\
NAS-Port=0,\
Service-Type=Framed,\
NAS-Identifier=test-nas" | \
radclient -x 127.0.0.1:1812 auth testing123
```

The `-x` flag shows debug output including the encrypted password.

## Wireshark Configuration for Decryption

### Method 1: Configure in Wireshark GUI

1. Open Wireshark
2. Go to **Edit → Preferences**
3. Expand **Protocols** → **RADIUS**
4. In the **Shared Secret** field, enter: `testing123`
5. Click **OK**

### Method 2: Create Shared Secrets File

Create a file with multiple secrets for different servers:

```bash
# Create the file
mkdir -p ~/.config/wireshark
cat > ~/.config/wireshark/radius_secrets << 'EOF'
# Format: <IP address>,<UDP port>,<shared secret>
127.0.0.1,1812,testing123
127.0.0.1,1813,testing123
0.0.0.0,1812,testing123
0.0.0.0,1813,testing123
EOF
```

Then in Wireshark:
1. **Edit → Preferences → Protocols → RADIUS**
2. **Shared Secret List File**: Browse to `~/.config/wireshark/radius_secrets`
3. Click **OK**

### Method 3: Command Line (tshark)

Decrypt RADIUS packets using tshark:

```bash
# Capture and decrypt RADIUS traffic
sudo tshark -i lo -f "port 1813" \
  -o "radius.shared_secret:testing123" \
  -Y "radius" -V

# Or from a capture file
tshark -r radius-acct.pcap \
  -o "radius.shared_secret:testing123" \
  -Y "radius" -V
```

## What Gets Encrypted

### Encrypted Attributes
- **User-Password** (Type 2) - XOR encrypted with MD5(secret + authenticator)
- **Tunnel-Password** (Type 69) - Encrypted
- **MS-MPPE-Send-Key** / **MS-MPPE-Recv-Key** - Encrypted

### Not Encrypted (Plain Text)
- User-Name
- NAS-IP-Address
- Acct-Session-Id
- All accounting counters (octets, packets, session time)
- Most other attributes

## Viewing Decrypted Data

### In Wireshark

Once configured with the shared secret:

1. **Encrypted view** (without secret):
   ```
   User-Password: [16 bytes encrypted data]
   ```

2. **Decrypted view** (with secret):
   ```
   User-Password: mypassword123
   ```

### In radclient Debug Output

With `-x` flag, radclient shows:

```
Sending Access-Request Id 123 to 127.0.0.1:1812
        User-Name = "testuser"
        User-Password = "mypassword123"    # Plain text in debug
        NAS-IP-Address = 127.0.0.1
        ...
```

But on the wire, the password is encrypted.

## Testing the Setup

### 1. Start Wireshark Capture

```bash
# In one terminal
sudo wireshark -i lo -k -f "port 1813"
```

Configure the shared secret in Wireshark (see above).

### 2. Start RADIUS Server

```bash
# In another terminal
cd /home/ankit/opt/seagull/diameter
./run/start-radius-acct-server.sh
```

### 3. Send Test Request with radclient

```bash
# In another terminal
echo "Acct-Status-Type=Start,\
User-Name=testuser,\
Acct-Session-Id=test-123,\
NAS-Identifier=test-nas" | \
radclient -x 127.0.0.1:1813 acct testing123
```

### 4. View in Wireshark

You should see:
- **Accounting-Request** packet
- All attributes in plain text (accounting data is not encrypted)
- **Accounting-Response** packet
- Authenticator field properly validated with the shared secret

## Understanding RADIUS Encryption

### User-Password Encryption Algorithm

```
1. Concatenate: secret + request_authenticator
2. Calculate: MD5(secret + request_authenticator) = b1
3. XOR: password[0:16] XOR b1 = encrypted_chunk1
4. For longer passwords, repeat with previous encrypted chunk
```

### Authenticator Validation

**Request Authenticator**: Random 16 bytes

**Response Authenticator**: 
```
MD5(Code + ID + Length + Request_Authenticator + Attributes + Secret)
```

Wireshark validates this automatically when you provide the shared secret.

## Troubleshooting

### "Bad Authenticator" in Wireshark

If you see this warning:
- ✗ Wrong shared secret configured
- ✓ Check the secret matches exactly (case-sensitive)
- ✓ Verify the server is using the same secret

### Password Still Encrypted

If User-Password shows as encrypted:
- ✗ Shared secret not configured in Wireshark
- ✓ Add secret in Preferences → Protocols → RADIUS
- ✓ Restart capture or reload the file

### radclient Connection Refused

If radclient can't connect:
- ✗ Server not running
- ✓ Start the RADIUS server first
- ✓ Check firewall rules: `sudo ufw allow 1813/udp`

## Security Notes

⚠️ **Important**: 
- The shared secret should be **strong** in production (not `testing123`)
- RADIUS encryption is **weak** by modern standards
- Use RADIUS over TLS (RadSec) for better security
- Never send RADIUS over untrusted networks without a VPN

## Example: Complete Test Flow

```bash
# Terminal 1: Start Wireshark
sudo tshark -i lo -f "port 1813" -o "radius.shared_secret:testing123" -V

# Terminal 2: Start Server
cd /home/ankit/opt/seagull/diameter
./run/start-radius-acct-server.sh

# Terminal 3: Send Request
echo "Acct-Status-Type=Start,User-Name=testuser,Acct-Session-Id=abc123" | \
radclient -x 127.0.0.1:1813 acct testing123

# You'll see the full decrypted packet in tshark output!
```

## References

- RFC 2865 - RADIUS (Section 5.2: User-Password Encryption)
- RFC 2866 - RADIUS Accounting
- RFC 2548 - Microsoft Vendor-specific RADIUS Attributes
- Wireshark RADIUS Dissector Documentation
