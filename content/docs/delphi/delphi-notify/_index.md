---
title: "Delphi Notify"
weight: 20
---

# Delphi Notify

## In short

Delphi Notify empowers non-technical users to understand, respond to, and take control of their digital security—without fear or confusion.

Delphi Notify is your cybersecurity “first responder”. It's built to help everyday people take action when something suspicious is happening on their devices or networks. Designed for home users, small businesses, and community groups (not just IT pros!), Delphi Notify turns complex security alerts into clear, friendly guidance you can use right away.

## Ready to Try Delphi Notify?
{{% hint info %}}
{{< button href="https://hera.cybermonkey.dev" >}}Sign up{{< /button >}}
{{% /hint %}}

![oh_the_hacks](/images/oh_the_hacks.jpg)

## How Delphi Notify works

- Watches for serious alerts from our Wazuh-based XDR/SIEM platform.
- Explains what happened, what to do, and how to check—all in calm, plain language using the Assessment → Intervention → Evaluation model.
- Sends you notifications (by email and other channels), right when you need them.
- Avoids jargon and panic: Guidance is step-by-step, easy to follow, and designed to build your confidence.
- Integrated with automation: Powered by StackStorm, so alerts are enriched with helpful context and can be connected to automated actions.
- Encourages feedback and improvement: The system can learn from your responses to make future alerts even more helpful.

## Examples

{{< tabs "id" >}}
{{% tab "Example 1: Rootcheck" %}}

## Code Monkey Cybersecurity

#### Delphi Notify Alert • Tuesday, 03 June 2025 04:34 AM AWST

#### Cybersecurity Alert: What Happened, What To Do, and How To Check

#### Wazuh Alert (level 7)

Alices-PC at 2025-06-03T01:32:17.348+0800:

Host-based anomaly detection event (rootcheck)..

**What happened**

Your security system detected something unusual on your computer called a "rootcheck" anomaly, which means it found changes or activities that are different from what it expects. This could be harmless or a sign that a program is behaving differently than normal, but it does not mean there is definitely a problem. Level 7 alerts like this are early warnings to help you stay safe.

**What to do**

First, restart your computer—this helps reset things if something temporary caused the alert. Next, open your antivirus program and run a full scan, as this checks your device for any harmful software. Finally, make sure your operating system and your antivirus are both up to date; look for update or check for updates in your computer’s settings and your antivirus app. If you notice anything strange, like new programs you didn’t install or pop-ups, do not click anything unfamiliar and ask for help from Code Monkey Cybersecurity or your usual IT support.

**How to check**

If the alert does not return and your antivirus shows a green checkmark or says “no threats found” within the next 1–2 days, it’s likely things are fine. You’re taking the right steps—this system is here to catch small problems early and help keep you safe. If anything feels off or you get more alerts, it’s okay to ask for help.

You’re taking the right steps — Delphi Notify helps you stay ahead of problems.

This message was sent automatically by Delphi Notify. If you have questions, reach out to your security team or Code Monkey Cybersecurity.

Need help? If you’re unsure or want more help, reply to this email or contact [main@cybermonkey.net.au](mailto:main@cybermonkey.net.au)

{{% /tab %}}

{{% tab "Example 2: Wrong time" %}}
Code Monkey Cybersecurity
=========================

Delphi Notify Alert • Sunday, 15 June 2025 10:04 AM AWST • Alert ID: 27e31ac3

What happened:
--------------

Your Windows computer ("Bobs-PC") reported a system error about the date and time. The alert says the computer tried to update its clock by a large amount (about 40 hours) using an outside time server (time.windows.com), but it could not do this automatically. This event was seen more than once over the past few days. There are also related errors saying the computer could not get the correct time from its own hardware clock, and that it lost connection to the network or domain. This matters because if your computer’s clock is very wrong, you may have trouble logging in, using secure websites, or syncing files. It can also be a sign of a hardware problem, a network issue, or, in rare cases, tampering. This alert should be checked the same day, especially if you notice problems with logging in, email, or websites. Based on the information, this is likely a technical issue with your device rather than an outside attack, since the time source is a public service and the errors are seen repeatedly on your system. To give you the best advice, I’d want to know: Have you noticed your computer’s time or date being incorrect recently? Are you unable to access the internet or your network? Has your device recently lost power or rebooted unexpectedly?

Further investigation:
----------------------

First, look at the clock on your computer’s desktop. Is the time and date correct? If not, make a note of how wrong it is. Second, check if you have internet access: try opening a website you normally use. Third, see if you can log in with your usual password and access your files and email. If you notice the wrong time, no internet, or login problems, that could mean the issue is serious and needs help right away.

What to do:
-----------

