#!/bin/bash
set -euxo pipefail

# $1: dst

dst_file="$1/env.txt"

touch "$dst_file"

{
	echo "=== pedax sha ==="
	echo "$GITHUB_SHA"

	echo "=== os image ==="
	# shellcheck disable=SC2154
	echo "$ImageOS"

	echo "=== flutter doctor ==="
	flutter doctor -v
} >>"$dst_file"
