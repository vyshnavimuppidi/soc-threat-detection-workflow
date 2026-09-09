# 📘 SOC Standard Operating Procedure (SOP): Investigation, Analysis & Incident Closure

> **Document ID:** SOP-SOC-004  
> **Author:** Vyshnavi Muppidi (Lead SOC Analyst)  
> **Target Audience:** Tier-1/2 SOC Analysts, Incident Responders, Security Automation Engineers  
> **Purpose:** Standardized investigation playbook and video walkthrough guide for analyzing and closing security incidents using the Wazuh SIEM + n8n SOAR pipeline.

---

## 🧭 Investigation & Incident Closure Lifecycle

![SOC Investigation Lifecycle](assets/soc-investigation-lifecycle.svg)

This pipeline standardizes a **6-stage investigation cycle**:

```text
[ Stage 1: Alert Intake ] ➔ [ Stage 2: SIEM Telemetry ] ➔ [ Stage 3: Threat Intel ] 
                                                                    │
[ Stage 6: Incident Closure ] 🠤 [ Stage 5: AI Synthesis ] 🠤 [ Stage 4: Containment ]
```

---

## 🎬 Video Walkthrough & Investigation Guide (Script for Your Demo)

If you are recording a demo video for YouTube, LinkedIn, or an interview portfolio, use this section as your **exact screen-by-screen script**!

### ⏱️ Video Outline (Total Time: ~3 to 5 Minutes)

| Timestamp | Screen to Show | What You Do & Say |
|---|---|---|
| **0:00 - 0:45** | **Architecture & n8n Canvas** | Introduce the problem: alert fatigue, manual pivoting. Introduce the 10-node SOAR workflow. |
| **0:45 - 1:30** | **Terminal / Alert Trigger** | Execute `.\samples\trigger-test-alert.ps1`. Show the JSON payload representing Wazuh Rule 87105 (C2 communication). |
| **1:30 - 2:30** | **n8n Live Canvas Execution** | Show the green execution pulses across nodes: Normalization ➔ Regex IOC filter ➔ SIEM Ingestion ➔ Ollama AI prompt. |
| **2:30 - 3:45** | **Analyst Investigation Deep-Dive** | Show the Analyst Template and explain how an analyst investigates in Wazuh SIEM, logs findings, and executes containment. |
| **3:45 - 4:45** | **Mailpit / HTML Report** | Open `http://localhost:8025` in browser. Showcase the color-coded executive HTML report delivered via SMTP. |
| **4:45 - 5:00** | **Closure & Takeaway** | Explain MTTR reduction (15 mins down to 30 secs) and sign off. |

---

## 🔍 Detailed Step-by-Step Investigation Walkthrough

### 📍 Step 1: Alert Ingestion & Severity Classification
* **Trigger:** Wazuh Manager detects an endpoint event exceeding Rule Level 4 (in this demo: Rule `87105`, Level 12 — Critical).
* **Automated Action:** Webhook receives the JSON payload, normalizes timestamps, agent metadata, MITRE techniques, and maps severity into `critical`.
* **Analyst Action:** Review the intake queue. Note the target agent (`LAPTOP-P3NHGSR9`) and detection timestamp.

---

