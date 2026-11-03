
#!/usr/bin/env bash

# Passive Subdomain Enumeration Automation
# Usage: ./recon.sh example.com

set -uo pipefail

DOMAIN="${1:-}"

if [[ -z "$DOMAIN" ]]; then
    echo "Usage: $0 example.com"
    exit 1
fi

# Basic domain validation
if [[ ! "$DOMAIN" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "[!] Invalid domain: $DOMAIN"
    exit 1
fi

DOMAIN=$(echo "$DOMAIN" | tr '[:upper:]' '[:lower:]')

BASE="$HOME/recon/$DOMAIN"
PASSIVE="$BASE/passive"
LOGS="$BASE/logs"

mkdir -p "$PASSIVE" "$LOGS"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;96m'
NC='\033[0m'

echo -e "${BLUE}"
echo "=========================================="
echo "       PASSIVE RECON AUTOMATION"
echo "       Target: $DOMAIN"
echo "=========================================="
echo -e "${NC}"

# Required tools
TOOLS=(subfinder assetfinder findomain curl jq python3)

echo -e "${YELLOW}[*] Checking required tools...${NC}"

MISSING=()

for TOOL in "${TOOLS[@]}"; do
    if command -v "$TOOL" >/dev/null 2>&1; then
        echo -e "${GREEN}[+] $TOOL installed${NC}"
    else
        echo -e "${RED}[-] $TOOL missing${NC}"
        MISSING+=("$TOOL")
    fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo -e "${RED}"
    echo "Missing dependencies:"
    printf '%s\n' "${MISSING[@]}"
    echo "Install missing tools before running recon."
    echo -e "${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}[+] All required tools are installed.${NC}"
echo ""

# Enumeration functions

do_subfinder() {
    subfinder -d "$DOMAIN" -all -silent |
    tr '[:upper:]' '[:lower:]' |
    sort -u > "$PASSIVE/subfinder.txt"
}

do_crtsh() {
    curl -fsS "https://crt.sh/?q=%25.${DOMAIN}&output=json" |
    jq -r '.[].name_value' |
    sed 's/\*\.//g' |
    tr '[:upper:]' '[:lower:]' |
    sort -u > "$PASSIVE/crtsh.txt"
}

do_wayback() {
    curl -fsS "https://web.archive.org/cdx/search/cdx?url=*.${DOMAIN}/*&output=json&fl=original&collapse=urlkey" |
    jq -r '.[1:][]?[0]' |
    python3 -c '
import sys
from urllib.parse import urlparse

domains = set()

for line in sys.stdin:
    host = urlparse(line.strip()).hostname
    if host:
        domains.add(host.lower())

for host in sorted(domains):
    print(host)
' > "$PASSIVE/wayback-domains.txt"
}

do_assetfinder() {
    assetfinder --subs-only "$DOMAIN" |
    tr '[:upper:]' '[:lower:]' |
    sort -u > "$PASSIVE/assetfinder.txt"
}

do_findomain() {
    findomain -t "$DOMAIN" -q |
    tr '[:upper:]' '[:lower:]' |
    sort -u > "$PASSIVE/findomain.txt"
}

do_certspotter() {
    curl -fsS "https://api.certspotter.com/v1/issuances?domain=${DOMAIN}&include_subdomains=true&expand=dns_names" |
    jq -r '.[].dns_names[]? | select(startswith("*") | not)' |
    tr '[:upper:]' '[:lower:]' |
    sort -u > "$PASSIVE/certspotter.txt"
}

# Run each tool with progress display

run_step() {
    NAME="$1"
    FUNC="$2"
    OUTPUT="$3"

    echo -e "${BLUE}[*] Running $NAME...${NC}"

    if "$FUNC" 2> "$LOGS/$NAME.log"; then
        COUNT=$(wc -l < "$PASSIVE/$OUTPUT")
        echo -e "${GREEN}[+] $NAME completed - $COUNT results${NC}"
    else
        echo -e "${RED}[-] $NAME failed. Check $LOGS/$NAME.log${NC}"
        : > "$PASSIVE/$OUTPUT"
    fi

    echo ""
}

# Start enumeration

run_step "subfinder" do_subfinder "subfinder.txt"
run_step "crtsh" do_crtsh "crtsh.txt"
run_step "wayback" do_wayback "wayback-domains.txt"
run_step "assetfinder" do_assetfinder "assetfinder.txt"
run_step "findomain" do_findomain "findomain.txt"
run_step "certspotter" do_certspotter "certspotter.txt"

# Merge all results

echo -e "${YELLOW}[*] Merging all results...${NC}"

cat \
    "$PASSIVE/subfinder.txt" \
    "$PASSIVE/crtsh.txt" \
    "$PASSIVE/wayback-domains.txt" \
    "$PASSIVE/assetfinder.txt" \
    "$PASSIVE/findomain.txt" \
    "$PASSIVE/certspotter.txt" |
    tr '[:upper:]' '[:lower:]' |
    sed 's/\*\.//g' |
    sort -u > "$BASE/final-domains.txt"

# Summary

TOTAL=$(wc -l < "$BASE/final-domains.txt")

echo ""
echo -e "${GREEN}"
echo "=========================================="
echo "          RECON COMPLETED!"
echo "=========================================="
echo -e "${NC}"

echo "Target       : $DOMAIN"
echo "Total domains: $TOTAL"
echo "Output       : $BASE/final-domains.txt"
echo "Passive data : $PASSIVE"
echo "Logs         : $LOGS"

echo ""
echo -e "${GREEN}[+] Final unique domains saved successfully.${NC}"
