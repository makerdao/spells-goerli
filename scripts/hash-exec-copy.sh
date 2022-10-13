#!/usr/bin/env bash
set -e

URL=$(echo "$1" | cut -f2 -d=)

[[ "$URL" == https://raw.githubusercontent.com/makerdao/community/*/governance/votes/*.md ]] || { echo "Please provide the correct exec copy link to hash (e.g. url=https://raw.githubusercontent.com/makerdao/community/<commit>/governance/votes/*.md)"; exit 1; }

if [[ -x "$(command -v wget)" ]]; then
    cast keccak -- "$(wget "$URL" -q -O - 2>/dev/null)"
elif [[ -x "$(command -v curl)" ]]; then
    cast keccak -- "$(curl "$URL" -o - 2>/dev/null)"
else
    echo "Please install either wget or curl";
    exit 1;
fi
