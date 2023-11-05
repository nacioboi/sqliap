#!/bin/bash



info() {
	echo -e "\x1b[32m$1\x1b[0m"
}

ninfo() {
	echo -ne "\x1b[32m$1\x1b[0m"
}

loading_dots() {
	for i in {1..3}; do
		echo -ne "."
		sleep 0.2
	done
	for i in {1..3}; do
		echo -ne "."
		sleep 0.1
	done
	for i in {1..2}; do
		echo -ne "."
		sleep 0.025
	done
	for i in {1..2}; do
		echo -ne "."
		sleep 0.001
	done
	echo
}

DID_SUCCEED=0
on_exit() {
	if [[ $DID_SUCCEED -eq 1 ]]; then
		exit 0
	fi
	echo -ne "\n\n\x1b[1;31m[prep.sh] ERROR: Something went wrong. Exiting\x1b[0m" && loading_dots
}

trap on_exit EXIT



info "[prep.sh] NOTE: The node modules are installed on the host system."
info "[prep.sh]     : This is done to avoid installing them every time the container is ran."
ninfo "[prep.sh] Installing node modules" && loading_dots
cd ./http

npm install express mysql2 xterm express-ws node-pty || \
	echo "[prep.sh] Failed to install node modules. Continuing anyway..."


cd ..

ninfo "[prep.sh] Installing node modules: done" && loading_dots




# ensure we have a junk directory.
[[ -d "junk" ]] || mkdir junk



# check if we already have the files.
[[ -f "junk/.node-complete" ]] && \
	[[ -f "junk/.make-complete" ]] && \
	[[ -f "junk/.git-complete" ]] && \
	info "[prep.sh] Nothing more to do. exiting 0..." && \
	exit 0

ninfo "[prep.sh] Running pre-installation cleanup" && loading_dots

if [[ ! -f "junk/.node-complete" ]]; then
	rm junk/node-latest-{linux-arm64,linux-x64}.tar.gz >/dev/null 2>&1
fi

if [[ ! -f "junk/.make-complete" ]]; then
	rm -rf junk/make* >/dev/null 2>&1
fi

if [[ ! -f "junk/.git-complete" ]]; then
	rm -rf junk/git* >/dev/null 2>&1
fi

ninfo "[prep.sh] Pre-installation cleanup: done" && loading_dots



ninfo "[prep.sh] Running pre-installation checks" && loading_dots

ARCH=$(uname -m) || exit 1
NODE_VER=$(\
	curl -s https://nodejs.org/dist/latest/ | \
	grep -o 'node-v[0-9]*\.[0-9]*\.[0-9]*' | \
	uniq \
) || exit 1
MAKE_VER=$(\
	curl -s https://ftp.gnu.org/gnu/make/ | \
	egrep -o 'make-[0-9]+\.[0-9]+(\.[0-9]+)?' | \
	sort -V | \
	tail -1 | \
	grep -o '[0-9].*[0-9]' \
) || exit 1
GIT_VER=$(\
	curl -s https://mirrors.edge.kernel.org/pub/software/scm/git/ | \
	egrep -o 'git-[0-9]+\.[0-9]+(\.[0-9]+)?' | \
	sort -V | \
	tail -1 | \
	grep -o '[0-9].*[0-9]'\
) || exit 1

if [[ "$ARCH" == "aarch64" ]]; then
	ARCH="arm64"
fi

info "[prep.sh] ARCH:      [$ARCH]"
info "[prep.sh] NODE_VER:  [$NODE_VER]"
info "[prep.sh] MAKE_VER:  [$MAKE_VER]"
info "[prep.sh] GIT_VER:   [$GIT_VER]"

ninfo "[prep.sh] Pre-installation checks: done" && loading_dots



