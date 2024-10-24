import subprocess
import os
import getpass
import json
import shutil

def setup_controller():
    install_packages()
    generate_ssh_key()

    user = input("Enter username for localhost: ")
    password = getpass.getpass(prompt=f"Enter password for {user}@localhost: ")
    
    if ssh_copy_id('localhost', user, password):
        os.environ['TP_USER'] = user
        os.environ['TP_PASSWORD'] = password
        print(f"Exported environment variables for ansible controller")
        # Setup localhost :
        subprocess.run(['ansible-playbook', '-i', 'inventories/local/inventory.yml', '-l', 'debian_workstations', 'playbooks/main.yml'], check=True)
        # Create testing stack :
        subprocess.run(['docker-compose', 'up', '-d'], check=True)

def setup_hosts(inventory, inventory_type = 'test'):
    if isinstance(inventory[0], str):
        for host in inventory:
            if ssh_copy_id(host, 'test', 'test'):
                pass

    elif isinstance(inventory[0], dict):
        for host in inventory:
            user = input(f"Enter username for {host['host']}: ")
            password = getpass.getpass(prompt=f"Enter password for {user}@{host['host']}: ")
            
            if ssh_copy_id(host['host'], user, password):
                export_var(host['user_env_name'], user)
                export_var(host['pass_env_name'], password)
                print(f"Exported environment variables: {host['user_env_name']} and {host['pass_env_name']}")

if __name__ == "__main__":
    
    inventory = [
        {'host': 'localhost', 'user_env_name': 'TP_USER', 'pass_env_name': 'TP_PASSWORD'},
        {'host': '192.168.1.161', 'user_env_name': 'EB_USER', 'pass_env_name': 'EB_PASSWORD'},
        {'host': '192.168.122.10', 'user_env_name': 'PI_USER', 'pass_env_name': 'PI_PASSWORD'},
        {'host': '192.168.122.121', 'user_env_name': 'SVR_USER', 'pass_env_name': 'SVR_PASSWORD'},
    ]

    # install_packages()
    #set_bitwarden_session()
    username = get_bw_secret_by_id('username', '5f298ff0-2430-49b4-889b-b1de00f2407d')
    print(username)

    #setup_controller()

    #setup_hosts(test_inventory)
    # setup_hosts(inventory)