First, make sure your computer’s time is set correctly. On Windows, right-click the time in the bottom right corner of your screen, then choose “Adjust date and time.” Make sure “Set time automatically” and “Set time zone automatically” are both turned ON. Click “Sync now” if there is a button. This will tell your computer to get the correct time from the internet. Second, restart your computer after syncing the time. This can help reset any temporary issues. Third, check your internet connection: unplug your modem/router for 30 seconds, then plug it back in. Wait a minute and then try browsing the web. If you use this computer to connect to a workplace or server, you may need to contact your IT support to check if the device can reach the domain or network as expected. If you are running a website, shared files, or other services, be aware that incorrect system time can cause problems for users trying to connect—this may need more technical review to fully resolve.

How to check:
-------------

You’ll know it worked if, after following these steps, your computer’s clock shows the correct time and date, you can browse the internet, and you can log in and use your files and email normally. Check over the next 2–3 days that the time stays correct and you don’t see similar error messages or login problems. If the time keeps changing, if you can’t get online, or if you see new security warnings, those are signs something is still wrong and you should contact Code Monkey Cybersecurity or another trusted IT helper for further help. Remember, by checking and correcting your system time you are taking the right steps. These kinds of alerts are designed to help you spot and fix small problems before they cause bigger issues.

Agent Details:
--------------

-   Agent Name: Bobs-PC
-   Agent ID: 017
-   IP Address: 192.168.6.173
-   Wazuh Version: Wazuh v4.12.0
-   Status: disconnected
-   Operating System: Microsoft Windows 11 Pro 10.0.26100.4202 ()
-   Registered: 2025-03-07 23:15:20 AWST+0800
-   Last Seen: 2025-06-15 06:33:34 AWST+0800
-   Disconnected: 2025-06-15 06:48:24 AWST+0800
-   Manager: vhost11-centos9-2
-   Groups: default

You’re taking the right steps — Delphi Notify helps you stay ahead of problems. This was sent automatically by Delphi Notify.

Need help? Reply or contact main@cybermonkey.net.au.

{{% /tab %}}

{{% tab "Example 3: Weird Application Crash" %}}

Code Monkey Cybersecurity
=========================

Delphi Notify Alert • Tuesday, 17 June 2025 02:54 PM AWST • Alert ID: ff9920ba

What happened:
--------------

This alert means that the ChatGPT desktop application (ChatGPT.exe) on your Windows 10 computer stopped responding and was automatically closed by Windows around 4:03 PM on June 16, 2025. This kind of error is called an "application hang" and usually means the program froze and couldn’t continue working. This does not automatically mean your computer is under attack or infected—it’s often just a software glitch or conflict. The alert was seen only once, and there are no signs this was caused by an outside system. It looks like a local issue, not a targeted attack. This should be looked at today, but it’s not an emergency unless you see other unusual problems.

Further investigation:
----------------------

First, check if ChatGPT or any other programs are crashing or freezing repeatedly. Open ChatGPT again and see if it works normally. Second, look for other warning messages or errors in the bottom right of your screen (the notification area) or in the Security and Maintenance settings (search for “Security and Maintenance” in the Windows search bar). Third, check if your computer is running unusually slow, if there are new icons or programs you didn’t install, or if strange pop-ups appear—these would suggest a more serious problem. If you only see this one crash and everything else is normal, it’s likely just a single software hiccup.

What to do:
-----------

Restart your computer. This simple step often clears up temporary issues and helps applications work properly again. How: Click the Windows Start button, select the power icon, and choose “Restart.” After your computer restarts, open ChatGPT again to see if it works. If it freezes again, uninstall and reinstall the ChatGPT application: Go to Settings > Apps > Installed apps or Apps & Features, find “ChatGPT” in the list, click it, and choose “Uninstall.” Then, visit the official ChatGPT website and download the latest version to reinstall. This can fix problems caused by a corrupted program file. If you use ChatGPT for important work and it keeps crashing, consider using the web version in your browser as a temporary solution while you troubleshoot.

How to check:
-------------

If this works, ChatGPT should open and run smoothly without freezing. You should not see more pop-up errors about ChatGPT hanging in the next day or two. If ChatGPT (or other programs) keeps crashing, your computer runs very slowly, or you see strange programs or pop-ups you don’t recognize, this could mean a bigger problem—please reach out to Code Monkey Cybersecurity or another trusted IT helper for further support. You are taking the right steps to keep your computer running well, and these alerts are here to help you catch small problems before they become big ones.

Agent Details:
--------------

-   Agent Name: Alices-PC
-   Agent ID: 022
-   IP Address: 192.168.11.20
-   Wazuh Version: Wazuh v4.12.0
-   Status: disconnected
-   Operating System: Microsoft Windows 10 Home 10.0.19045.5965 ()
-   Registered: 2025-03-27 00:22:32 AWST+0800
-   Last Seen: 2025-06-17 11:56:51 AWST+0800
-   Disconnected: 2025-06-17 12:10:14 AWST+0800
-   Manager: vhost11-centos9-2
-   Groups: default

You’re taking the right steps — Delphi Notify helps you stay ahead of problems. This was sent automatically by Delphi Notify.

{{% /tab %}}

{{< /tabs >}}