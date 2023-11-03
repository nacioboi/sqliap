#!/bin/bash

bashrc_append() {
	cat << EOF >> /root/.bashrc
	$1
EOF
}

append_to_bashrc_welcome() {
	bashrc_append "echo Welcome :D"
}

append_to_bashrc_functions() {
	bashrc_append "

__animated_icon_pos=1
__animated_icons=(\"⠋\" \"⠙\" \"⠹\" \"⠸\" \"⠼\" \"⠴\" \"⠦\" \"⠧\" \"⠇\" \"⠏\")
__animate_icon() {
	echo -e \"\${__animated_icons[__animated_icon_pos]} PLEASE WAIT...\"
	__animated_icon_pos=\$(( (__animated_icon_pos + 1) % 10 ))
}

__wait_for_node_installs() {
	prev_ps1=\"\$PS1\"
	PS1=''
	echo -n 'NODE MODULES ARE ABOUT TO INSTALL'
	node_install_output='/usr/var/http/.node_installing_output'
	completed_file='/usr/var/http/.completed_node_installs'
	while ! [[ -f \$completed_file ]]; do
		if [[ -f \$node_install_output ]]; then
			echo -e \"\\x1b[2J\\x1b[3J\x1b[H\"
			__animate_icon
			cat \$node_install_output
		fi
		sleep 0.1
	done
	rm -f \$completed_file
	export PS1=\"\$prev_ps1\"
	export PROMPT_COMMAND=''
	echo 'Thanks for waiting :D'
}

precmd() {
	__wait_for_node_installs
}

export PROMPT_COMMAND=precmd
"
}

append_cd_to_bashrc() {
	echo -e "cd /usr/var/http\n" >> /root/.bashrc
}

init_node_install() {
	echo "Running npm install..."
	npm install express mysql >> /usr/var/http/.node_installing_output 2>&1
	touch /usr/var/http/.completed_node_installs
	echo "DONE"
	echo -n "..."
	sleep 0.75
	echo -e "\\033[2J"
}

start_services() {
	sleep 3
	mysqld >> ../sqld.log 2>&1 &
	sleep 2
	npm start >> ../node.log 2>&1 &
}

check_logs_existence() {
	__check_logs_existance_done=0
	while [[ $__check_logs_existance_done -eq 0 ]]; do
		one=0
		two=0
		[[ -f "../sqld.log" ]] && echo "MySQLd has started successfully..." && one=1
		[[ -f "../node.log" ]] && echo "Node has started successfully..." && two=1
		[[ $one -eq 1 && $two -eq 1 ]] && __check_logs_existance_done=1
		sleep 0.5
	done
}

# Trap to handle cleanup
trap 'echo "Cleaning up..."; rm -f /usr/var/http/.node_installing_output; exit 0' EXIT

append_to_bashrc_welcome
#append_to_bashrc_functions
append_cd_to_bashrc

cd /usr/var/http/myhttp
#init_node_install
start_services
check_logs_existence

sleep 7200 # Keep the container open for 2 hours
