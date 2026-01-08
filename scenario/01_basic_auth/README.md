# Basic Authentication Test Scenarios

This directory contains test scenarios for basic DIAMETER AAA authentication using User-Password AVP.

## Scenarios

### 1. user_password_success.xml

**Description**: Tests successful authentication with correct credentials

**Flow**:
1. CER/CEA - Capabilities Exchange
2. AAR with User-Password
3. AAA with Result-Code 2001 (Success)

**Expected Results**:
- Result-Code: 2001 (DIAMETER_SUCCESS)
- Session-Timeout: 3600 seconds
- Idle-Timeout: 600 seconds
- Framed-IP-Address: 10.1.1.100
- VLAN-ID: 100

**Run**:
```bash
cd /home/ankit/DIAMETER_production/diameter-aaa/seagull-tests
./scripts/run_scenario.sh scenarios/01_basic_auth/user_password_success.xml
```

### 2. user_password_failure.xml

**Description**: Tests failed authentication with wrong password

**Flow**:
1. CER/CEA - Capabilities Exchange
2. AAR with wrong User-Password
3. AAA with Result-Code 4001 (Authentication-Rejected)

**Expected Results**:
- Result-Code: 4001 (DIAMETER_AUTHENTICATION_REJECTED)

**Run**:
```bash
./scripts/run_scenario.sh scenarios/01_basic_auth/user_password_failure.xml
```

## Test Credentials

**Valid User**:
- Username: user1@example.com
- Password: password123 (hex: 0x70617373776f7264313233)

**Invalid Password**:
- Password: wrongpass (hex: 0x77726f6e6770617373)

## Customization

To test with different users, edit the scenario XML:

```xml
<avp name="User-Name" value="your-user@example.com"> </avp>
<avp name="User-Password" value="0xHEX_ENCODED_PASSWORD"> </avp>
```

To convert password to hex:
```bash
echo -n "your_password" | xxd -p
```

## Troubleshooting

**Connection Refused**:
- Ensure AAA server is running
- Check: `ps aux | grep diameter-server`
- Check: `netstat -an | grep 3868`

**Authentication Failed**:
- Verify user exists in config.yaml
- Check password is correct
- Review server logs

**Timeout**:
- Increase timeout in conf.aaa-client.xml
- Check server responsiveness
