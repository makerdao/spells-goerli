#! /usr/bin/env bash

set -e

function message() {
    echo
    echo -----------------------------------
    echo "$@"
    echo -----------------------------------
    echo
}

message BUILDING DOCKER IMAGE
docker build -t makerdao/spells-kovan-test .

message RUNNING TESTS
docker run --rm -it -e ETH_RPC_URL=$ETH_RPC_URL makerdao/spells-kovan-test

