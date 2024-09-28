import os
import shutil
from utils.shell import run_command
import utils.const as const

# Change the default shell to Zsh
run_command('chsh -s $(which zsh)')

# Create directories if they don't exist
if not os.path.exists(const.ZSH_DIR):
    os.makedirs(const.ZSH_DIR)

# Add plugins and themes
for component in const.ZSH_COMPONENTS:
    if not os.path.isdir(component.get('directory')):
        run_command(f"git clone {component.get('repository_url')} {component.get('directory')}")

### Copying configuration files

for file in const.CONFIG_FILES:
    src = os.path.join('../config', file)
    dest = os.path.join(const.HOME_DIR, file)
    shutil.copyfile(src, dest)

# Instructions for the user
print("Zsh, Powerlevel10k and the plugins have been installed and configured.")

# Change to Zsh
run_command('exec zsh')
