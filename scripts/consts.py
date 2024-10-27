import os

BW_VERSION = '2024.10.0'

ENV_FILE = os.path.expanduser('~/.env')

GITLAB_PAT = os.getenv('GITLAB_PAT')
GITLAB_PID = '40235593'

KNOWN_HOSTS_PATH = os.path.expanduser('~/.ssh/known_hosts')

PROD_INVENTORY = [
    { 
        'name': 'ubuntu_thinkpad', 'ip': '192.168.1.10', 'bw_item_id_gitlab_var_key': 'TP_HOST_BW_ID',
        'username_env_var_name': 'TP_LT_USER', 'password_env_var_name': 'TP_LT_PASSWORD', 'is_controller': True
    },
    { 
        'name': 'debian_thinkcenter', 'ip': '192.168.1.20', 'bw_item_id_gitlab_var_key': 'TC_HOST_BW_ID',
        'username_env_var_name': 'TC_SVR_USER', 'password_env_var_name': 'TC_SVR_PASSWORD', 'is_controller': False
    }, 
    { 
        'name': 'raspberry_pi_1', 'ip': '192.168.1.30', 'bw_item_id_gitlab_var_key': 'RPI_BW_ID',
        'username_env_var_name': 'PI_1_USER', 'password_env_var_name': 'PI_1_PASSWORD', 'is_controller': False
    }
]

RC_FILES = [os.path.expanduser('~/.bashrc'), os.path.expanduser('~/.zshrc')]

REQUIRED_PACKAGES = ['openssh-server', 'ansible', 'sshpass']

RSA_KEY_PATH = os.path.expanduser('~/.ssh/id_rsa')

SECRET_FILE = os.path.expanduser('~/.secrets')

TEST_INVENTORY = [
    {'name': 'ubuntu_thinkpad', 'ip': '172.10.1.10', 'username': 'test', 'password': 'test'},
    {'name': 'debian_thinkcenter', 'ip': '172.10.1.20', 'username': 'test', 'password': 'test'}, 
    {'name': 'raspberry_pi_1', 'ip': '172.10.1.30', 'username': 'test', 'password': 'test'}
]