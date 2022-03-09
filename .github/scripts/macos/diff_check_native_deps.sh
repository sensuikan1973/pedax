#!/bin/bash
cd macos
pod install

git diff --exit-code
