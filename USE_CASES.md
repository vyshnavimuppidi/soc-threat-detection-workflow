# 🎯 Comprehensive Security Use Cases Matrix

This document outlines all detection, enrichment, and response use cases handled by the **Wazuh SIEM + n8n SOAR Pipeline**.

---

## 📊 Use Case Overview Matrix

| # | Use Case Name | Primary Wazuh Rule & Level | MITRE ATT&CK ID | Key IOCs Extracted | Automated SOAR Action | Analyst Remediation |
|---|---|---|---|---|---|---|
| **UC-1** | **Adversary Command & Control (C2) Beaconing** | Rule `87105` (Level 12 - Critical) | `T1071.001`, `T1090`, `T1573` | Remote IP, C2 Domain, SSL Port | Threat scoring (VirusTotal/AbuseIPDB), index back to Wazuh | Host network isolation, firewall egress blocking |
| **UC-2** | **Malicious Executable Staging in Temp Folder** | Rule `60100` (Level 10 - High) | `T1059`, `T1204.002`, `T1036` | SHA256 Hash, File Path, Child PID | Hash reputation lookup, process lineage extraction | Terminate PID, file sandbox quarantine |
| **UC-3** | **Phishing & Credential Harvesting Domain Access** | Rule `87110` (Level 8 - High) | `T1566.002`, `T1583.001` | FQDN, HTTP URL, DNS query | Domain categorization (URLhaus), abuse history | DNS sinkholing, password reset, proxy URL block |
| **UC-4** | **Brute Force & Credential Stuffing** | Rule `5710` (Level 7 - Medium) | `T1110.001`, `T1078` | Source IP, Failed Username, Auth Protocol | Geolocation check, AbuseIPDB fail count | Temporary IP block, enforce MFA re-authentication |
| **UC-5** | **False Positive Filtering (Scanner / Admin Activity)** | Any Rule with Level 4–15 | N/A | Internal RFC 1918 IPs, Nessus/Qualys User | Identifies benign scanner behavior, suppresses email | Mark `False Positive`, tune Wazuh rule thresholds |

---

## 🔬 Deep-Dive Breakdown of Each Use Case

### 🛡️ UC-1: Command & Control (C2) / Active Beaconing (Primary Demo Case)
* **Threat Scenario:** An endpoint infected with a backdoor or Cobalts Strike beacon attempts periodic outbound communication over HTTPS (Port 443) to an adversary controller.
* **Input Telemetry:**
  ```json
  {
    "rule": { "id": "87105", "level": 12, "description": "Suspicious outbound communication to known C2 server" },
    "agent": { "name": "LAPTOP-P3NHGSR9", "ip": "192.168.1.105" },
    "data": { "dstip": "185.220.101.5", "dstport": "443", "file": "C:\\Windows\\Temp\\beacon_agent.exe" }
  }
  ```
* **Pipeline Execution:**
  1. Extracted external IP `185.220.101.5` (filters local `192.168.1.105`).
  2. Threat scoring assigns **96% Malicious Abuse Confidence** (Tor exit node).
  3. Pushes document to Wazuh Indexer for searchability.
  4. Ollama generates technical containment brief.
* **Analyst Output:**
  - Verdict: `True Positive - Confirmed Threat`
  - Action: Quarantined endpoint `LAPTOP-P3NHGSR9`, updated perimeter firewall blocklist.

---

### 🛡️ UC-2: Suspicious Binary Execution from `%TEMP%` Directory
* **Threat Scenario:** Malware drops an unsigned executable into `C:\Windows\Temp\` or `C:\Users\<user>\AppData\Local\Temp\` and executes it under elevated privileges (`SYSTEM`).
* **Input Telemetry:**
  - Sysmon Event ID 1 (Process Create)
  - Syscheck File Integrity Monitor (FIM) event with `sha256_after`
* **Pipeline Execution:**
  1. Regex parses 64-character SHA256 string: `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.
  2. Correlates with Threat Intel malware hashes.
  3. Formats forensic report with file paths and executing user.
