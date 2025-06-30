# Delphi | API

# Logging into the Wazuh server API via command line

To ensure secure access, all Wazuh server API endpoints require authentication. Users must include a JSON Web Token (JWT) in every request. JWT is an open standard (RFC 7519) that defines a compact and self-contained method for securely transmitting information between parties as a JSON object.

Follow the steps below to log into the Wazuh server API using `POST /security/user/authenticate` and obtain a token necessary for accessing the API endpoints:

Run the following command to send a user authentication `POST` request to the Wazuh server API and store the returned JWT in the `TOKEN` variable. Replace `<WAZUH_API_USER>` and `<WAZUH_API_PASSWORD>` with your credentials.

Note, you need to run this command on the server where Delphi is installed because we're running this command to get `TOKEN` from `...https://localhost:55000...`:

```plaintext
TOKEN=$(curl -u '<WAZUH_API_USER>:<WAZUH_API_PASSWORD>' -k -X POST "https://localhost:55000/security/user/authenticate?raw=true")
```

Remember, we updated the `<WAZUH_API_PASSWORD>` [earlier](/delphi/change_default_passwd)

The credentials are  
`<WAZUH_API_USER>`\=`wazuh-wui`  
`<WAZUH_API_PASSWORD>`\=`TheP@sswordY0uChangedEarlier`

Also, make sure `'<WAZUH_API_USER>:<WAZUH_API_PASSWORD>'` are enclosed in `single quotes` to ensure `bash` parses them properly. Otherwise, special characters like `!`, `&`, and `$` result in funny errors

## Retrieve JWT authentication token locally

```plaintext
TOKEN=$(curl -u 'wazuh-wui:TheP@sswordY0uChangedEarlier' -k -X POST "https://localhost:55000/security/user/authenticate?raw=true")
```

Expected output:

```plaintext
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   404  100   404    0     0   1223      0 --:--:-- --:--:-- --:--:--  1224
```

### Echo `$TOKEN` to terminal

This is an authentication token, so keep it secret.

```plaintext
echo $TOKEN
```

### Verify

Check everything is working correctly locally

```plaintext
curl -k -X GET "https://localhost:55000/" -H "Authorization: Bearer $TOKEN"
```

Expected output should be similar to:

```plaintext
{"data": {"title": "Wazuh API REST", "api_version": "4.10.1", "revision": 41011, "license_name": "GPL 2.0", "license_url": "https://github.com/wazuh/wazuh/blob/v4.10.1/LICENSE", "hostname": "wazuh.master", "timestamp": "2025-01-26T07:01:15Z"}, "error": 0}
```

## Retrieve JWT authentication token remotely/over web

And check everything is working correctly over the web. This can be done on the server where Wazuh is installed, but is better done on a remote machine with an agent installed on it

```plaintext
read -p "Enter the Wazuh domain (eg. wazuh.domain.com): " WZ_FQDN
read -p "Enter the API username (eg. wazuh-wui): " WZ_API_USR
read -p "Enter the API passwd: " WZ_API_PASSWD

TOKEN=$(curl -u "${WZ_API_USR}:${WZ_API_PASSWD}" -k -X POST "https://${WZ_FQDN}:55000/security/user/authenticate?raw=true")

echo ""
echo "Your JWT auth token is:"

echo ""
echo "$TOKEN"

echo ""
echo "finis"
```

Expected should be the same again:

```plaintext
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   404  100   404    0     0   1223      0 --:--:-- --:--:-- --:--:--  1224
```

### Echo `$TOKEN` to terminal

This is an authentication token, so keep it secret.

```plaintext
echo $TOKEN
```

### Verify

Check everything is working correctly locally

```plaintext
curl -k -X GET "https://wazuh.domain.com:55000/" -H "Authorization: Bearer $TOKEN"
```

Output should be very similar again:

```plaintext
{"data": {"title": "Wazuh API REST", "api_version": "4.10.1", "revision": 41011, "license_name": "GPL 2.0", "license_url": "https://github.com/wazuh/wazuh/blob/v4.10.1/LICENSE", "hostname": "wazuh.master", "timestamp": "2025-01-26T07:01:15Z"}, "error": 0}
```

# Changing RBAC settings

Set RBAC mode  
As explained in the how it works section, you can modify the RBAC mode and change it to white or black using the PUT /security/config endpoint. You can also restore it to default with the DELETE /security/config endpoint.

Here is an example of how to change RBAC mode using a cURL command. We recommend that you export the authentication token to an environment variable as explained in the getting started section. Replace <DESIRED\_RBAC\_MODE> with the mode to enable (white or black):

## RBAC modes

You can configure RBAC in Wazuh in two distinct and opposite modes: black and white. The selected mode shapes the behavior of the policies created. Setting a policy's effect parameter to allow permits that policy in both black and white modes. Conversely, setting the effect to deny prohibits it in both modes. Therefore, the RBAC mode only affects actions that are not specified within each policy.

### Whitelist mode:

