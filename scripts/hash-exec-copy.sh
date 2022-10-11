#!/usr/bin/env bash
set -e

[[ "$1" =~ https://raw.githubusercontent.com/makerdao/community/* ]] || { echo "Please provide the exec copy link to hash (e.g. url=<https://raw.githubusercontent.com/makerdao/community/...>)"; exit 1; }

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)

    case "$KEY" in
            url)      URL="$VALUE" ;;
            *)        exit 1
    esac
done

if [[ -x "$(command -v wget)" ]]; then
    cast keccak -- "$(wget "$URL" -q -O - 2>/dev/null)"
elif [[ -x "$(command -v curl)" ]]; then
    cast keccak -- "$(curl "$URL" -o - 2>/dev/null)"
else
    echo "Please install either wget or curl";
    exit 1;
fi
