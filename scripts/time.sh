#!/usr/bin/env bash
set -e

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)

    case "$KEY" in
            date)      DATE="$VALUE" ;;
            stamp)     STAMP="$VALUE" ;;
            *)
    esac
done

if [[ -z "$STAMP" && -z "$DATE" ]]; then
    date --utc # return current date in UTC by default
elif [[ -z "$DATE" ]]; then
    date --utc --date=@"$STAMP"
else
    date --date "$DATE" +%s
fi
