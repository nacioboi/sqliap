#!/bin/bash



# make sure node modules are installed on host system.
# we will copy the node_modules folder to the container.
cd ./http

npm install express mysql2 xterm express-ws node-pty

if [[ "$?" != "0" ]]; then
	echo "Failed to install dependencies"
	exit 1
fi

cd ..



# check if we already have the files.
[[ -f ./node-latest-linux.tar.gz ]] && \
	[[ -f ./make-latesst-linux.tar.gz ]] && \
	[[ -f ./git-latest-linux.tar.gz ]] && \
	exit 0

# make sure no files from a previous run are present.
#rm ./{node,make,git}-latest-linux.tar.gz >/dev/null 2>&1
#rm ./node-latest-{linux-arm64,linux-x64}.tar.gz >/dev/null 2>&1



# prepare for download.
ARCH=$(uname -m)
NODE_VER=$(\
	curl -s https://nodejs.org/dist/latest/ | \
	grep -o 'node-v[0-9]*\.[0-9]*\.[0-9]*' | \
	uniq \
)
MAKE_VER=$(\
	curl -s https://ftp.gnu.org/gnu/make/ | \
	egrep -o 'make-[0-9]+\.[0-9]+(\.[0-9]+)?' | \
	sort -V | \
	tail -1 | \
	grep -o '[0-9].*[0-9]' \
)
GIT_VER=$(\
	curl -s https://mirrors.edge.kernel.org/pub/software/scm/git/ | \
	egrep -o 'git-[0-9]+\.[0-9]+(\.[0-9]+)?' | \
	sort -V | \
	tail -1 | \
	grep -o '[0-9].*[0-9]'\
)

if [[ "$ARCH" == "aarch64" ]]; then
	ARCH="arm64"
fi

echo "ARCH:      [$ARCH]"
echo "NODE_VER:  [$NODE_VER]"
echo "MAKE_VER:  [$MAKE_VER]"
echo "GIT_VER:   [$GIT_VER]"
echo -e "\n"



# get node.
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



# get make...
# git and make are vital utilities for installing any other linux packages.
# since we do not have a package manager, we need to install them manually.
# we run into a problem when building them from source inside the container,
# git needs make to install and make needs git to isntall.
# we face a chicken and egg problem.
if [[ ! -f "make-latest-linux.tar.gz" ]]; then
	wget https://ftp.gnu.org/gnu/make/make-${MAKE_VER}.tar.gz -O make-latest-linux.tar.gz

	# install it.
	tar -xvf make-latest-linux.tar.gz
	cd make-${MAKE_VER}
	mkdir ../make-install-dir
	./configure
	make prefix=../make-install-dir all
	make prefix=../make-install-dir install
	cd ..
fi



# get git...
# git and make are vital utilities for installing any other linux packages.
# since we do not have a package manager, we need to install them manually.
# we run into a problem when building them from source inside the container,
# git needs make to install and make needs git to isntall.
# we face a chicken and egg problem.
if [[ ! -f "git-latest-linux.tar.gz" ]]; then
	wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-${GIT_VER}.tar.gz -O git-latest-linux.tar.gz

	# install it.
	tar -xvf git-latest-linux.tar.gz
	cd git-${GIT_VER}
	mkdir ../git-install-dir
	./configure --prefix=../git-install-dir
	make prefix=../git-install-dir all
	make prefix=../git-install-dir install
	cd ..
fi