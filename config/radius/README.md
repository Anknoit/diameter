# RADIUS Configuration for Seagull Testing

This directory contains a complete RADIUS configuration for testing with Seagull, including authentication and accounting scenarios.

## Overview

The configuration includes:
- **Protocol Dictionary**: Complete RADIUS protocol definition (RFC 2865, RFC 2866)
- **Authentication**: Client/server configurations and scenarios for RADIUS authentication
- **Accounting**: Client/server configurations and scenarios for RADIUS accounting (existing)

## Files Structure

### Configuration Files (`config/radius/`)
- `radius-dictionary.xml` - Complete RADIUS protocol dictionary with all standard attributes
- `conf.auth-client.xml` - RADIUS authentication client configuration (UDP port 1812)
- `conf.auth-server.xml` - RADIUS authentication server configuration (UDP port 1812)
- `conf.client.xml` - RADIUS accounting client configuration (TCP port 1813)
- `conf.server.xml` - RADIUS accounting server configuration (TCP port 1813)

### Scenario Files (`scenario/radius/`)
- `radius-auth.client.xml` - Authentication client scenario (Access-Request/Accept)
- `radius-auth.server.xml` - Authentication server scenario (Access-Request/Accept)
- `radius-accounting.client.xml` - Accounting client scenario (Accounting-Request/Response)

### Run Scripts (`run/`)
- `start-radius-auth-server.sh` - Start authentication server
- `start-radius-auth-client.sh` - Start authentication client

## Quick Start

### Testing RADIUS Authentication

1. **Start the Server** (in terminal 1):
   ```bash
   cd /home/ankit/opt/seagull/diameter
   ./run/start-radius-auth-server.sh
   ```

2. **Start the Client** (in terminal 2):
   ```bash
   cd /home/ankit/opt/seagull/diameter
   ./run/start-radius-auth-client.sh
   ```

### Testing RADIUS Accounting

1. **Start the Server** (in terminal 1):
   ```bash
   cd /home/ankit/opt/seagull/diameter
   seagull -conf config/radius/conf.server.xml \
           -dico config/radius/radius-accounting.xml \
           -scen scenario/radius-accounting.server.xml \
           -log logs/radius-acct-server.log \
           -llevel ET
   ```

2. **Start the Client** (in terminal 2):
   ```bash
   cd /home/ankit/opt/seagull/diameter
   seagull -conf config/radius/conf.client.xml \
           -dico config/radius/radius-accounting.xml \
           -scen scenario/radius/radius-accounting.client.xml \
           -log logs/radius-acct-client.log \
           -llevel ET
   ```

## RADIUS Protocol Details

### Message Types Supported
- **Access-Request** (Code 1) - Authentication request
- **Access-Accept** (Code 2) - Authentication success
- **Access-Reject** (Code 3) - Authentication failure
- **Accounting-Request** (Code 4) - Accounting data
- **Accounting-Response** (Code 5) - Accounting acknowledgment
- **Access-Challenge** (Code 11) - Multi-step authentication
- **Status-Server** (Code 12) - Server status check
- **Status-Client** (Code 13) - Client status response

### Key Attributes Included

#### Authentication Attributes
- User-Name (1)
- User-Password (2)
- CHAP-Password (3)
- NAS-IP-Address (4)
- NAS-Port (5)
- Service-Type (6)
- Framed-IP-Address (8)
- Reply-Message (18)
- State (24)
- Session-Timeout (27)
- Idle-Timeout (28)
- Called-Station-Id (30)
- Calling-Station-Id (31)
- NAS-Identifier (32)

#### Accounting Attributes
- Acct-Status-Type (40)
- Acct-Delay-Time (41)
- Acct-Input-Octets (42)
- Acct-Output-Octets (43)
- Acct-Session-Id (44)
- Acct-Authentic (45)
- Acct-Session-Time (46)
- Acct-Input-Packets (47)
- Acct-Output-Packets (48)
- Acct-Terminate-Cause (49)

## Configuration Parameters

### Traffic Parameters
- **call-rate**: Number of calls per second (default: 1)
- **call-timeout-ms**: Timeout for each call in milliseconds (default: 10000)
- **max-simultaneous-calls**: Maximum concurrent calls (default: 2000)
- **display-period**: Statistics display interval in seconds (default: 1)

### Transport Settings
- **Authentication**: UDP port 1812 (standard RADIUS auth port)
- **Accounting**: TCP port 1813 (configured for testing)
- **Bind Address**: 127.0.0.1 (localhost)

## Logs and Statistics

All logs are stored in the `logs/` directory:
- `radius-auth-server.log` - Server execution log
- `radius-auth-client.log` - Client execution log
- `radius-auth-server-stat.csv` - Server statistics
- `radius-auth-client-stat.csv` - Client statistics
- `radius-auth-server-protocol-stat.csv` - Server protocol statistics
- `radius-auth-client-protocol-stat.csv` - Client protocol statistics

## Customization

### Modifying Authentication Credentials
Edit `scenario/radius/radius-auth.client.xml`:
```xml
<Attribute name="User-Name" value="your-username@example.com"> </Attribute>
<Attribute name="User-Password" value="your-password"> </Attribute>
```

### Changing Call Rate
Edit the configuration file (`conf.auth-client.xml`):
```xml
<define entity="traffic-param" name="call-rate" value="10"></define>
```

### Using External Data Files
Uncomment in configuration files:
```xml
<define entity="traffic-param" name="external-data-file" value="../scenario/radius/external_client_data.csv"></define>
<define entity="traffic-param" name="external-data-select" value="sequential"></define>
```

## Troubleshooting

### Port Already in Use
If you get "Address already in use" error:
```bash
# Check what's using the port
sudo netstat -tulpn | grep 1812
# Or
sudo lsof -i :1812

# Kill the process if needed
sudo kill -9 <PID>
```

### No Response from Server
1. Verify server is running and listening on correct port
2. Check firewall settings
3. Review logs in `logs/` directory
4. Ensure client and server are using same dictionary file

### Authentication Failures
1. Check that Identifier values match between request and response
2. Verify Authenticator field is properly set
3. Review attribute values in scenario files

## References

- RFC 2865 - Remote Authentication Dial In User Service (RADIUS)
- RFC 2866 - RADIUS Accounting
- Seagull Documentation: http://gull.sourceforge.net/

## Notes

- The authenticator field is automatically generated by Seagull
- User-Password should be encrypted in production (not implemented in test scenarios)
- Message-Authenticator (attribute 80) can be added for enhanced security
- The scenarios are designed for basic functional testing, not production use
