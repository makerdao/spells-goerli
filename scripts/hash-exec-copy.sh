#!/usr/bin/env bash
set -e

[[ "$1" =~ https://raw.githubusercontent.com/makerdao/community/* ]] || { echo "Plese provide the exec copy link to hash (e.g. url=<https://raw.githubusercontent.com/makerdao/community/...>)"; exit 1; }

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)

    case "$KEY" in
            url)      URL="$VALUE" ;;
            *)        URL="$KEY" 
    esac
done

if ! [[ -x "$(command -v wget)" ]]; then
    cast keccak -- "$(curl "$URL" -o - 2>/dev/null)"
else   
    cast keccak -- "$(wget "$URL" -q -O - 2>/dev/null)"
fi
