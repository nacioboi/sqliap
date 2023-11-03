#!/bin/bash

# This file is used to get the latest node version from the nodejs.org website

[[ -f ./node-latest-linux.tar.gz ]] && exit 0

ARCH=$(uname -m)
NODE_VER=$(curl -s https://nodejs.org/dist/latest/ | grep -o 'node-v[0-9]*\.[0-9]*\.[0-9]*' | uniq)

if [[ "$ARCH" == "aarch64" ]]; then
	ARCH="arm64"
fi

if [[ "$ARCH" == "arm64" ]]; then
	if [[ ! -f "node-latest-linux-arm64.tar.gz" ]]; then
		wget https://nodejs.org/dist/latest/${NODE_VER}-linux-arm64.tar.gz -O node-latest-linux-arm64.tar.gz
		ln -sf node-latest-linux-arm64.tar.gz node-latest-linux.tar.gz
	fi
elif [[ "$ARCH" == "x86_64" ]]; then
	if [[ ! -f "node-latest-linux-x64.tar.gz" ]]; then
		wget https://nodejs.org/dist/latest/${NODE_VER}-linux-x64.tar.gz -O node-latest-linux-x64.tar.gz
		ln -sf node-latest-linux-x64.tar.gz node-latest-linux.tar.gz
	fi
else
	echo "Unsupported architecture: $ARCH"
	exit 1
fi

cd ./http

npm install express mysql2

if [[ "$?" != "0" ]]; then
	echo "Failed to install dependencies"
	exit 1
fi