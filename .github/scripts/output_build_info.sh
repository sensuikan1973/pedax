#!/bin/bash
set -euxo pipefail

# $1: dst

dst_file="$1/env.txt"

touch $dst_file

echo "=== pedax sha ===" >> $dst_file
echo $GITHUB_SHA >> $dst_file

echo "=== os image ===" >> $dst_file
echo $ImageOS >> $dst_file

echo "=== flutter doctor ===" >> $dst_file
flutter doctor -v >> $dst_file