### 📍 Step 2: SIEM Telemetry & Process Tree Analysis
* **Where to Look:** Wazuh Dashboard (`wazuh#/security-events?search=87105`).
* **What to Inspect:**
  1. **Process Lineage (Parent-Child):** What process initiated the connection?  
     *Finding:* `C:\Windows\Temp\beacon_agent.exe` was launched by `NT AUTHORITY\SYSTEM`.
  2. **Network Socket:** Destination IP `185.220.101.5` over port `443` (TCP).
  3. **File Integrity (Syscheck):** SHA256 hash `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.
* **What to Say in Video:**  
  *"In a manual SOC, I would spend 5 minutes searching through event logs. Here, the automated parser extracts the exact binary path, user token, and network socket instantly."*

---

### 📍 Step 3: Threat Intelligence Verification & IOC Correlation
* **Automated Action:** Node 4 discards private subnets (RFC 1918) and extracts public IOCs:
  - Remote IP: `185.220.101.5`
  - Domain: `malicious-c2-domain.com`
* **Threat Score:** Evaluated in Node 5. The IP matches a known Tor exit node with a **96% Abuse Confidence Score** (28 abuse reports in 24 hours).
* **SIEM Writeback:** Node 6 pushes this reputation back into the Wazuh Indexer (`wazuh-alerts-*`) so other analysts in the SOC can see the enriched event immediately.

---

### 📍 Step 4: Containment & Eradication (Remediation)
![Analyst Investigation Console](assets/analyst-investigation-template.svg)

Once malicious activity is verified, the analyst logs the **Triage Verdict** and triggers containment:

#### 1. Host Isolation (Quarantine)
```powershell
# Automated or manual containment: sever endpoint network access while maintaining Wazuh management tunnel
wazuh-control isolate-host --agent-id 001
```
*Purpose:* Prevents the attacker from pivoting laterally to internal domain controllers or database clusters.

#### 2. Perimeter Egress Firewall Rule
* Block outbound traffic to destination IP `185.220.101.5` at the edge firewall / Palo Alto / Fortinet boundary.

#### 3. Payload Quarantining & Memory Dump
* Terminate process ID `4820` (`beacon_agent.exe`).
* Move binary to secure sandbox (`C:\Quarantine\`) for reverse engineering.
* Revoke compromised `SYSTEM` service tokens.

---

### 📍 Step 5: AI-Assisted Risk Synthesis Review
* Node 8 queries **Ollama (Llama 3.1:8B)** with low temperature (`0.2`).
* The model produces a grounded, objective 3-point briefing:
  - *Bullet 1 (Risk):* Critical C2 beaconing confirmed from temp directory execution.
  - *Bullet 2 (Threat Intel):* High-confidence correlation against known adversary infrastructure.
  - *Bullet 3 (Next Steps):* Host quarantine verified; memory forensics scheduled.
* **Analyst Action:** Verify the AI summary for accuracy. Because Ollama runs strictly on-premise, zero company PII or network IPs are sent to third-party clouds.

---

### 📍 Step 6: Incident Closure & Post-Mortem Rule Tuning

#### Closing the Incident:
1. **Ticket Resolution:** Update the ticketing system (Jira / ServiceNow / TheHive) with:
   - **Verdict:** `True Positive - Confirmed Threat`
   - **Lead Analyst:** `Vyshnavi Muppidi`
   - **Action Taken:** Host isolated, IP blacklisted, malicious process terminated.
   - **Time to Respond (MTTR):** `< 45 seconds`.
2. **Post-Mortem & SIEM Rule Tuning:**
   - Add the SHA256 hash to Wazuh rootcheck CDB lists.
   - Create an automated Wazuh active-response rule to kill any process spawned from `C:\Windows\Temp\` attempting outbound external TCP connections.
   - Mark the case as **RESOLVED - THREAT MITIGATED**.

---

## 📤 Video Posting Recommendations (Where to Post & How to Caption)

When your video is recorded, post it to these platforms to maximize visibility for recruiters:

### 1. LinkedIn (Best for Job Inquiries & Recruiter Outreach)
* **Post Title:** 🛡️ Built an Automated SOC Threat Detection & AI Investigation Pipeline with Wazuh & n8n
* **Sample Caption:**
  > *"Excited to share my latest cybersecurity engineering project! 🚀*
  > 
  > *In a modern SOC, analysts face severe alert fatigue manually copying IOCs and pivoting across multiple tools. To solve this, I designed an automated SOAR pipeline integrating **Wazuh SIEM**, **n8n**, and an on-premise **Llama 3.1** model via **Ollama**.*
  > 
  > *Key Highlights:*
  > *✅ Real-time webhook ingestion of Wazuh Sysmon alerts*
  > *✅ Automated IOC extraction with RFC 1918 private IP filtering*
  > *✅ Threat intelligence enrichment ingested back into Wazuh Indexer*
  > *✅ Zero-data-leakage local AI executive synthesis*
  > *✅ Human-in-the-loop analyst triage & automated HTML incident reporting*
  > 
  > *Check out the complete architecture and code on my GitHub:*
  > *👉 https://github.com/vyshnavimuppidi/soc-threat-detection-workflow*
  > 
  > *#CyberSecurity #SOC #ThreatHunting #SIEM #Wazuh #SOAR #IncidentResponse #Infosec"*

### 2. YouTube / Loom (For Video Walkthroughs)
* Upload your 3–5 minute video recording with the title:  
  **`Wazuh SIEM + n8n SOAR: Automated Threat Detection, IOC Enrichment & AI Analysis Pipeline`**
* Link your GitHub repository in the video description.

### 3. GitHub Readme Embed
* Add the video link or GIF directly into the top of your `README.md`!
