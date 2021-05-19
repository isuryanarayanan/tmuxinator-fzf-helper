#!/usr/bin/env bash


# Checking FZF installation
if [ $(dpkg-query -W -f='${Status}' fzf 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	# Requesting root

	SUDO=''
	if (( $EUID != 0 )); then
			echo "Please run as root"
			SUDO='sudo'
			exit
	fi
	$SUDO apt-get install fzf;
fi

# In edit mode
if [[ "$1" == "--edit" ]]; then
	# Getting tmuxinator projects 

	SESSION=$(tmuxinator list -n | tail -n +2 | fzf --border --prompt="Project: " -m -1 -q "$2")
	export EDITOR=vim && tmuxinator edit $SESSION

# In standard mode
else
	# Getting tmuxinator projects and active sessions
	
	SESSION=$( ((tmuxinator list -n| awk '{print substr($1, 0, length($1)-0) " (open)"}')  && tmux ls | grep : | cut -d. -f1 | awk '{print substr($1, 0, length($1)-1) " (close)"}') |
		tail -n +2 |
		fzf --border --prompt="Project: " -m -1 -q "$1")

	# Session closer
	if echo "$SESSION" | grep '(close)'; then
		CLOSESESSION=(${SESSION// / })
		tmuxinator stop ${CLOSESESSION[0]};
	fi

	# Session starter
	if echo "$SESSION" | grep '(open)'; then
		CLOSESESSION=(${SESSION// / })
		tmuxinator start ${CLOSESESSION[0]};
	fi

fi
