#!/bin/bash

flutter config --enable-linux-desktop
sudo apt-get update -y
sudo apt-get install -y libgtk-3-dev libx11-dev pkg-config cmake ninja-build libblkid-dev liblzma-dev
