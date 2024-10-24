import os

BW_VERSION = '2024.10.0'
BW_THINKCENTER_ITEM_ID_VAR_KEY = 'BW_THINKCENTER_ITEM'
BW_PASSWORD_GITLAB_VAR_KEY = 'BITWARDEN_PASSWORD'

REQUIRED_PACKAGES = ['openssh-server', 'ansible', 'sshpass']

RC_FILES = [os.path.expanduser('~/.zshrc'), os.path.expanduser('~/.bashrc')]

RSA_KEY_PATH = os.path.expanduser('~/.ssh/id_rsa')
KNOWN_HOSTS_PATH = os.path.expanduser('~/.ssh/known_hosts')

TEST_INVENTORY = ['172.10.1.10', '172.10.1.20', '172.10.1.30']
PROD_INVENTORY = [
    {'host': 'localhost', 'user_env_name': 'TP_USER', 'pass_env_name': 'TP_PASSWORD'},
    {'host': '192.168.1.161', 'user_env_name': 'EB_USER', 'pass_env_name': 'EB_PASSWORD'},
    {'host': '192.168.122.10', 'user_env_name': 'PI_USER', 'pass_env_name': 'PI_PASSWORD'},
    {'host': '192.168.122.121', 'user_env_name': 'SVR_USER', 'pass_env_name': 'SVR_PASSWORD'},
]

GITLAB_PAT = os.getenv('GITLAB_PAT')
GITLAB_PID = '40235593'

def get_gitlab_pat():
    
    return os.getenv('GITLAB_PAT')