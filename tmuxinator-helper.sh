#!/usr/bin/env bash

# Expects tmux and tmuxinator to be 
# already installed and in system path

# Config folder
mkdir -p ~/.config/tmuxinator-helper/
mkdir -p ~/.config/tmuxinator-helper/templates/

# Modes Commands
modes_new='--new'
modes_edit='--edit'
modes_delete='--delete'

# Templates Commands


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

SESSION='-close-'

while echo $SESSION | grep '-close-'
do

	# In edit mode
	if [[ "$1" == "--edit" ]]; then
		# Getting tmuxinator projects 

		SESSION=$(tmuxinator list -n | tail -n +2 | fzf --border --prompt="Project: " -m -1 -q "$2")
		export EDITOR=vim && tmuxinator edit $SESSION
		SESSION=''

	# Add a tmuxinator project template
	elif [[ "$1" == "--new-template" ]]; then
		cp ./$2 ~/.config/tmuxinator-helper/templates/"$3.yml"
		SESSION=''
	
	# Edit template
	elif [[ "$1" == "--edit-template" ]]; then
		vim ~/.config/tmuxinator-helper/templates/"$2.yml"
		SESSION=''

	# Delete template
	elif [[ "$1" == "--delete-template" ]]; then
		rm ~/.config/tmuxinator-helper/templates/"$2.yml"
		SESSION=''

	# Delete project
	elif [[ "$1" == "--delete" ]]; then
		SESSION=$(tmuxinator list -n | tail -n +2 | fzf --border --prompt="Project: ")
		rm ~/.config/tmuxinator/"$SESSION.yml"
		SESSION=''

	# New project
	elif [[ "$1" == "--new" ]];then
		PROJECTNAME="$2"
		TEMPLATE="()"

		if [[ "$3" == "--template" ]]; then
			TEMPLATE="$4"
		fi

		if [[ "$TEMPLATE" == "()" ]]; then
			tmuxinator new $2
		else
			touch ~/.config/tmuxinator/"$2.yml"
			cat ~/.config/tmuxinator-helper/templates/"$4.yml" > ~/.config/tmuxinator/"$2.yml"
			sed -i "s/_projectname/$2/" ~/.config/tmuxinator/"$2.yml"
			pwdesc=$(echo $PWD | sed 's_/_\\/_g')
			sed -i "s/\\/_projectpath/$pwdesc/" ~/.config/tmuxinator/"$2.yml"
		fi
		SESSION=''

	# In standard mode
	else
		# Getting tmuxinator projects and active sessions
		
		SESSION=$( ((tmuxinator list -n| awk '{print substr($1, 0, length($1)-0) " (open)"}')  && tmux ls | grep : | cut -d. -f1 | awk '{print substr($1, 0, length($1)-1) " (close)"}') |
			tail -n +2 |
			fzf --border --prompt="Project: " -m -1 -q "$1")

		# Session closer
		if echo $SESSION | grep '(close)'; then
			CLOSESESSION=(${SESSION// / })
			tmuxinator stop ${CLOSESESSION[0]};
			SESSION='-close-'
		fi

		# Session starter
		if echo $SESSION | grep '(open)'; then
			CLOSESESSION=(${SESSION// / })
			SESSION=''
			tmuxinator start ${CLOSESESSION[0]};
		fi
		# If all sessions are closed then exit loop
		if ! echo $( ((tmuxinator list -n| awk '{print substr($1, 0, length($1)-0) " (open)"}')  && tmux ls | grep : | cut -d. -f1 | awk '{print substr($1, 0, length($1)-1) " (close)"}') |
			tail -n +2 ) | grep '(close)'; then
			SESSION=''
		fi
		
	fi
done
