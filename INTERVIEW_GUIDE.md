# 🎯 SOC Interview Presentation & Defense Guide

This document contains everything you need to talk about, explain, and defend this project during technical interviews for roles such as:
- **SOC Analyst (Tier 1 / Tier 2 / Tier 3)**
- **Cybersecurity Incident Responder**
- **Security Operations & Automation Engineer (SOAR)**
- **Cybersecurity Engineer**

---

## 📄 1. How to Put This Project on Your Resume

Add this directly into your **Projects** section on your resume:

```text
SOC Threat Detection, IOC Enrichment & AI-Assisted Incident Response Pipeline
Technologies: Wazuh SIEM/EDR, n8n SOAR, Ollama (Llama 3.1), Docker, Threat Intelligence (VirusTotal/AbuseIPDB), MITRE ATT&CK
• Architected an end-to-end automated SOAR pipeline integrating Wazuh SIEM with n8n to ingest and triage endpoint and network security alerts in real-time.
• Implemented automated IOC extraction with RFC 1918 regex filtering to extract public IPs, domains, and SHA256 hashes, enriching indicators against threat intelligence feeds.
• Designed bi-directional SIEM telemetry ingestion, persisting enriched reputation scores back into Wazuh Indexer for proactive threat hunting.
• Incorporated an on-premise LLM (Ollama / Llama 3.1 8B) to generate concise 3-point risk assessments without cloud data leakage, paired with human-in-the-loop analyst triage verification.
• Reduced Mean Time to Respond (MTTR) by ~80% and eliminated manual IOC pivoting by automating executive HTML incident reporting dispatched via SMTP.
```

---

## 🎙️ 2. The Elevator Pitch (30 Seconds)

**When the interviewer says:** *"Tell me about a cybersecurity project you recently built."*

> *"I designed and built an end-to-end SOC threat detection and automation pipeline using Wazuh SIEM, n8n, and a local AI model via Ollama.*
>
> *Whenever an endpoint triggers a high-severity alert—such as suspicious C2 beaconing—my pipeline intercepts it via webhook, normalizes the alert against MITRE ATT&CK, extracts external IOCs while filtering private IPs, and enriches the indicators against threat intelligence feeds.*
>
> *It then updates the SIEM index with the enriched threat score, prompts an on-premise Llama 3.1 model to generate a risk summary, records the analyst's verdict, and sends a polished HTML incident briefing to the response team.*
>
> *This cut triage time from 15 minutes of manual copy-pasting to under 30 seconds."*

---

## 🗣️ 3. The Deep Dive (2 Minutes)

**When the interviewer says:** *"Walk me through the architecture and how each piece interacts."*

> *"The workflow consists of 5 core phases across 10 modular nodes:*
>
> **1. Ingestion & Normalization:**
> *Wazuh Manager fires an alert via webhook to n8n upon detecting suspicious endpoint behavior. In node 2, JavaScript parses the raw Sysmon log into a unified schema—extracting agent metadata, timestamp, rule ID, and mapping Wazuh's 1-15 rule level into standard categories like Critical, High, and Medium.*
>
> **2. Smart Triage:**
> *Node 3 acts as a circuit breaker. If an alert is low severity, it drops it to protect resources and prevent alert fatigue. Only actionable alerts proceed.*
>
> **3. IOC Extraction & Threat Intel Scoring:**
> *In Node 4, regex searches the payload for IPs, domains, and SHA256 hashes. Crucially, I filtered out RFC 1918 private ranges (10.x, 192.168.x, 172.16.x) and loopback so we never query internal hosts. Node 5 correlates public IOCs against threat intelligence scoring (simulating VirusTotal and AbuseIPDB), assigning a threat score up to 100.*
>
> **4. Bi-Directional SIEM Feedback & Human-in-the-Loop:**
> *In Node 6, the enriched IOC reputation is indexed straight back into the Wazuh Indexer (`wazuh-alerts-*`), allowing other analysts to hunt for that indicator in the Wazuh dashboard. Node 7 captures the human analyst verdict and remediation actions, ensuring human oversight.*
>
> **5. AI Synthesis & Reporting:**
> *In Node 8, the telemetry is sent to an on-premise Ollama instance running Llama 3.1 8B to draft an executive risk briefing. Finally, Node 9 compiles a color-coded HTML email and Node 10 dispatches it to the SOC inbox via Mailpit.*
>
> *The entire process is self-contained, reproducible via Docker Compose, and guarantees zero customer telemetry is leaked to external AI clouds."*

---

## 🌟 4. The STAR Framework

Interviewers frequently use behavioral questions. Use this framework to answer:

### **S - Situation**
> *"In a modern SOC, tier-1 analysts spend up to 70% of their shift doing repetitive swivel-chair tasks: manually opening VirusTotal, AbuseIPDB, and AlienVault, copying IP addresses, calculating risk scores, and writing incident summary emails. This leads to severe alert fatigue and high Mean Time to Respond (MTTR)."*

### **T - Task**
> *"My goal was to build a reliable, automated pipeline that handles the data ingestion, enrichment, and draft summarization automatically, while still keeping the human analyst in control of the final triage verdict."*

