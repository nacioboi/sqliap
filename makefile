
all: prep it do

check_sudo:
	@if [ `id -u` -ne 0 ]; then \
		echo "Please run as root" ; \
		exit 1 ; \
	fi

prep:
	./.get-latest-node.sh

it: check_sudo
	sudo docker build -t my-mysql-image .

do: check_sudo
	./.start_container.sh

clean:
	rm node-latest-linux*