The system forbids all actions by default. The administrator configures roles to grant permissions.

```plaintext
curl -k -X PUT "https://localhost:55000/security/config?pretty=true" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{\"rbac_mode\":\"white\"}"
```

### Blacklist mode:

The system allows all actions by default. The administrator configures roles to restrict permissions.

```plaintext
curl -k -X PUT "https://localhost:55000/security/config?pretty=true" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{\"rbac_mode\":\"black\"}"
```

# Listing agents via API

```plaintext
curl -k -X GET "https://<WAZUH_MANAGER_IP_ADDRESS>:55000/agents?pretty=true&sort=-ip,name" -H  "Authorization: Bearer $TOKEN"
```

# Removing agents via API

**RBAC blacklist mode needs to be enabled**

To remove agents with ID 005, 006, 007.

```plaintext
curl -k -X DELETE "https://localhost:55000/agents?pretty=true&older_than=0s&agents_list=005,006,007&status=all" -H  "Authorization: Bearer $TOKEN"
```

To select the agents you want to remove?

```plaintext
read -p "List the agents you would like to remove (comma,separated,variables): " RM_AGENTS
curl -k -X DELETE "https://localhost:55000/agents?pretty=true&older_than=0s&agents_list=$RM_AGENTS&status=all" -H  "Authorization: Bearer $TOKEN"
```

# Stopping agents via API

The Wazuh API does not offer a direct endpoint to remotely stop (i.e. terminate) the agent service running on an endpoint. The available API actions allow you to delete, block, restart, or otherwise manage an agent’s record and its connectivity, but they don’t actually stop the underlying service on the agent’s host.

Here’s what you can do instead:

## Block the Agent via API:

Blocking an agent prevents the manager from processing data from that agent even if its service is still running. For example, you can update the agent’s status to “blocked” with a PUT request:

```plaintext
read -p "List the agent/s you would like to block (comma,separated,variables): " BLK_AGENTS
curl -k -X PUT "https://localhost:55000/agents/$BLK_AGENTS/status" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"status": "blocked"}'
```

Replace <AGENT\_ID> and YOUR\_TOKEN with the appropriate values. This doesn’t stop the service on the endpoint, but it stops the manager from re-registering or processing its events.

## Disable Auto-Registration:

If your agent is reappearing because it is auto-registering, you can modify the auto-registration settings in your manager’s configuration (typically in the ossec.conf file) to restrict auto-registration. For example, you might disable it entirely or restrict it to a certain IP range.

## Stop the Agent on the Endpoint:

To actually stop the agent’s service, you’ll need to run an OS-specific command on the endpoint itself. For example:

### On Linux:

```plaintext
sudo systemctl stop wazuh-agent
```

### On Windows:

Stop the “Wazuh Agent” service from the Services management console or via PowerShell:

```plaintext
Stop-Service -Name "Wazuh Agent"
```

### On macOS:

Run the uninstall script or stop the service if it was installed as a service.

Because the Wazuh API is focused on managing agent records and sending commands that the agent may execute (like restart or upgrade), it doesn’t provide a mechanism to remotely shut down the operating system service itself. If you need to automate stopping the agent remotely, you would have to use other remote execution tools (such as SSH on Linux/macOS or PowerShell remoting on Windows) in conjunction with the Wazuh API.

## Summary

-   Direct API Stop: Not available.

Alternative Approaches:

-   Use the API to block the agent so the manager ignores its data.
-   Disable or modify auto-registration to prevent re-registration.
-   Use OS-specific commands (manually or via remote execution tools) on the agent host to actually stop the service.

Choose the approach that best fits your operational needs.

# Upgrading the Wazuh agent

**A Wazuh agent can be upgraded remotely using the command line and through the Wazuh server API.**

Warning It is recommended to use the Wazuh server API to upgrade agents if running a Wazuh cluster.

##   
Using the command line  
 

To upgrade agents using the command line, use the /var/ossec/bin/agent\_upgrade tool as follows:

List all outdated agents using the -l parameter:

```plaintext
/var/ossec/bin/agent_upgrade -l
```

  
Output

```plaintext

ID Name Version
002 VM_Debian9 Wazuh v4.7.2
003 VM_Debian8 Wazuh v4.7.2
009 VM_WinServ2016 Wazuh v4.7.2
```

Total outdated agents: 3  
Upgrade the Wazuh agent using the -a parameter followed by the agent ID (here, the agent ID is 003):

```plaintext
/var/ossec/bin/agent_upgrade -a 003
```

Output  
 

```plaintext
Upgrading...
Upgraded agents:
Agent 003 upgraded: Wazuh v4.7.2 -> Wazuh v4.8.0
```

  
Following the upgrade, the Wazuh agent is automatically restarted. Check the agent version to ensure it has been properly upgraded as follows:

```plaintext
/var/ossec/bin/agent_control -i 003
```

  
Output

