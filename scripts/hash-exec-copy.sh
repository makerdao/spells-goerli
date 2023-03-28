#!/usr/bin/env bash

set -e

if [[ -z "$1" ]]; then
echo "Error: Please provide a date in YYYY-MM-DD format as an argument."
exit 1
fi

# Check input date for correct format
if ! [[ $1 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] ; then
    echo 'Invalid date format. Please use yyyy-mm-dd'
    exit 1
fi

# Format input date into GitHub date URL format
DATE=$(date -d "$1" +"%B %d, %Y" | sed -e 's/ /%20/g' -e 's/,/%2C/g')

if [[ -x "$(command -v wget)" ]] && [[ -x "$(command -v curl)" ]]; then
    # Get latest change git commit hash for target exec copy
    commit_hash=$(curl -s "https://api.github.com/repos/makerdao/community/commits?path=governance/votes/Executive%20vote%20-%20$DATE.md&per_page=1" | grep -o -E '"sha": "[^"]+"' | head -n 1 | awk '{print $2}' | sed 's/"//g')
    [[ -z "$commit_hash" ]] && { echo "Error: Executive vote not found"; exit 1; }
    # Hash target exec copy
    exec_hash=$(cast keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/"$commit_hash"/governance/votes/Executive%20vote%20-%20"$DATE".md -q -O - 2>/dev/null)")
else
    echo "Please ensure you have curl and wget installed";
    exit 1;
fi

# Output target exec copy hash
echo "Executive vote - $(date -d "$1" +"%B %d, %Y")
Community repo commit: $commit_hash
Exec copy hash: $exec_hash"