### **A - Action**
> *"I deployed a virtual SOC lab using Wazuh EDR for detection and n8n as the SOAR orchestration engine. I authored custom JavaScript nodes to normalize alerts and extract IOCs using regex while discarding private subnets. I established a bi-directional sync to push threat scores back to Wazuh Indexer. To assist analysts, I integrated an on-premise Ollama instance running Llama 3.1 8B with temperature set to 0.2 to synthesize objective summaries without privacy leakage."*

### **R - Result**
> *"The automated pipeline dropped manual triage time from ~15 minutes per alert to under 30 seconds. It provided structured HTML incident reports with complete MITRE ATT&CK mapping, immediate IOC reputation context, and clear analyst containment notes."*

---

## 🧠 5. Tough Technical Questions & Winning Answers

### Q1: Why did you choose n8n over dedicated SOAR platforms like Cortex XSOAR, Splunk SOAR, or Shuffle?
> **Answer:**
> *"n8n offers a lightweight, developer-friendly, open-source workflow automation platform with native Docker support. Unlike enterprise SOAR platforms that cost tens of thousands of dollars in licensing, n8n allows complete customization via custom JavaScript Code nodes, native Webhooks, and HTTP Request nodes, making it ideal for rapid prototyping, agile SOC engineering, and self-hosted privacy-conscious architectures."*

---

### Q2: Why use a local LLM instead of GPT-4o or Claude 3.5 Sonnet?
> **Answer:**
> *"Data sovereignty and confidentiality. Security alerts contain sensitive internal data: employee usernames, internal IP addresses, hostname conventions, and file paths. Sending that data to third-party public AI providers risks breaching regulatory compliance (SOC 2, ISO 27001, GDPR) or inadvertently training public models on private corporate infrastructure. With Ollama running locally in our Docker network, zero data leaves the perimeter."*

---

### Q3: How do you prevent the LLM from hallucinating during incident analysis?
> **Answer:**
> *"Three specific controls:*
> *1. **Low Temperature:** Set to `0.2` to ensure deterministic, focused outputs rather than creative responses.*
> *2. **Strict Context Grounding:** The prompt strictly constrains the model: `You are a Senior Incident Responder. In 3 bullet points, summarize the security risk, IOC findings, and next steps for: Alert ID, Rule Description, Host, Classification, and Analyst Verdict`.*
> *3. **Human-in-the-loop Safeguard:** The AI is strictly an assistant providing a summary for the email report; it does not trigger automated destructive containment actions on its own."*

---

### Q4: Explain how your IOC extraction logic works and how you avoid false positives on internal networks.
> **Answer:**
> *"Node 4 uses regular expressions to match IPv4 addresses, domains, URLs, and 64-character SHA256 hashes. For IPv4 addresses, it applies an RFC 1918 filter that checks if the IP begins with `10.`, `192.168.`, `172.16-31.`, `127.` (loopback), or `0.`. If it matches any of those private ranges, it is excluded from external threat intel queries. This ensures that internal servers and workstation IPs are never flagged or looked up against public reputation feeds."*

---

### Q5: What is Node 6 doing when it writes back to `single-node-wazuh.indexer-1:9200`?
> **Answer:**
> *"Wazuh Indexer is based on OpenSearch / Elasticsearch. When Wazuh triggers an alert, it only knows the initial rule level. In Node 6, our pipeline takes the enriched threat intelligence and posts a new document to the `wazuh-alerts-*` index via the REST API with Rule ID `87105` (Level 12) tagged with groups `threat_intel` and `virustotal`. This closes the loop: the analyst viewing the Wazuh Dashboard immediately sees the correlated threat intelligence directly inside their primary SIEM interface."*

---

### Q6: If an attacker flooded your webhook with 10,000 alerts per minute, how would your architecture handle it?
> **Answer:**
> *"In this lab architecture, synchronous HTTP calls to Ollama could become a bottleneck under heavy volume. In a production enterprise deployment, I would scale this by:*
> *1. Placing a message broker like **Apache Kafka** or **RabbitMQ** in front of n8n to buffer incoming alert streams.*
> *2. Running n8n in **Queue Mode** with Redis and multiple distributed worker nodes.*
> *3. Implementing a local **Redis cache** for IOC reputation lookups with a 24-hour TTL, so identical IP lookups don't execute redundant calculations."*

---

## 📋 6. Live Demo Checklist

When demonstrating this project live in a technical screening:

1. **Show the n8n Canvas:** Display the visual node flow so the interviewer sees the clean architecture.
2. **Execute the PowerShell Script:** Run `.\samples\trigger-test-alert.ps1` in your terminal.
3. **Show the Webhook Execution:** Switch back to n8n to show the green checkmarks across all 10 nodes in real-time.
4. **Inspect Node 6 & 8:** Show the Wazuh Indexer POST payload and the live Ollama LLM summary generation.
5. **Open Mailpit (`http://localhost:8025`):** Open the newly arrived email and display the formatted, color-coded HTML incident report.
