#!/bin/bash
cd macos || exit
pod install

git diff --exit-code
