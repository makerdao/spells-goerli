#!/usr/bin/env bash
set -e

[[ "$1" =~ https://raw.githubusercontent.com/makerdao/community/* ]] || { echo "Please provide the correct exec copy link to hash (e.g. https://raw.githubusercontent.com/makerdao/community/...)"; exit 1; }

for ARGUMENT in "$@"
do
    URL=$(echo "$ARGUMENT" | cut -f2 -d=)
done

if [[ -x "$(command -v wget)" ]]; then
    cast keccak -- "$(wget "$URL" -q -O - 2>/dev/null)"
elif [[ -x "$(command -v curl)" ]]; then
    cast keccak -- "$(curl "$URL" -o - 2>/dev/null)"
else
    echo "Please install either wget or curl";
    exit 1;
fi
