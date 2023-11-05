
all: prep it do

check_sudo:
	@if [ `id -u` -ne 0 ]; then \
		echo "Please run as root" ; \
		exit 1 ; \
	fi

prep:
	./.prep.sh

it: check_sudo
	sudo docker build -t mysqldi .
	sudo rm make-copy

do: check_sudo
	./.container_wrapper.sh

clean:
	rm node-latest-linux*