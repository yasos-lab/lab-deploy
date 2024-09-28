import os

BW_BINARY = '/opt/bitwarden/bw'
BW_EMAIL_GITLAB_VAR_KEY = 'BITWARDEN_EMAIL'
BW_PASSWORD_GITLAB_VAR_KEY = 'BITWARDEN_PASSWORD'

CLOUD_PROVIDERS = [
    {
        'provider': 'mega', 
        'label': 'Mega',
        'gitlab_var_key_bw_id': 'MEGA_BW_ID'
    },
    {
        'provider': 'drive',
        'label': 'G-Drive',
        'gitlab_var_key_bw_id': 'GGL_BW_ID'
    },
    {
        'provider': 'onedrive',
        'label': '1-Drive',
        'gitlab_var_key_bw_id': 'MSFT_BW_ID'
    },
    {
        'provider': 'dropbox', 
        'label': 'Dropbox', 
        'gitlab_var_key_bw_id': 'DROPBOX_BW_ID'
    }
]

CONFIG_FILES = ['.secrets', '.vimrc', '.zshrc', '.zsh/.p10k.zsh']

GITLAB_PAT = os.getenv('GITLAB_PAT')
GITLAB_PID = '40235593'

HOME_DIR = os.path.expanduser('~')

MEGA_BW_ID = 'MEGA_BW_ID'

ZSH_DIR = os.path.join(HOME_DIR, ".zsh")
ZSH_COMPONENTS = [
    {
        'directory': os.path.join(ZSH_DIR, 'powerlevel10k'),
        'repository_url': "https://github.com/romkatv/powerlevel10k.git"
    },
    {
        'directory': os.path.join(ZSH_DIR, 'powerlevel10k'),
        'repository_url': "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    },
    {
        'directory': os.path.join(ZSH_DIR, 'powerlevel10k'),
        'repository_url': "https://github.com/zsh-users/zsh-autosuggestions"
    }
    
]
