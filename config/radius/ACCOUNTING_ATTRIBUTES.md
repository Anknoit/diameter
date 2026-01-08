# RADIUS Accounting Attributes Reference

This document describes the RADIUS accounting attributes configured in the Seagull test environment, matching the production-like template.

## Accounting Request Attributes

The accounting client sends comprehensive RADIUS accounting messages with the following attributes:

### Start Request Attributes

| Attribute | Type | Value | Description |
|-----------|------|-------|-------------|
| **Acct-Session-Id** | String | Auto-generated (counter) | Unique session identifier |
| **Acct-Status-Type** | Integer | 1 | Start (session beginning) |
| **Acct-Terminate-Cause** | Integer | 1 | Admin-Reset |
| **NAS-IP-Address** | Address | 127.0.0.1 | Network Access Server IP |
| **Acct-Delay-Time** | Integer | 0 | Delay in seconds |
| **User-Name** | String | S4534553635 | Subscriber/User identifier |
| **Service-Type** | Integer | 9 | Callback-NAS-Prompt |
| **Framed-Protocol** | Integer | 1 | PPP |
| **Framed-IP-Address** | Address | 172.23.17.104 | Assigned IP address |
| **Framed-IP-Netmask** | Address | 255.255.255.240 | Network mask |
| **NAS-Identifier** | String | bgl-cpf-dell-bgl-01 | NAS identifier |
| **Acct-Multi-Session-Id** | String | Y000000D3BBD4A04C000000D2 | Multi-session ID |
| **Acct-Authentic** | Integer | 1 | RADIUS authentication |
| **Acct-Session-Time** | Integer | 990 | Session duration (seconds) |
| **Event-Timestamp** | Integer | 1682725133 | Unix timestamp |
| **Acct-Input-Octets** | Integer | 6990 | Bytes received |
| **Acct-Output-Octets** | Integer | 7990 | Bytes sent |
| **Calling-Station-Id** | String | lag-10:3051.148 | Calling station identifier |

### Stop Request Attributes

Same as Start, but with updated values:

| Attribute | Value Change | Description |
|-----------|--------------|-------------|
| **Acct-Status-Type** | 2 | Stop (session end) |
| **Acct-Session-Time** | 1490 | Increased session time |
| **Event-Timestamp** | 1682725633 | Updated timestamp (+500s) |
| **Acct-Input-Octets** | 13980 | Doubled from start |
| **Acct-Output-Octets** | 15980 | Doubled from start |

## Attribute Value Mappings

### Acct-Status-Type Values
- `1` = Start
- `2` = Stop
- `3` = Interim-Update
- `7` = Accounting-On
- `8` = Accounting-Off

### Acct-Terminate-Cause Values
- `1` = User Request / Admin Reset
- `2` = Lost Carrier
- `3` = Lost Service
- `4` = Idle Timeout
- `5` = Session Timeout
- `6` = Admin Reboot
- `7` = Port Error
- `8` = NAS Error
- `9` = NAS Request
- `10` = NAS Reboot
- `11` = Port Unneeded
- `12` = Port Preempted
- `13` = Port Suspended
- `14` = Service Unavailable
- `15` = Callback
- `16` = User Error
- `17` = Host Request

### Service-Type Values
- `1` = Login
- `2` = Framed
- `3` = Callback Login
- `4` = Callback Framed
- `5` = Outbound
- `6` = Administrative
- `7` = NAS Prompt
- `8` = Authenticate Only
- `9` = Callback NAS Prompt
- `10` = Call Check
- `11` = Callback Administrative

### Framed-Protocol Values
- `1` = PPP
- `2` = SLIP
- `3` = AppleTalk Remote Access Protocol (ARAP)
- `4` = Gandalf proprietary SingleLink/MultiLink protocol
- `5` = Xylogics proprietary IPX/SLIP
- `6` = X.75 Synchronous

### Acct-Authentic Values
- `1` = RADIUS
- `2` = Local
- `3` = Remote

## IP Address Conversion

RADIUS uses 32-bit integers for IP addresses (network byte order):

| IP Address | Integer Value | Calculation |
|------------|---------------|-------------|
| 127.0.0.1 | 2130706433 | (127<<24) + (0<<16) + (0<<8) + 1 |
| 172.23.17.104 | 2887057256 | (172<<24) + (23<<16) + (17<<8) + 104 |
| 255.255.255.240 | 4294967040 | (255<<24) + (255<<16) + (255<<8) + 240 |

## Comparison with radclient Example

The Seagull configuration matches this radclient command:

```bash
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
Acct-Session-Id=chet998890jhbjh90,\
Acct-Multi-Session-Id=Y000000D3BBD4A04C000000D2,\
Acct-Authentic=RADIUS,\
Acct-Session-Time=990,\
Event-Timestamp=1682725133,\
Acct-Input-Octets=6990,\
Acct-Output-Octets=7990,\
Calling-Station-Id=lag-10:3051.148" | \
radclient -s 127.0.0.1:1813 acct root@123
```

## Scenario File Location

The accounting scenario is defined in:
- **Client**: `/home/ankit/opt/seagull/diameter/scenario/radius/radius-accounting.client.xml`
- **Server**: `/home/ankit/opt/seagull/diameter/scenario/radius/radius-acct.server.xml`

## Testing

To test the accounting flow:

```bash
# Terminal 1 - Start server
cd /home/ankit/opt/seagull/diameter
./run/start-radius-acct-server.sh

# Terminal 2 - Start client
cd /home/ankit/opt/seagull/diameter
./run/start-radius-acct-client.sh
```

The client will send:
1. Accounting-Request (Start) with initial counters
2. Wait 500ms
3. Accounting-Request (Stop) with updated counters

## Wireshark Analysis

To capture and analyze the accounting messages:

```bash
sudo tcpdump -i lo -w radius-acct.pcap port 1813
```

Then open in Wireshark to see all the attributes in detail.
