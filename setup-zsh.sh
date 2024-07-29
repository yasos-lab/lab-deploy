#!/bin/bash

# Change the default shell to Zsh
chsh -s $(which zsh)

# Clone the Powerlevel10k repository
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

# Copy .zshrc and .p10k.zsh from the current git repository to the home directory
cp ./Config/.zshrc ~/.zshrc
cp ./Config/.p10k.zsh ~/.p10k.zsh

# Instructions for the user
echo "Zsh, Powerlevel10k, and the Hack Nerd Font have been installed and configured."
echo "Restart your terminal or run 'exec zsh' to start using Zsh with Powerlevel10k."

# Change to Zsh
exec zsh