* **Analyst Output:**
  - Process PID terminated; file quarantined for malware reverse engineering.

---

### 🛡️ UC-3: Phishing Link & Credential Harvesting Domain
* **Threat Scenario:** An employee clicks an obfuscated URL in a spear-phishing email leading to `account-verify-portal.net` or `evil-c2.xyz`.
* **Input Telemetry:**
  - Sysmon Event ID 22 (DNSEvent) or Squid/Web Proxy access log.
* **Pipeline Execution:**
  1. Regex extracts domain: `account-verify-portal.net`.
  2. Matches URLhaus / VirusTotal threat feeds for credential harvesting.
  3. Calculates composite threat score of **90/100**.
* **Analyst Output:**
  - Domain sinkholed on internal DNS; user's SSO session revoked; password reset forced.

---

### 🛡️ UC-4: Remote Brute Force & Credential Access
* **Threat Scenario:** External IP attempts 50+ SSH or RDP connection attempts within 60 seconds against a public bastion host.
* **Input Telemetry:**
  - Wazuh Rule `5710` (Multiple authentication failures from single source).
* **Pipeline Execution:**
  1. External source IP extracted; abuse history queried.
  2. Evaluates if fail count exceeds critical threshold.
* **Analyst Output:**
  - IP blocked on edge perimeter; target account locked for 30 minutes.

---

### 🛡️ UC-5: Benign Internal Activity & False Positive Suppression
* **Scenario:** Internal vulnerability scanner (e.g. Tenable/Nessus) performs scheduled port scans triggering hundreds of low/medium alerts.
* **Pipeline Execution:**
  1. Node 4 filters private RFC 1918 IPs (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`).
  2. Checks alert severity (Level < 4 is dropped by Node 3).
  3. No unnecessary external threat intel API calls are consumed.
* **Analyst Output:**
  - Verdict logged as `False Positive - Authorized Vulnerability Scan`.
  - Email banner turns **Green**, preventing SOC panic.

---

## 📦 Complete Output Package: What the Analyst Receives

When an incident completes the pipeline, the following artifacts are generated:

### 1. Indexed Wazuh Document (SIEM Record)
```json
{
  "@timestamp": "2026-09-10T00:15:00.000Z",
  "rule": {
    "id": "87105",
    "level": 12,
    "description": "Enriched Threat Intelligence: IOC Reputation for 87105 (Classification: MALICIOUS)",
    "groups": ["threat_intel", "virustotal", "ioc_reputation"]
  },
  "ioc_reputation": {
    "threat_score": 96,
    "classification": "MALICIOUS",
    "matches": [
      {
        "ioc": "185.220.101.5",
        "type": "IP_ADDRESS",
        "classification": "MALICIOUS (High Confidence)",
        "source": "VirusTotal / AbuseIPDB",
        "abuse_confidence_score": "96%"
      }
    ]
  },
  "original_alert_id": "wazuh-alert-87105-001"
}
```

### 2. Local AI Structured Synthesis (Ollama Llama 3.1)
* High-density 3-bullet technical brief:
  - Security Risk & Rule Context
  - Threat Intelligence Validation
  - Immediate Containment Recommendations

### 3. Styled HTML Incident Report (SMTP / Mailpit)
* **Visual Severity Banner:** Color-coded (`#dc2626` Red for True Positive, `#10b981` Green for False Positive, `#d97706` Amber for Suspicious).
* **Metadata Table:** Rule description, MITRE ATT&CK tags, host IP/agent ID, timestamp.
* **Threat Intel Table:** Tabular listing of each IOC, confidence percentage, and threat categorization.
* **Analyst Audit Trail:** Signed off by lead investigator with exact containment actions executed.
* **SIEM Deep-Link:** Direct URL to pivot into Wazuh events for deep forensics.
