# **Blocking a known malicious actor**[**Permalink to this headline**](https://documentation.wazuh.com/current/proof-of-concept-guide/block-malicious-actor-ip-reputation.html#blocking-a-known-malicious-actor)

Version 4.11 (current)

 [Proof of Concept guide](https://documentation.wazuh.com/current/proof-of-concept-guide/index.html)
 Blocking a known malicious actor

In this use case, we demonstrate how to block malicious IP addresses from accessing web resources on a web server. You set up Apache web servers on Ubuntu and Windows endpoints, and try to access them from an RHEL endpoint.

This case uses a public IP reputation database that contains the IP addresses of some malicious actors. An IP reputation database is a collection of IP addresses that have been flagged as malicious. The RHEL endpoint plays the role of the malicious actor here, therefore you add its IP address to the reputation database. Then, configure Wazuh to block the RHEL endpoint from accessing web resources on the Apache web servers for 60 seconds. It’s a way of discouraging attackers from continuing to carry out their malicious activities.

In this use case, you use the Wazuh [CDB list](https://documentation.wazuh.com/current/user-manual/ruleset/cdb-list.html) and [Active Response](https://documentation.wazuh.com/current/getting-started/use-cases/incident-response.html) capabilities.

## **Infrastructure**[**Permalink to this headline**](https://documentation.wazuh.com/current/proof-of-concept-guide/block-malicious-actor-ip-reputation.html#infrastructure)

| **Endpoint** | **Description** |
| --- | --- |
| RHEL 9.0 | Attacker endpoint connecting to the victim's web server on which you use Wazuh CDB list capability to flag its IP address as malicious. |
| Ubuntu 22.04 | Victim endpoint running an Apache 2.4.54 web server. Here, you use the Wazuh Active Response module to automatically block connections from the attacker endpoint. |
| Windows 11 | Victim endpoint running an Apache 2.4.54 web server. Here, you use the Wazuh Active Response module to automatically block connections from the attacker endpoint. |

## **Configuration**[**Permalink to this headline**](https://documentation.wazuh.com/current/proof-of-concept-guide/block-malicious-actor-ip-reputation.html#configuration)

### **Ubuntu endpoint**[**Permalink to this headline**](https://documentation.wazuh.com/current/proof-of-concept-guide/block-malicious-actor-ip-reputation.html#ubuntu-endpoint)

Perform the following steps to install an Apache web server and monitor its logs with the Wazuh agent.

Update local packages and install the Apache web server:

$ sudo apt update $ sudo apt install apache2

If the firewall is enabled, modify the firewall to allow external access to web ports. Skip this step if the firewall is disabled:

$ sudo ufw status $ sudo ufw app list $ sudo ufw allow 'Apache'

Check the status of the Apache service to verify that the web server is running:

$ sudo systemctl status apache2

Use the `curl` command or open `http://<UBUNTU_IP>` in a browser to view the Apache landing page and verify the installation:

$ curl http://<UBUNTU\_IP>

Add the following to `/var/ossec/etc/ossec.conf` file to configure the Wazuh agent and monitor the Apache access logs:

<localfile>  <log\_format>syslog</log\_format>  <location>/var/log/apache2/access.log</location> </localfile>

Restart the Wazuh agent to apply the changes:

$ sudo systemctl restart wazuh-agent

### **Windows endpoint**[**Permalink to this headline**](https://documentation.wazuh.com/current/proof-of-concept-guide/block-malicious-actor-ip-reputation.html#windows-endpoint)

#### **Install the Apache web server**[**Permalink to this headline**](https://documentation.wazuh.com/current/proof-of-concept-guide/block-malicious-actor-ip-reputation.html#install-the-apache-web-server)

Perform the following steps to install and configure an Apache web server.

Install the latest [Visual C++ Redistributable package](https://aka.ms/vs/17/release/vc_redist.x64.exe).

Download the [Apache web server](https://www.apachelounge.com/download/) Win64 ZIP installation file. This is an already compiled binary for Windows operating systems.

Unzip the contents of the Apache web server zip file and copy the extracted `Apache24` folder to the `C:` directory.

Navigate to the `C:\Apache24\bin\` folder and run the following command in a PowerShell terminal with administrator privileges:

\> .\\httpd.exe

The first time you run the Apache binary a Windows Defender Firewall pops up.

Click on **Allow Access**. This allows the Apache HTTP server to communicate on your private or public networks depending on your network setting. It creates an inbound rule in your firewall to allow incoming traffic on port 80.

Open `http://<WINDOWS_IP>` in a browser to view the Apache landing page and verify the installation. Also, verify that this URL can be reached from the attacker endpoint.

#### **Configure the Wazuh agent**[**Permalink to this headline**](https://documentation.wazuh.com/current/proof-of-concept-guide/block-malicious-actor-ip-reputation.html#configure-the-wazuh-agent)

Perform the steps below to configure the Wazuh agent to monitor Apache web server logs.

Add the following to `C:\Program Files (x86)\ossec-agent\ossec.conf` to configure the Wazuh agent and monitor the Apache access logs:

<localfile>  <log\_format>syslog</log\_format>  <location>C:\\Apache24\\logs\\access.log</location> </localfile>

Restart the Wazuh agent in a PowerShell terminal with administrator privileges to apply the changes:

\> Restart-Service -Name wazuh

### **Wazuh server**[**Permalink to this headline**](https://documentation.wazuh.com/current/proof-of-concept-guide/block-malicious-actor-ip-reputation.html#wazuh-server)

You need to perform the following steps on the Wazuh server to add the IP address of the RHEL endpoint to a CDB list, and then configure rules and Active Response.

#### **Download the utilities and configure the CDB list**[**Permalink to this headline**](https://documentation.wazuh.com/current/proof-of-concept-guide/block-malicious-actor-ip-reputation.html#download-the-utilities-and-configure-the-cdb-list)

Install the `wget` utility to download the necessary artifacts using the command line interface:

$ sudo yum update && sudo yum install -y wget

Download the Alienvault IP reputation database:

$ sudo wget https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/alienvault\_reputation.ipset -O /var/ossec/etc/lists/alienvault\_reputation.ipset

Append the IP address of the attacker endpoint to the IP reputation database. Replace `<ATTACKER_IP>` with the RHEL IP address in the command below:

$ sudo echo "<ATTACKER\_IP>" >> /var/ossec/etc/lists/alienvault\_reputation.ipset

Download a script to convert from the `.ipset` format to the `.cdb` list format:

$ sudo wget https://wazuh.com/resources/iplist-to-cdblist.py -O /tmp/iplist-to-cdblist.py

Convert the `alienvault_reputation.ipset` file to a `.cdb` format using the previously downloaded script:

$ sudo /var/ossec/framework/python/bin/python3 /tmp/iplist-to-cdblist.py /var/ossec/etc/lists/alienvault\_reputation.ipset /var/ossec/etc/lists/blacklist-alienvault

Optional: Remove the `alienvault_reputation.ipset` file and the `iplist-to-cdblist.py` script, as they are no longer needed:

$ sudo rm -rf /var/ossec/etc/lists/alienvault\_reputation.ipset $ sudo rm -rf /tmp/iplist-to-cdblist.py

Assign the right permissions and ownership to the generated file:

$ sudo chown wazuh:wazuh /var/ossec/etc/lists/blacklist-alienvault

#### **Configure the Active Response module to block the malicious IP address**[**Permalink to this headline**](https://documentation.wazuh.com/current/proof-of-concept-guide/block-malicious-actor-ip-reputation.html#configure-the-active-response-module-to-block-the-malicious-ip-address)

Add a custom rule to trigger a Wazuh [active response](https://documentation.wazuh.com/current/user-manual/capabilities/active-response/index.html) script. Do this in the Wazuh server `/var/ossec/etc/rules/local_rules.xml` custom ruleset file:

<group name="attack,">  <rule id="100100" level="10">    <if\_group>web|attack|attacks</if\_group>    <list field="srcip" lookup="address\_match\_key">etc/lists/blacklist-alienvault</list>    <description>IP address found in AlienVault reputation database.</description>  </rule> </group>

Edit the Wazuh server `/var/ossec/etc/ossec.conf` configuration file and add the `etc/lists/blacklist-alienvault` list to the `<ruleset>` section:

<ossec\_config>  <ruleset>    <!-- Default ruleset -->    <decoder\_dir>ruleset/decoders</decoder\_dir>    <rule\_dir>ruleset/rules</rule\_dir>    <rule\_exclude>0215-policy\_rules.xml</rule\_exclude>    <list>etc/lists/audit-keys</list>    <list>etc/lists/amazon/aws-eventnames</list>    <list>etc/lists/security-eventchannel</list>    <list>etc/lists/blacklist-alienvault</list>    <!-- User-defined ruleset -->    <decoder\_dir>etc/decoders</decoder\_dir>    <rule\_dir>etc/rules</rule\_dir>  </ruleset> </ossec\_config>

Add the Active Response block to the Wazuh server `/var/ossec/etc/ossec.conf` file:

**For the Ubuntu endpoint**

The `firewall-drop` command integrates with the Ubuntu local iptables firewall and drops incoming network connection from the attacker endpoint for 60 seconds:

> <ossec\_config>  <active-response>    <command>firewall-drop</command>    <location>local</location>    <rules\_id>100100</rules\_id>    <timeout>60</timeout>  </active-response> </ossec\_config>

**For the Windows endpoint**

The active response script uses the `netsh` command to block the attacker's IP address on the Windows endpoint. It runs for 60 seconds:

> <ossec\_config>  <active-response>    <command>netsh</command>    <location>local</location>    <rules\_id>100100</rules\_id>    <timeout>60</timeout>  </active-response> </ossec\_config>

Restart the Wazuh manager to apply the changes:

$ sudo systemctl restart wazuh-manager

## **Attack emulation**[**Permalink to this headline**](https://documentation.wazuh.com/current/proof-of-concept-guide/block-malicious-actor-ip-reputation.html#attack-emulation)

Access any of the web servers from the RHEL endpoint using the corresponding IP address. Replace `<WEBSERVER_IP>` with the appropriate value and execute the following command from the attacker endpoint:

$ curl http://<WEBSERVER\_IP>

The attacker endpoint connects to the victim's web servers the first time. After the first connection, the Wazuh Active Response module temporarily blocks any successive connection to the web servers for 60 seconds.

## **Visualize the alerts**[**Permalink to this headline**](https://documentation.wazuh.com/current/proof-of-concept-guide/block-malicious-actor-ip-reputation.html#visualize-the-alerts)

You can visualize the alert data in the Wazuh dashboard. To do this, go to the **Threat Hunting** module and add the filters in the search bar to query the alerts.

Ubuntu - `rule.id:(651 OR 100100)`

![Wazuh alerts showing malicious actor blocking on Ubuntu system](https://documentation.wazuh.com/current/_images/block-malicious-actor-ubuntu-alerts1.png)

Windows - `rule.id:(657 OR 100100)`

![Wazuh alerts showing malicious actor blocking on Windows system](https://documentation.wazuh.com/current/_images/block-malicious-actor-windows-alerts1.png)

[Proof of Concept guide](https://documentation.wazuh.com/current/proof-of-concept-guide/index.html)[File integrity monitoring](https://documentation.wazuh.com/current/proof-of-concept-guide/poc-file-integrity-monitoring.html)

**Explore**

 [Overview](https://wazuh.com/platform/overview/)
 [XDR](https://wazuh.com/platform/xdr/)
 [SIEM](https://wazuh.com/platform/siem/)

**Services**

 [Wazuh Cloud](https://wazuh.com/cloud/)
 [Professional support](https://wazuh.com/services/professional-support/)
 [Consulting services](https://wazuh.com/services/consulting-services/)
 [Training courses](https://wazuh.com/services/training-courses/)

**Company**

 [About us](https://wazuh.com/about-us/)
 [Customers](https://wazuh.com/our-customers/)
 [Partners](https://wazuh.com/partners/)

**Documentation**

 [Quickstart](https://documentation.wazuh.com/current/quickstart.html)
 [Getting started](https://wazuh.com/current/getting-started/index.html)
 [Installation guide](https://wazuh.com/current/installation-guide/index.html)

**Resources**

 [Blog](https://wazuh.com/blog/)
 [Community](https://wazuh.com/community/)

© 2025 Wazuh Inc.

[Legal resources](https://wazuh.com/legal-resources/)

[Contact us](https://wazuh.com/contact-us/)

[+1 (844) 349 2984](tel:+18443492984)

 [X](https://x.com/wazuh)
 [LinkedIn](https://www.linkedin.com/company/wazuh)
 [Reddit](https://www.reddit.com/r/Wazuh/)
 [GitHub](https://github.com/wazuh)
 [Slack](https://wazuh.com/community/join-us-on-slack/)
 [Mailing list](mailto:wazuh+subscribe@googlegroups.com)