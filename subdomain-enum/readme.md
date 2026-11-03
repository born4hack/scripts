
# Automated Passive Subdomain Enumeration

## Overview

Developed a Bash-based automation script to streamline passive subdomain enumeration for authorized security assessments.

The script automates six different enumeration tools and data sources, collects discovered subdomains, removes duplicate entries, and generates a consolidated list of unique domains.

The objective is to make passive reconnaissance faster, repeatable, and easier to manage without manually executing individual commands.

## Tools & Technologies

| Tool | Purpose |
|---|---|
| Subfinder | Passive subdomain discovery |
| crt.sh | Certificate Transparency log searches |
| Wayback Machine | Extracting hostnames from archived URLs |
| Assetfinder | Discovering related subdomains |
| Findomain | Subdomain enumeration |
| CertSpotter | Certificate issuance and DNS name discovery |
| curl | Fetching data from external sources |
| jq | Processing JSON responses |
| Python3 | Extracting hostnames from archived URLs |
| Bash | Automation and workflow management |

## Features

- Accepts a target domain as a command-line argument.
- Automatically checks whether required dependencies are installed.
- Executes six passive enumeration sources.
- Displays real-time progress and execution status in the terminal.
- Saves individual tool outputs separately.
- Maintains execution logs for troubleshooting.
- Converts domain entries to lowercase.
- Removes wildcard prefixes.
- Merges all collected results.
- Sorts results and eliminates duplicate entries.
- Generates a consolidated `final-domains.txt` file.

## Installation

Update system packages:

```bash
sudo apt update
```

Install required dependencies:

```bash
sudo apt install -y curl wget jq   git python3 python3-pip golang-go  findomain assetfinder 
```

Install Subfinder:

```bash
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
```



Add Go binaries to PATH:

```bash
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
source ~/.bashrc
```

## Usage

Make the script executable:

```bash
chmod +x recon.sh
```

Run the script by providing a target domain:

```bash
./recon.sh example.com
```

The script automatically checks dependencies, executes all six enumeration sources, and generates the final consolidated output.

## Enumeration Sources

| # | Source | Description |
|---|---|---|
| 1 | Subfinder | Discovers subdomains using passive sources. |
| 2 | crt.sh | Retrieves domain names from Certificate Transparency logs. |
| 3 | Wayback Machine | Extracts hostnames from archived URLs. |
| 4 | Assetfinder | Discovers related subdomains. |
| 5 | Findomain | Performs subdomain enumeration. |
| 6 | CertSpotter | Retrieves DNS names from certificate issuance records. |

## Sample Execution

```text
==========================================
       PASSIVE RECON AUTOMATION
       Target: example.com
==========================================

[*] Checking required tools...
[+] subfinder installed
[+] assetfinder installed
[+] findomain installed
[+] curl installed
[+] jq installed
[+] python3 installed

[+] All required tools are installed.

[*] Running subfinder...
[+] subfinder completed

[*] Running crtsh...
[+] crtsh completed

[*] Running wayback...
[+] wayback completed

[*] Running assetfinder...
[+] assetfinder completed

[*] Running findomain...
[+] findomain completed

[*] Running certspotter...
[+] certspotter completed

[*] Merging all results...

==========================================
          RECON COMPLETED!
==========================================

Target       : example.com
Total domains: [Unique Results]
Output       : ~/recon/example.com/final-domains.txt

[+] Final unique domains saved successfully.
```

## Output Structure

```text
recon/
├── recon.sh
│
└── example.com/
    ├── passive/
    │   ├── subfinder.txt
    │   ├── crtsh.txt
    │   ├── wayback-domains.txt
    │   ├── assetfinder.txt
    │   ├── findomain.txt
    │   └── certspotter.txt
    │
    ├── metadata/
    ├── results/
    ├── logs/
    │
    └── final-domains.txt
```

## Final Output

All discovered entries are merged, normalized, sorted, and deduplicated into:

```text
~/recon/example.com/final-domains.txt
```

View the final results:

```bash
cat ~/recon/example.com/final-domains.txt
```

Count unique entries:

```bash
wc -l ~/recon/example.com/final-domains.txt
```

## Workflow

1. Provide the target domain.
2. Verify required dependencies.
3. Execute all six passive enumeration sources.
4. Collect individual tool outputs.
5. Normalize and merge collected results.
6. Remove duplicate entries.
7. Generate the final consolidated domain list.

## Future Improvements

- HTTP/HTTPS live host validation using httpx.
- Automated technology fingerprinting.
- Subdomain scope filtering.
- Screenshot collection for discovered web applications.
- Port and service discovery.
- Integration with vulnerability assessment workflows.
- HTML reconnaissance report generation.

## Disclaimer

This project is intended for authorized security testing and passive reconnaissance only. Always ensure that target domains and subsequent testing activities are within the permitted assessment scope.

---

**Project Type:** Passive Reconnaissance Automation  
**Language:** Bash, Python3  
**Environment:** Kali Linux  
**Output:** Consolidated Unique Subdomain List



<img width="747" height="862" alt="image" src="https://github.com/user-attachments/assets/0e77163c-453f-4f55-bf92-f1e5de9c38b3" />
