# **Centralized configuration (agent.conf)**[**Permalink to this headline**](https://documentation.wazuh.com/current/user-manual/reference/centralized-configuration.html#centralized-configuration-agent-conf)

Version 4.11 (current)

-   [User manual](https://documentation.wazuh.com/current/user-manual/index.html)
-   [Reference](https://documentation.wazuh.com/current/user-manual/reference/index.html)
-   Centralized configuration (agent.conf)  
     

## **Introduction**[**Permalink to this headline**](https://documentation.wazuh.com/current/user-manual/reference/centralized-configuration.html#introduction)

Agents can be configured remotely by using the `agent.conf` file. The following capabilities can be configured remotely:

[File Integrity monitoring](https://documentation.wazuh.com/current/user-manual/capabilities/file-integrity/index.html) (**syscheck**)

[Rootkit detection](https://documentation.wazuh.com/current/user-manual/capabilities/malware-detection/index.html) (**rootcheck**)

[Log data collection](https://documentation.wazuh.com/current/user-manual/capabilities/log-data-collection/index.html) (**localfile**)

[Remote commands](https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/wodle-command.html) (**wodle name="command"**)

[Labels for agent alerts](https://documentation.wazuh.com/current/user-manual/agent/agent-management/labels.html) (**labels**)

[Security Configuration Assessment](https://documentation.wazuh.com/current/user-manual/capabilities/sec-config-assessment/index.html) (**sca**)

[System inventory](https://documentation.wazuh.com/current/user-manual/capabilities/system-inventory/index.html) (**syscollector**)

[Avoid events flooding](https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/client-buffer.html) (**client\_buffer**)

[Configure osquery wodle](https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/wodle-osquery.html) (**wodle name="osquery"**)

[force\_reconnect\_interval setting](https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/client.html) (**client**)

**Note**

When setting up remote commands in the shared agent configuration, **you must enable remote commands for Agent Modules**. This is enabled by adding the following line to the `/var/ossec/etc/local_internal_options.conf` file in the agent:

wazuh\_command.remote\_commands=1

## **Agent groups**[**Permalink to this headline**](https://documentation.wazuh.com/current/user-manual/reference/centralized-configuration.html#agent-groups)

Agents can be grouped together in order to send them a unique centralized configuration that is group specific. Each agent can belong to more than one group, and unless otherwise configured, all agents belong to a group called `default`.

**Note**

Check the [agent\_groups manual](https://documentation.wazuh.com/current/user-manual/reference/tools/agent-groups.html) to learn how to add groups and assign agents to them.

The manager pushes all files included in the group folder to the agents belonging to this group. For example, all files in `/var/ossec/etc/shared/default` will be pushed to all agents belonging to the `default` group.

In case an agent is assigned to multiple groups, all the files contained in each group folder will be merged into one, and subsequently sent to the agents, being the last one the group with the highest priority.

The file `ar.conf` (Active Response status) will always be sent to agents even if it is not present in the group folder.

The agent will store the shared files in `/var/ossec/etc/shared`, not in a group folder.

Below are the files that would be found in this folder on an agent assigned to the **debian** group. Notice that these files are pushed to the agent from the manager `/var/ossec/etc/shared/debian` folder.

|     |     |
| --- | --- |
| **Manager** | **Agent (Group: 'debian')** |
| /var/ossec/etc/shared/ <br><br>├── ar.conf <br><br>├── debian <br><br>│   ├── agent.conf <br><br>│   ├── cis\_debian\_linux\_rcl.txt <br><br>│   ├── cis\_rhel5\_linux\_rcl.txt <br><br>│   ├── cis\_rhel6\_linux\_rcl.txt <br><br>│   ├── cis\_rhel7\_linux\_rcl.txt <br><br>│   ├── cis\_rhel\_linux\_rcl.txt <br><br>│   ├── cis\_sles11\_linux\_rcl.txt <br><br>│   ├── cis\_sles12\_linux\_rcl.txt <br><br>│   ├── custom\_rootcheck.txt <br><br>│   ├── debian\_ports\_check.txt <br><br>│   ├── debian\_test\_files.txt <br><br>│   ├── merged.mg <br><br>│   ├── rootkit\_files.txt <br><br>│   ├── rootkit\_trojans.txt <br><br>│   ├── system\_audit\_rcl.txt <br><br>│   ├── system\_audit\_ssh.txt <br><br>│   ├── win\_applications\_rcl.txt <br><br>│   ├── win\_audit\_rcl.txt<br><br>│   └── win\_malware\_rcl.txt <br><br>└── default<br><br>    ├── agent.conf<br><br>    ├── cis\_debian\_linux\_rcl.txt<br><br>    ├── cis\_rhel5\_linux\_rcl.txt<br><br>    ├── cis\_rhel6\_linux\_rcl.txt<br><br>    ├── cis\_rhel7\_linux\_rcl.txt<br><br>    ├── cis\_rhel\_linux\_rcl.txt<br><br>    ├── cis\_sles11\_linux\_rcl.txt<br><br>    ├── cis\_sles12\_linux\_rcl.txt<br><br>    ├── merged.mg<br><br>    ├── rootkit\_files.txt<br><br>    ├── rootkit\_trojans.txt<br><br>    ├── system\_audit\_rcl.txt<br><br>    ├── system\_audit\_ssh.txt<br><br>    ├── win\_applications\_rcl.txt<br><br>    ├── win\_audit\_rcl.txt<br><br>    └── win\_malware\_rcl.txt | /var/ossec/etc/shared/<br><br> ├── ar.conf<br><br> ├── agent.conf<br><br> ├── cis\_debian\_linux\_rcl.txt<br><br> ├── cis\_rhel5\_linux\_rcl.txt<br><br> ├── cis\_rhel6\_linux\_rcl.txt<br><br> ├── cis\_rhel7\_linux\_rcl.txt<br><br> ├── cis\_rhel\_linux\_rcl.txt<br><br> ├── cis\_sles11\_linux\_rcl.txt<br><br> ├── cis\_sles12\_linux\_rcl.txt<br><br> ├── custom\_rootcheck.txt<br><br> ├── debian\_ports\_check.txt<br><br> ├── debian\_test\_files.txt<br><br> ├── merged.mg<br><br> ├── rootkit\_files.txt<br><br> ├── rootkit\_trojans.txt<br><br> ├── system\_audit\_rcl.txt<br><br> ├── system\_audit\_ssh.txt<br><br> ├── win\_applications\_rcl.txt<br><br> ├── win\_audit\_rcl.txt<br><br> └── win\_malware\_rcl.txt |

The proper syntax of `agent.conf` is shown below along with the process for pushing the configuration from the manager to the agent.

## **agent.conf**[**Permalink to this headline**](https://documentation.wazuh.com/current/user-manual/reference/centralized-configuration.html#agent-conf)

**XML section name**

```plaintext
<agent_config>
    ...
</agent_config>
```

The `agent.conf` is only valid on server installations.

The `agent.conf` may exist in each group folder at `/var/ossec/etc/shared`.

For example, for the `group1` group, it is in `/var/ossec/etc/shared/group1`. Each of these files should be readable by the `wazuh` user.

## **Options**[**Permalink to this headline**](https://documentation.wazuh.com/current/user-manual/reference/centralized-configuration.html#options)

|     |     |
| --- | --- |
| **name** | Assigns the block to agents with specific names. |     |
| Allowed values | Any regular expression that matches the agent name. |
| **os** | Assigns the block to agents on specific operating systems. |     |
| Allowed values | Any regular expression that matches the agent OS information. |
| **profile** | Assigns the block to agents with specific profiles as defined in [client configuration](https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/client.html#reference-ossec-client-config-profile). |     |
| Allowed values | Any regular expression that matches the agent profile. |

**Example**

```plaintext
<agent_config name=”^agent01|^agent02”>
...
<agent_config os="^Linux">
...
<agent_config profile="^UnixHost">
```

To get the agent name and operating system information, you can run the `agent_control` utility.

```plaintext
agent_control -i <AGENT_ID>
```

Where `<AGENT_ID>` corresponds to the agent ID of the endpoint.

**Output**

```plaintext
Wazuh agent_control. Agent information: 
Agent ID:   001 
Agent Name: agent01 
IP address: any 
Status:     Active 

Operating system:    Linux |centos9 |5.14.0-366.el9.x86_64 |#1 SMP PREEMPT_DYNAMIC Thu Sep 14 23:37:14 UTC 2023 |x86_64 
Client version:      Wazuh v4.5.2 
Configuration hash:  ab73af41699f13fdd81903b5f23d8d00 
Shared file hash:    4a8724b20dee0124ff9656783c490c4e 
Last keep alive:     1696963366 

Syscheck last started at:  Tue Oct 10 12:37:43 2023 
Syscheck last ended at:    Tue Oct 10 12:37:46 2023
```

## **Centralized configuration process**[**Permalink to this headline**](https://documentation.wazuh.com/current/user-manual/reference/centralized-configuration.html#centralized-configuration-process)

The following is an example of how a centralized configuration can be done.

Configure the `agent.conf` file:

> Edit the file corresponding to the agent group. For example, for the `default` group, edit the file `/var/ossec/etc/shared/default/agent.conf`. If the file does not exist, create it:
> 
> \# touch /var/ossec/etc/shared/default/agent.conf # chown wazuh:wazuh /var/ossec/etc/shared/default/agent.conf # chmod 660 /var/ossec/etc/shared/default/agent.conf
> 
> Several configurations may be created based on the `name`, `OS` or `profile` of an agent.
> 
> <agent\_config name="agent\_name">    <localfile>        <location>/var/log/my.log</location>        <log\_format>syslog</log\_format>    </localfile> </agent\_config> <agent\_config os="Linux">    <localfile>        <location>/var/log/linux.log</location>        <log\_format>syslog</log\_format>    </localfile> </agent\_config> <agent\_config profile="database">    <localfile>        <location>/var/log/database.log</location>        <log\_format>syslog</log\_format>    </localfile> </agent\_config>
> 
> **Note**
> 
> The `profile` option uses the values defined on the `<config-profile>` setting from the [client configuration](https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/client.html#reference-ossec-client-config-profile).

Run `/var/ossec/bin/verify-agent-conf`:

> Each time you make a change to the `agent.conf` file, it is important to check for configuration errors. If any errors are reported by this check, they must be fixed before the next step. Failure to perform this step may allow errors to be pushed to agents which may prevent the agents from running. At that point, it is very likely that you will be forced to visit each agent manually to recover them.

Push the configuration to the agents:

> With every agent keepalive (10 seconds default), the agent sends to the manager the checksum of its merge.md file and the manager compares it with the current one. If the received checksum differs from the available one, the Wazuh manager pushes the new file to the agent. The agent will start using the new configuration after being restarted.
> 
> **Note**
> 
> Restarting the manager will make the new `agent.conf` file available to the agents more quickly.

Confirm that the agent received the configuration:

> The `agent_groups` tool or the Wazuh API endpoint [GET /agents](https://documentation.wazuh.com/current/user-manual/api/reference.html#operation/api.controllers.agent_controller.get_agents) can show whether the group configuration is synchronized in the agent or not:
> 
> \# curl -k -X GET "https://localhost:55000/agents?agents\_list=001&select=group\_config\_status&pretty=true" -H  "Authorization: Bearer $TOKEN"
> 
> **Output**
> 
> {   "data": {      "affected\_items": \[         {            "group\_config\_status": "synced",            "id": "001"         }      \],      "total\_affected\_items": 1,      "total\_failed\_items": 0,      "failed\_items": \[\]   },   "message": "All selected agents information was returned",   "error": 0 }
> 
> \# /var/ossec/bin/agent\_groups -S -i 001
> 
> **Output**
> 
> Agent '001' is synchronized.

Restart the agent:

> By default, the agent restarts by itself automatically when it receives a new shared configuration.
> 
> If `auto_restart` has been disabled (in the `<client>` section of [Local configuration](https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/index.html)), the agent will have to be manually restarted so that the new `agent.conf` file will be used. This can be done as follows:
> 
> \# /var/ossec/bin/agent\_control -R -u 1032
> 
> **Output**
> 
> Wazuh agent\_control: Restarting agent: 1032

## **Precedence**[**Permalink to this headline**](https://documentation.wazuh.com/current/user-manual/reference/centralized-configuration.html#precedence)

It's important to understand which configuration file takes precedence between `ossec.conf` and `agent.conf` when the central configuration is used. When this configuration is utilized, the local and the shared configuration are merged, however, the `ossec.conf` file is read before the shared `agent.conf` and the last configuration of any setting will overwrite the previous. Also, if a file path for a particular setting is set in both of the configuration files, both paths will be included in the final configuration.

For example:

Let's say we have this configuration in the `ossec.conf` file:

<sca>  <enabled>no</enabled>  <scan\_on\_start>yes</scan\_on\_start>  <interval>12h</interval>  <skip\_nfs>yes</skip\_nfs>  <policies>    <policy>system\_audit\_rcl.yml</policy>    <policy>system\_audit\_ssh.yml</policy>    <policy>system\_audit\_pw.yml</policy>  </policies> </sca>

and this configuration in the `agent.conf` file.

<sca>  <enabled>yes</enabled>  <policies>    <policy>cis\_debian\_linux\_rcl.yml</policy>  </policies> </sca>

The final configuration will enable the Security Configuration Assessment module. In addition, it will add the *cis\_debian\_linux\_rcl.yml* to the list of scanned policies. In other words, the configuration located at `agent.conf` will overwrite the one of the `ossec.conf`.

## **How to ignore shared configuration**[**Permalink to this headline**](https://documentation.wazuh.com/current/user-manual/reference/centralized-configuration.html#how-to-ignore-shared-configuration)

Whether for any reason you don't want to apply the shared configuration in a specific agent, it can be disabled by adding the following line to the `/var/ossec/etc/local_internal_options.conf` file in that agent:

agent.remote\_conf=0

## **Download configuration files from remote location**[**Permalink to this headline**](https://documentation.wazuh.com/current/user-manual/reference/centralized-configuration.html#download-configuration-files-from-remote-location)

The Wazuh manager has the capability to download configuration files like `merged.mg` as well as other files to be merged for the groups that you want.

To use this feature, we need to put a yaml file named `files.yml` under the directory `/var/ossec/etc/shared/`. When the **manager** starts, it will read and parse the file.

The `files.yml` has the following structure as shown in the following example:

groups:    my\_group\_1:        files:            agent.conf: https://example.com/agent.conf            rootcheck.txt: https://example.com/rootcheck.txt            merged.mg: https://example.com/merged.mg        poll: 15    my\_group\_2:        files:            agent.conf: https://example.com/agent.conf        poll: 200 agents:    001: my\_group\_1    002: my\_group\_2    003: another\_group

Here we can distinguish the two main blocks: `groups` and `agents`.

In the `groups` block we define the group name from which we want to download the files.

> If the group doesn't exist, it will be created.
> 
> If a file has the name `merged.mg`, only this file will be downloaded. Then it will be validated.
> 
> The `poll` label indicates the download rate in seconds of the specified files.

This configuration can be changed on the fly. The **manager** will reload the file and parse it again so there is no need to restart the **manager** every time.

The information about the parsing is shown on the `/var/ossec/logs/ossec.log` file. For example:

Parsing is successful:

**Output**

INFO: Successfully parsed of yaml file: /etc/shared/files.yml

File has been changed:

**Output**

INFO: File '/etc/shared/files.yml' changed. Reloading data

Parsing failed due to bad token:

**Output**

INFO: Parsing file '/etc/shared/files.yml': unexpected identifier: 'group'

Download of file failed:

**Output**

ERROR: Failed to download file from url: https://example.com/merged.mg

Downloaded `merged.mg` file is corrupted or not valid:

**Output**

ERROR: The downloaded file '/var/download/merged.mg' is corrupted.

[Verifying configuration](https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/verifying-configuration.html)[Internal configuration](https://documentation.wazuh.com/current/user-manual/reference/internal-options.html)

**Explore**

-   [Overview](https://wazuh.com/platform/overview/)
-   [XDR](https://wazuh.com/platform/xdr/)
-   [SIEM](https://wazuh.com/platform/siem/)

**Services**

-   [Wazuh Cloud](https://wazuh.com/cloud/)
-   [Professional support](https://wazuh.com/services/professional-support/)
-   [Consulting services](https://wazuh.com/services/consulting-services/)
-   [Training courses](https://wazuh.com/services/training-courses/)

**Company**

-   [About us](https://wazuh.com/about-us/)
-   [Customers](https://wazuh.com/our-customers/)
-   [Partners](https://wazuh.com/partners/)

**Documentation**

-   [Quickstart](https://documentation.wazuh.com/current/quickstart.html)
-   [Getting started](https://wazuh.com/current/getting-started/index.html)
-   [Installation guide](https://wazuh.com/current/installation-guide/index.html)

**Resources**

-   [Blog](https://wazuh.com/blog/)
-   [Community](https://wazuh.com/community/)

© 2025 Wazuh Inc.

[Legal resources](https://wazuh.com/legal-resources/)

[Contact us](https://wazuh.com/contact-us/)

[+1 (844) 349 2984](tel:+18443492984)

-   [X](https://x.com/wazuh)
-   [LinkedIn](https://www.linkedin.com/company/wazuh)
-   [Reddit](https://www.reddit.com/r/Wazuh/)
-   [GitHub](https://github.com/wazuh)
-   [Slack](https://wazuh.com/community/join-us-on-slack/)
-   [Mailing list](mailto:wazuh+subscribe@googlegroups.com)