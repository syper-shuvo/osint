#!/bin/bash

API_KEY="API_KEY_HERE"
LIMIT=40
CURSOR=""

# Get domain from argument or prompt
if [ -n "$1" ]; then
    DOMAIN="$1"
else
    read -p "Enter target domain (e.g., dyson.com): " DOMAIN
fi

OUTPUT="virus"
echo "[*] Fetching subdomains for: $DOMAIN"
echo -n "" > "$OUTPUT"

while true; do
    if [ -z "$CURSOR" ]; then
        URL="https://www.virustotal.com/api/v3/domains/$DOMAIN/subdomains?limit=$LIMIT"
    else
        URL="https://www.virustotal.com/api/v3/domains/$DOMAIN/subdomains?limit=$LIMIT&cursor=$CURSOR"
    fi

    echo "[*] Querying: $URL"
    RESPONSE=$(curl -s --request GET --url "$URL" --header "x-apikey: $API_KEY")

    echo "$RESPONSE" | jq -r '.data[].id' >> "$OUTPUT"

    CURSOR=$(echo "$RESPONSE" | jq -r '.meta.cursor // empty')
    if [ -z "$CURSOR" ]; then
        echo "[✓] Done. Results saved to: $OUTPUT"
        break
    fi

    sleep 1
done
