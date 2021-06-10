#!/usr/bin/env bash

mkdir -p logs

timestamp=$(date "+%Y%m%d-%H%M%S")

/usr/local/bin/bats tests.bats | tee logs/$timestamp.log
