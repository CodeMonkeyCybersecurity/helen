---
title: " Coming Next Month:  Backup for SMEs - Because OneDrive and iCloud Aren't Actually Backups"
date: "2025-07-05"
author: "Henry Oliver"
tags: ["Backup Services", "Data Safety", "Restic", "Memory Safety", "SME Security"]
categories: ["Service Announcement", "Data Safety"]
description: "Launching August 2025: True  backup powered by Restic and built with memory-safe Go. Starting at $5-8 per person per month - because sync isn't backup."
---

![Backup Service Launch](/images/oh_the_hacks_web.jpg)

# **Coming August: Real Backup for Real Businesses** 

## **Because "it's in the cloud" doesn't mean it's safe**

After watching too many WA businesses discover the hard way that **OneDrive and iCloud are sync services, not backup solutions**, we're launching something that actually protects your data. According to [Backblaze's 2024 backup statistics](https://www.backblaze.com/blog/backup-awareness-survey/), 65% of businesses have experienced data loss, yet only 41% perform regular backups.

**Starting August 2025:  backup powered by Restic - from $5-8 per person per month.**

---

## **The Problem: Sync ≠ Backup** 

### **What Happens When You Delete Something by Mistake**

**OneDrive/iCloud logic:**
- You delete a file → It deletes everywhere
- File corrupted by ransomware → Corruption syncs everywhere ([Veeam's 2024 Ransomware Trends Report](https://www.veeam.com/ransomware-trends-report) shows 76% of organizations were targeted by ransomware)
- Accidental bulk deletion → Everything gone on all devices  
- After 93 days → Permanently gone forever ([Microsoft's own documentation](https://support.microsoft.com/en-us/office/restore-deleted-files-or-folders-in-onedrive-949ada80-0026-4db3-a953-c99083e6a84f) confirms this limitation)

**Actual backup logic:**
- You delete a file → Multiple previous versions remain safe
- Ransomware hits → Clean versions available from before infection
- Bulk deletion → Complete restore available from any point in time
- Years later → Still recoverable with proper retention

### **The Statistics That Should Scare You**

**96% of businesses** don't back up their workstations properly ([Carbonite Business Research](https://www.carbonite.com/en/business/resources/data-backup-statistics/)) 
**93% of businesses** that lose data for more than 10 days file for bankruptcy within a year ([DataCore Software](https://www.datacore.com/blog/backup-disaster-recovery-statistics/))
**88% of data loss** is caused by human error (accidental deletion) ([Kroll Ontrack Data Recovery](https://www.krollontrack.com/data-recovery/data-loss-statistics/))
**67% of data loss** comes from hard drive crashes and system failures ([Peerless Research Group](https://www.peerlessresearch.com/research-studies/))
**$2,000+ per hour** - average cost of business downtime from data loss ([Gartner IT Infrastructure](https://www.gartner.com/en/information-technology/glossary/it-infrastructure))

**Australian small businesses are particularly vulnerable:**
**60% fail within three years** - often due to operational disruptions like data loss ([Australian Small Business and Family Enterprise Ombudsman](https://www.asbfeo.gov.au/statistics-small-business))
**40% don't back up their data at all** ([Australian Cyber Security Centre](https://www.cyber.gov.au/acsc/view-all-content/reports/small-and-medium-enterprises-sme-cyber-security-awareness))
**40-50% of existing backups** aren't fully recoverable when needed ([EMC Corp Backup Recovery Study](https://www.emc.com/about/news/press/2014/20140506-01.htm))

---

## **Why OneDrive and iCloud Fail Small Businesses** 

### **1. Sync Services, Not Backup Services**
When you delete a file locally, **it deletes everywhere**. That's sync working as designed - but it's the opposite of what backup should do.

### **2. Limited Retention (93 Days Max)**
Delete something and don't notice for 4 months? **Gone forever.** No  would accept this limitation.

### **3. Ransomware Propagation**
Ransomware encrypts your local files → Encrypted files sync to cloud → **All your "backup" copies are now encrypted too**

### **4. Shared Responsibility Confusion**
Microsoft/Apple handle infrastructure, but **accidental deletion is your responsibility**. They'll reliably delete your data if you tell them to.

### **5. No Point-in-Time Recovery**
Can't restore your database to exactly how it was at 2pm yesterday. You get broad rollbacks that lose other work.

### **6. Compliance Failures**
Doesn't meet **3-2-1 backup standards** recommended by [US Cybersecurity and Infrastructure Security Agency (CISA)](https://www.cisa.gov/news-events/news/data-backup-options)

---

## **Our Solution: Restic-Powered Backup** 

### **Built on Memory-Safe Foundations**

Our backup service is powered by **Restic**, written in **Go** - one of the memory-safe programming languages **recommended by the White House** for critical infrastructure.

**Why this matters:**
**White House cybersecurity guidance** specifically recommends Go alongside C#, Java, Ruby, and Swift ([ONCD Memory Safety Report](https://www.whitehouse.gov/oncd/briefing-room/2024/02/26/press-release-technical-report/))
**Memory-safe languages** prevent many cybersecurity vulnerabilities at the code level ([National Institute of Standards and Technology](https://nvlpubs.nist.gov/nistpubs/ir/2019/NIST.IR.8397.pdf))
**"Since many cybersecurity issues start with a line of code"** - using memory-safe languages means inheriting security automatically ([Microsoft Security Development Lifecycle](https://www.microsoft.com/en-us/securityengineering/sdl/))

### **Restic: The Backup Tool Actually Use**

**Technical Excellence:**
**Fast, secure, efficient** - designed for production environments
**Cross-platform support** - Linux, macOS, Windows, FreeBSD, OpenBSD
**Cryptographic guarantee** of data confidentiality and integrity
**Deduplication and compression** - only store what's actually changed
**Multiple backend support** - local storage, cloud providers, SFTP

**Features:**
**Incremental backups** - only backup changes, not everything
**Point-in-time recovery** - restore to any moment in history
**Verification and integrity testing** - prove your backups actually work
**Retention policies** - keep what you need, delete what you don't
**Cross-cloud replication** - multiple geographic locations

---

## **What We're Launching in August** 

### ** Professional Backup**
**$5 per person per month**

**Perfect for:** Small offices, retail stores, professional practices

**What you get:**
**Daily automated backups** of all work files and folders
**30-day retention** with point-in-time recovery
**Local and cloud storage** (your choice of provider)
**Email alerts** when backups succeed or fail
**Self-service restore** via web interface
**Business hours support** for setup and questions

### ** Custom Solutions**
**Quote on request**

**For businesses with specific needs:**
**Unlimited retention** periods
**Real-time replication** to multiple locations
**Integration with existing systems** and workflows
**24/7 monitoring and support**
**On-premises backup appliances**
**Disaster recovery planning and testing**

---

## **Why This Pricing Makes Sense** 

### **Compare the Real Costs:**

| Scenario | OneDrive/iCloud | Our Backup Service | Actual Data Loss |
|----------|-----------------|-------------------|------------------|
| **Monthly cost** | $6-12/user | $5-8/user | $0 |
| **Accidental deletion after 94 days** |  Gone forever |  Fully recoverable | $2,000+/hour downtime |
| **Ransomware attack** |  All synced copies encrypted |  Clean restore available | $55,000 average loss |
| **Hard drive failure** |  Only recent files safe |  Complete system restore | Weeks of recreation time |
| **Compliance audit** |  Fails 3-2-1 standard |  Full audit trail | Potential fines/penalties |

**The math is simple:** One data loss event costs more than **years** of proper backup service.

---

## **Technical Implementation: Standards** 

### **Memory-Safe Architecture**
**Restic core** written in Go (White House-recommended memory-safe language)
**Prevents buffer overflows** and memory corruption vulnerabilities
**Secure by design** at the programming language level

### **Encryption and Security**
**AES-256 encryption** for all backup data
**Client-side encryption** - we never see your unencrypted data
**Cryptographic verification** of backup integrity
**Secure key management** integrated with our Vault infrastructure

### **Reliability and Performance**
**Incremental backups** - only changed data transferred
**Deduplication** - 50-90% storage savings typical
**Bandwidth throttling** - won't impact business operations
**Automated testing** - regular restore verification
**Multiple storage backends** - local, S3, Azure, Google Cloud

### **Monitoring and Alerting**
**Real-time backup status** via our Delphi platform
**Failed backup alerts** in plain English
**Storage usage monitoring** and forecasting
**Performance metrics** and optimization recommendations

---

## **Migration from Existing "Backup" Solutions** 

### **From OneDrive/iCloud Sync:**
1. **Assessment** - identify what's actually protected vs. just synced
2. **Initial full backup** - capture current state completely
3. **Ongoing protection** - daily incremental backups
4. **Verification** - test restore to prove it works
5. **Training** - show team how real backup/restore works

### **From Other Backup Solutions:**
1. **Compatibility check** - ensure we can read existing backup formats
2. **Migration planning** - minimize disruption to operations
3. **Parallel operation** - run both systems until confidence established
4. **Cut-over** - seamless transition to Restic-based system
5. **Optimization** - tune performance for your specific environment

### **From No Backup (40% of SMEs):**
1. **Immediate protection** - start backing up within 24 hours
2. **Baseline establishment** - capture current critical systems
3. **Expansion** - gradually include more systems and data
4. **Process integration** - make backup part of normal operations
5. **Disaster planning** - develop recovery procedures ([Australian Business Continuity Institute](https://www.businesscontinuity.com.au/resources/business-continuity-planning/))

---

## **Launch Timeline and Early Access** 

### **July 2025: Development Completion**
- Final testing of Restic integration
- Security audits and penetration testing
- Performance optimization and scaling tests
- Documentation and training material completion

### **August 1, 2025: Official Launch**
- General availability for all WA businesses
- Full service offering with support
- Online signup and automated provisioning
- Integration with existing Delphi Notify customers

### **Early Access Program (Starting July 15)**
**Limited to 20 businesses - apply now**

**Benefits:**
**50% discount** for first 3 months
**Direct access** to development team
**Priority feature requests** and customization
**Case study participation** (optional)
**Guaranteed service migration** if you're unsatisfied

---

## **Real-World Scenarios We Prevent** 

### **The Accounting Firm Disaster**
*A Perth accounting firm had their bookkeeper accidentally delete an entire client folder. With OneDrive, the 93-day window had passed. They had to recreate 18 months of financial records manually - 300+ hours of work.*

**With our backup:** Complete restore in 15 minutes to exactly the state before deletion.

### **The Medical Practice Ransomware**
*A Fremantle medical practice got hit with ransomware. All their OneDrive files were encrypted along with local copies. Patient records going back 5 years were inaccessible.*

**With our backup:** Clean restore from before infection, practice back online same day.

### **The Manufacturer's Hard Drive Failure**
*A Joondalup manufacturer lost their main design workstation to hard drive failure. OneDrive only had recent files - 10 years of CAD drawings and specifications were gone.*

**With our backup:** Complete system restore including all historical files and application settings.

---

## **Integration with Our Security Ecosystem** 

### **Works with Delphi Notify**
**Security monitoring** alerts if backup systems are compromised
**Threat correlation** - identify if data loss was malicious
**Incident response** coordination between security and backup teams

### **Leverages Our Infrastructure**
**HashiCorp Vault** for secure key management
**Same monitoring systems** we use for security alerting
**Established support processes** and team expertise
**Geographic distribution** across Australian data centers

### **Complements Our Training**
**Backup procedures** included in security awareness training
**Recovery testing** as part of business continuity planning
**Employee education** on difference between sync and backup
**Incident response** procedures for data loss events

---

## **Getting Ready for Launch** 

### **Early Access Application**
**Available now through July 31st**

 **Email:** [main@cybermonkey.net.au](mailto:main@cybermonkey.net.au?subject=Early%20Access%20Application)
 **Web:** [cybermonkey.net.au/backup](https://cybermonkey.net.au/offerings/delphi/)

**Include in your application:**
Business size and industry
- Current backup solution (if any)
- Critical data types and volumes
- Compliance requirements
- Timeline for implementation

### **Free Backup Assessment**
**Available starting July 15th**

We'll evaluate your current data protection and show you:
**What's actually protected** vs. just synced
**Recovery time estimates** for different scenarios
**Cost comparison** between current solution and ours
**Risk assessment** of current backup gaps
**Implementation timeline** and process

### **Launch Day Pricing**
**August 1st special offers:**

 **First month free** for all new customers  
 **Free migration** from existing backup solutions  
 **Setup included** - we handle the technical implementation  
 **30-day satisfaction guarantee** - full refund if not satisfied  
 **Priority support** for first 90 days

---

## **Why August Is the Right Time** 

### **Financial Year Timing**
**New budget cycles** starting for many Australian businesses
**Tax time focus** on business systems and record keeping
**Insurance renewals** often requiring backup compliance
**Fresh start mentality** after EOFY reviews

### **Threat Landscape Evolution**
**Ransomware attacks** increasing 424% year-over-year ([SonicWall Cyber Threat Report](https://www.sonicwall.com/2024-cyber-threat-report/))
**Supply chain attacks** affecting small business vendors ([ENISA Threat Landscape Report](https://www.enisa.europa.eu/publications/enisa-threat-landscape-2024))
**Regulatory changes** requiring better data protection ([Privacy Act Review Australia](https://www.ag.gov.au/rights-and-protections/privacy/privacy-act-review))
**Insurance requirements** getting stricter on backup compliance ([Insurance Council of Australia](https://insurancecouncil.com.au/issues-submissions/cyber-insurance/))

### **Technology Maturity**
**Restic ecosystem** now production-ready for enterprise use ([GitHub Restic Project](https://github.com/restic/restic))
**Go language adoption** accelerating in critical infrastructure ([Stack Overflow Developer Survey](https://survey.stackoverflow.co/2024/))
**Memory-safe languages** becoming cybersecurity standard ([NIST Cybersecurity Framework](https://www.nist.gov/cyberframework))
**Cloud storage costs** making professional backup affordable ([AWS S3 Pricing Trends](https://aws.amazon.com/s3/pricing/))

---

## **Frequently Asked Questions** 

**Q: How is this different from cloud storage sync?**
A: Sync services like OneDrive replicate deletions and corruption everywhere. True backup preserves multiple versions and protects against all forms of data loss.

**Q: What happens if your service goes down?**
A: Your data is stored in multiple locations with multiple access methods. Even if our service is unavailable, you can still access your backups directly.

**Q: Can I restore individual files or do I need to restore everything?**
A: Individual file restoration down to specific versions and timestamps. You choose exactly what to restore and when.

**Q: How long do you keep our data?**
A: Professional plan: 30 days. Custom plans: as long as you need. You control retention policies.

**Q: What about bandwidth usage?**
A: Initial backup uses more bandwidth, but daily incrementals are typically very small. We offer bandwidth throttling to prevent business impact.

**Q: Do you have access to our data?**
A: No. Client-side encryption means we only see encrypted data. You control the encryption keys through our Vault integration.

---

## **The Bottom Line** 

**Current situation:** 40% of Australian SMEs have no real backup, and another 40-50% have backups that won't work when needed.

**Business impact:** 93% of businesses that lose data for more than 10 days file for bankruptcy within a year.

**Our solution:**  backup starting at $5/month per person - less than a coffee per week to protect your entire business.

**August launch:** Join the early access program or wait for general availability.

**The choice is yours:** Pay a few dollars monthly for protection, or risk losing everything to the next "oops" moment.

---

**Ready to protect your business properly?**

{{% hint info %}}
{{< btn href="mailto:main@cybermonkey.net.au?subject=Early%20Access%20Interest" style="primary" >}}Apply for Early Access{{< /btn >}}
{{% /hint %}}

---

**Contact Information:**
 **Email:** [main@cybermonkey.net.au](mailto:main@cybermonkey.net.au)  
 **Website:** [cybermonkey.net.au](https://cybermonkey.net.au)  
 **Location:** Fremantle, Western Australia 

*Real backup. Memory-safe architecture. SME pricing.*

**Finally, backup that actually backs up.** 

#DataSafety #Restic #MemorySafe #SMEBackup #WAbusiness

---

*Code Monkey Cybersecurity - Making  data protection accessible to every WA business. Based in Fremantle, protecting data across Australia.*