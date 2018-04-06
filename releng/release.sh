#!/usr/bin/env bash

# file: release.sh
#
# This script is responsible for two things:
#
# 1. Publishing edge artifacts after a successful build
# 2. Publishing "release"
#
set -o nounset
set -o errexit

hash="${1:?commit hash is empty or not set}"
version="${2:-undefined}"

printf "=== Begin: release.sh args dump ===\n"
printf "hash    = '$hash'\n"
printf "version = '$version'\n"
printf "=== End:   release.sh args dump ===\n"

if [[ "${version}" != "undefined" ]]; then
    printf "Start full stable release operations"
fi
