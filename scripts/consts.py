import os

BW_VERSION = '2024.10.0'

GITLAB_PAT = os.getenv('GITLAB_PAT')
GITLAB_PID = '40235593'

REQUIRED_PACKAGES = ['openssh-server', 'ansible', 'sshpass']

KNOWN_HOSTS_PATH = os.path.expanduser('~/.ssh/known_hosts')

PROD_INVENTORY = [
    { 'name': 'ubuntu_thinkpad', 'ip': '192.168.1.10', 'bw_item_id_gitlab_var_key': 'TP_HOST_BW_ID' },
    { 'name': 'debian_thinkcenter', 'ip': '192.168.1.20', 'bw_item_id_gitlab_var_key': 'TC_HOST_BW_ID' }, 
    { 'name': 'raspberry_pi_1', 'ip': '192.168.1.30', 'bw_item_id_gitlab_var_key': 'RPI_BW_ID' }
]

RC_FILES = [os.path.expanduser('~/.zshrc'), os.path.expanduser('~/.bashrc')]

RSA_KEY_PATH = os.path.expanduser('~/.ssh/id_rsa')

TEST_INVENTORY = [
    {'name': 'ubuntu_thinkpad', 'ip': '172.10.1.10', 'username': 'test', 'password': 'test'},
    {'name': 'debian_thinkcenter', 'ip': '172.10.1.20', 'username': 'test', 'password': 'test'}, 
    {'name': 'raspberry_pi_1', 'ip': '172.10.1.30', 'username': 'test', 'password': 'test'}
]