if [[ ! -f "junk/.node-complete" ]]; then
	ninfo "[prep.sh] Downloading node" && loading_dots
	
	if [[ "$ARCH" == "arm64" ]]; then
		wget https://nodejs.org/dist/latest/${NODE_VER}-linux-arm64.tar.gz -O junk/node-latest-linux-arm64.tar.gz || exit 1
		mv junk/node-latest-linux-arm64.tar.gz junk/node-latest-linux.tar.gz || exit 1
	elif [[ "$ARCH" == "x86_64" ]]; then
		wget https://nodejs.org/dist/latest/${NODE_VER}-linux-x64.tar.gz -O node-latest-linux-x64.tar.gz || exit 1
		mv node-latest-linux-x64.tar.gz node-latest-linux.tar.gz || exit 1
	else
		echo -e "[prep.sh] \x1b[31mERROR: Unsupported architecture\x1b[0m: [$ARCH]."
		exit 1
	fi

	touch junk/.node-complete

	ninfo "[prep.sh] Downloading node: done" && loading_dots
fi



if [[ ! -f "junk/.make-complete" ]]; then
	info "[prep.sh] NOTE: git and make are vital utilities for installing any other linux packages."
	info "[prep.sh]     : Since, inside the container, we do not have a package manager, we need to install them manually."
	info "[prep.sh]     : We run into a problem when building them from source inside the container,"
	info "[prep.sh]     : git needs make to install and make needs git to isntall."
	info "[prep.sh]     : We face a chicken and egg problem..."
	info "[prep.sh]     : To solve this, we download the source code for make and git on the host system,"
	info "[prep.sh]     : and then copy them into the container."
	ninfo "[prep.sh] Downloading make" && loading_dots
	sleep 2

	wget https://ftp.gnu.org/gnu/make/make-${MAKE_VER}.tar.gz -O junk/make-latest-linux.tar.gz

	# install it.
	cd junk && tar -xvf make-latest-linux.tar.gz && cd .. || exit 1
	mkdir junk/make-install-dir || exit 1
	PREFIX=$(pwd)/junk/make-install-dir || exit 1
	cd junk/make-${MAKE_VER} && ./configure 			&& cd ../.. || exit 1
	cd junk/make-${MAKE_VER} && make prefix=${PREFIX} 		&& cd ../.. || exit 1
	cd junk/make-${MAKE_VER} && make prefix=${PREFIX} install 	&& cd ../.. || exit 1
	rm -rf junk/make-${MAKE_VER} || exit 1

	touch junk/.make-complete

	ninfo "[prep.sh] Downloading make: done" && loading_dots
fi



if [[ ! -f "junk/.git-complete" ]]; then
	info "[prep.sh] NOTE: git and make are vital utilities for installing any other linux packages."
	info "[prep.sh]     : Since, inside the container, we do not have a package manager, we need to install them manually."
	info "[prep.sh]     : We run into a problem when building them from source inside the container,"
	info "[prep.sh]     : git needs make to install and make needs git to isntall."
	info "[prep.sh]     : We face a chicken and egg problem..."
	info "[prep.sh]     : To solve this, we download the source code for make and git on the host system,"
	info "[prep.sh]     : and then copy them into the container."
	ninfo "[prep.sh] Downloading git" && loading_dots

	wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-${GIT_VER}.tar.gz -O junk/git-latest-linux.tar.gz

	# install it.
	cd junk && tar -xvf git-latest-linux.tar.gz && cd .. || exit 1
	mkdir junk/git-install-dir || exit 1
	PREFIX=$(pwd)/junk/git-install-dir || exit 1
	cd junk/git-${GIT_VER} && ./configure 				&& cd ../.. || exit 1
	cd junk/git-${GIT_VER} && make prefix=${PREFIX} all 		&& cd ../.. || exit 1
	cd junk/git-${GIT_VER} && make prefix=${PREFIX} install 	&& cd ../.. || exit 1
	rm -rf junk/git-${GIT_VER}

	touch junk/.git-complete
	
	ninfo "[prep.sh] Downloading git: done" && loading_dots
fi

DID_SUCCEED=1
ninfo "[prep.sh] All done. exiting 0" && loading_dots