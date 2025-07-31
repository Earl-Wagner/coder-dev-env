#!/bin/sh

install_devcontainer_cli() {
    echo "🔧 Configuring npm for user installation..."
    # Set npm prefix to user's home directory to avoid permission issues
    npm config set prefix '~/.npm-global'
    # Add npm global bin to PATH
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc # For bash users
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc # For zsh users (if applicable)
    export PATH="$HOME/.npm-global/bin:$PATH" # Apply to current session

    echo "Installing @devcontainers/cli using npm..."
    npm install -g @devcontainers/cli
}

install_ssh_config() {
	echo "🔑 Installing SSH configuration..."
	rsync -a /mnt/home/coder/.ssh/ ~/.ssh/
	chmod 0700 ~/.ssh
}

install_git_config() {
	echo "📂 Installing Git configuration..."
	if [ -f /mnt/home/coder/git/config ]; then
		rsync -a /mnt/home/coder/git/ ~/.config/git/
	elif [ -d /mnt/home/coder/.gitconfig ]; then
		rsync -a /mnt/home/coder/.gitconfig ~/.gitconfig
	else
		echo "⚠️ Git configuration directory not found."
	fi
}

install_dotfiles() {
	if [ ! -d /mnt/home/coder/.config/coderv2/dotfiles ]; then
		echo "⚠️ Dotfiles directory not found."
		return
	fi

	cd /mnt/home/coder/.config/coderv2/dotfiles || return
	for script in install.sh install bootstrap.sh bootstrap script/bootstrap setup.sh setup script/setup; do
		if [ -x $script ]; then
			echo "📦 Installing dotfiles..."
			./$script || {
				echo "❌ Error running $script. Please check the script for issues."
				return
			}
			echo "✅ Dotfiles installed successfully."
			return
		fi
	done
	echo "⚠️ No install script found in dotfiles directory."
}

personalize() {
	# Allow script to continue as Coder dogfood utilizes a hack to
	# synchronize startup script execution.
	touch /tmp/.coder-startup-script.done

	if [ -x /mnt/home/coder/personalize ]; then
		echo "🎨 Personalizing environment..."
		/mnt/home/coder/personalize
	fi
}

install_devcontainer_cli
install_ssh_config
install_dotfiles
personalize
