#!/bin/bash

# Change the default shell to Zsh
chsh -s $(which zsh)

# Clone the Powerlevel10k repository
if [ ! -d ~/.zsh/powerlevel10k ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/powerlevel10k
fi

### ZSH PLUGINS

# Clone the zsh-syntax-highlighting repository
if [ ! -d ~/.zsh/plugins/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/plugins/zsh-syntax-highlighting
fi

# Clone the zsh-autosuggestions repository
if [ ! -d ~/.zsh/plugins/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
fi

# Copy .env, .vimrc, .zshrc and .p10k.zsh from the current git repository to the home directory
cp ./config/.env ~/.env
cp ./config/.vimrc ~/.vimrc
cp ./config/.zshrc ~/.zshrc
cp ./config/.p10k.zsh ~/.zsh/.p10k.zsh

# Instructions for the user
echo "Zsh, Powerlevel10k and the plugins have been installed and configured."

# Change to Zsh
exec zsh