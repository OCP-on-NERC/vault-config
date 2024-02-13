#!/bin/sh

fakedata=$(mktemp -d fakedataXXXXXX)
trap 'rm -rf $fakedata' EXIT

set -eu

# This is a bit of hack to locate all the paths required by "importstr"
# statements and then create corresponding empty files in the
# fakedata directory.
find config -type f -print0 |
	xargs -0 grep importstr |
	grep -E 'tokens|secrets' |
	cut -f2 -d'"' |
	xargs -IPATH sh -c 'mkdir -p "$1/${2%/*}"; touch "$1/$2"' -- "$fakedata" PATH

python apply_vault_config.py -l -d "$fakedata" > /dev/null