```plaintext
Agent ID: 003
Agent Name: wazuh-agent2
IP address: any/any
Status: Active
Operating system: Linux |wazuh-agent2 |5.8.0-7625-generic |#26160444147720.10~d41e407-Ubuntu SMP Wed Jul 4 01:25:00 UTC 2 |x86_64
Client version: Wazuh v4.8.0
Configuration hash: e2f47d482da37c099fa1d6e4c43b523c
Shared file hash: aabb92f4a8cba49c7c6045c1aa80fbd3
Last keep alive: 1604927114
Syscheck last started at: Mon Jul 9 13:00:55 2024
Syscheck last ended at: Mon Jul 9 13:00:56 2024
Rootcheck last started at: Mon Jul 9 13:00:57 2024
```

##   
Using the RESTful API

### List all outdated agents using endpoint GET /agents/outdated. 

Replace <WAZUH\_MANAGER\_IP\_ADDRESS> with the IP address or FQDN of the Wazuh server:

```plaintext
curl -k -X GET "https://<WAZUH_MANAGER_IP_ADDRESS>:55000/agents/outdated?pretty=true" -H "Authorization: Bearer $TOKEN"
```

###   
Output

```plaintext

{
"data": {
"affected_items": [
{"version": "Wazuh v4.7.2", "id": "002", "name": "VM_Debian9"},
{"version": "Wazuh v4.7.2", "id": "003", "name": "VM_Debian8"},
{"version": "Wazuh v4.7.2", "id": "009", "name": "VM_WinServ2016"},
],
"total_affected_items": 3,
"total_failed_items": 0,
"failed_items": [],
},
"message": "All selected agents information was returned",
"error": 0,
}
```

###   
Upgrade the Wazuh agent using endpoint PUT /agents/upgrade (here, we upgrade agents with ID 002 and 003). 

Replace <WAZUH\_MANAGER\_IP\_ADDRESS> with the IP address or FQDN of the Wazuh server:

```plaintext
curl -k -X PUT "https://<WAZUH_MANAGER_IP_ADDRESS>:55000/agents/upgrade?agents_list=002,003&pretty=true" -H "Authorization: Bearer $TOKEN"
```

###   
Output

```plaintext

{
"data": {
"affected_items": [
{
"agent": "002",
"task_id": 1
},
{
"agent": "003",
"task_id": 2
}
],
"total_affected_items": 2,
"total_failed_items": 0,
"failed_items": []
},
"message": "All upgrade tasks were created",
"error": 0
}
```

  
The agents\_list parameter in the PUT /agents/upgrade and PUT /agents/upgrade\_custom endpoints allows the value all. 

When this value is set, an upgrade request will be sent to all Wazuh agents.

When upgrading more than 3000 Wazuh agents at the same time, it is highly recommended that the parameter wait\_for\_complete be set to true to avoid a possible API timeout.

This recommendation is based on testing with a Wazuh manager on a server with a 2.5 GHz AMD EPYC 7000 series processor and 4 GiB memory. Using an agent list with 3000 agents or fewer on a system with similar or better specifications guarantees a response before the API timeout occurs.

### Check the upgrade results using endpoint GET /agents/upgrade\_result. 

Replace <WAZUH\_MANAGER\_IP\_ADDRESS> with the IP address or FQDN of the Wazuh server:

```plaintext
curl -k -X GET "https://<WAZUH_MANAGER_IP_ADDRESS>:55000/agents/upgrade_result?agents_list=002,003&pretty=true" -H "Authorization: Bearer $TOKEN"
```

Output

```plaintext

{
"data": {
"affected_items": [
{
"message": "Success",
"agent": "002",
"task_id": 1,
"node": "worker2",
"module": "upgrade_module",
"command": "upgrade",
"status": "Updated",
"create_time": "2024-07-09T17:13:45Z",
"update_time": "2024-07-09T17:14:07Z"
},
{
"message": "Success",
"agent": "003",
"task_id": 2,
"node": "worker1",
"module": "upgrade_module",
"command": "upgrade",
"status": "Updated",
"create_time": "2024-07-09T17:13:45Z",
"update_time": "2024-07-09T17:14:11Z"
}
],
"total_affected_items": 2,
"total_failed_items": 0,
"failed_items": []
},
"message": "All upgrade tasks were returned",
"error": 0
}
```

###   
Following the upgrade, the Wazuh agents are automatically restarted. 

Check the version of the Wazuh agents to ensure they have been properly upgraded using endpoint GET /agents:

```plaintext
curl -k -X GET "https://<WAZUH_MANAGER_IP_ADDRESS>:55000/agents?agents_list=002,003&pretty=true&select=version" -H "Authorization: Bearer $TOKEN"
```

### Output

```plaintext
{
"data": {
"affected_items": [
{
"id": "002",
"version": "Wazuh 4.8.0"
},
{
"id": "003",
"version": "Wazuh 4.8.0"
}
],
"total_affected_items": 2,
"total_failed_items": 0,
"failed_items": []
},
"message": "All selected agents information was returned",
"error": 0
}
```