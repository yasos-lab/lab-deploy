import subprocess
import os
import getpass

def install_packages():
    packages = ['openssh-server', 'ansible', 'sshpass']
    
    try:
        with open('/etc/os-release') as f:
            content = f.read()
            if 'ubuntu' in content or 'debian' in content:
                subprocess.run(['sudo', 'apt', 'install', '-y'] + packages, check=True)
            elif 'centos' in content or 'fedora' in content or 'rhel' in content:
                subprocess.run(['sudo', 'dnf', 'install', '-y'] + packages, check=True)
            else:
                print("Unsupported distribution.")
                exit(1)
            
            print("Successfully installed packages.")
    except subprocess.CalledProcessError as e:
        print(f"Error installing packages: {e}")
        exit(1)

def generate_ssh_key():
    key_path = os.path.expanduser('~/.ssh/id_rsa')
    if not os.path.exists(key_path):
        try:
            subprocess.run(['ssh-keygen', '-t', 'rsa', '-b', '2048', '-f', key_path, '-N', ''], check=True)
            print("SSH key generated successfully.")
        except subprocess.CalledProcessError as e:
            print(f"Error generating SSH key: {e}")
            exit(1)
    else:
        print("SSH key already exists. Skipping key generation.")

def ssh_copy_id(host, user, password):
    try:
        subprocess.run(['sshpass', '-p', password, 'ssh-copy-id', '-o', 'StrictHostKeyChecking=no', f'{user}@{host}'], check=True)
        print(f"SSH key copied to {host} successfully.")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error copying SSH key to {host}: {e}")
        return False

def export_var(name, value):
    zshrc_file = os.path.expanduser('~/.zshrc')
    bashrc_file = os.path.expanduser('~/.bashrc')

    export_line = f'export {name}="{value}"'

    # Append to .zshrc if it exists
    if os.path.exists(zshrc_file):
        with open(zshrc_file, 'a') as f:
            f.write('\n'.join(export_line) + '\n')
        print(f"Added environment variables to {zshrc_file}.")

    # Append to .bashrc if it exists
    if os.path.exists(bashrc_file):
        with open(bashrc_file, 'a') as f:
            f.write('\n'.join(export_line) + '\n')
        print(f"Added environment variables to {bashrc_file}.")

    # If neither file exists
    if not os.path.exists(zshrc_file) and not os.path.exists(bashrc_file):
        print("Neither .zshrc nor .bashrc found. Please create one manually.")

def main(inventory):
    install_packages()
    generate_ssh_key()

    if isinstance(inventory[0], str):
        known_hosts_path = os.path.expanduser('~/.ssh/known_hosts')

        for host in inventory:
            if ssh_copy_id(host, 'test', 'test'):
                pass
            else:
                subprocess.run(['ssh-keygen', '-f', known_hosts_path, '-R', f'{host}'], check=True)
                ssh_copy_id(host, 'test', 'test')


    elif isinstance(inventory[0], dict):
        for host in inventory:
            user = input(f"Enter username for {host['host']}: ")
            password = getpass.getpass(prompt=f"Enter password for {host['host']}: ")
            
            if ssh_copy_id(host['host'], user, password):
                export_var(host['user_env_name'], user)
                export_var(host['pass_env_name'], password)
                print(f"Exported environment variables: {host['user_env_name']} and {host['pass_env_name']}")

if __name__ == "__main__":
    test_inventory = [
        '172.10.1.10',
        '172.10.1.20',
        '172.10.1.30',
        '172.10.1.40',
    ]
    
    inventory = [
        {'host': 'localhost', 'user_env_name': 'LOCAL_USER', 'pass_env_name': 'LOCAL_PASS'},
        {'host': '192.168.1.161', 'user_env_name': 'LOCAL_USER', 'pass_env_name': 'LOCAL_PASS'},
        {'host': '192.168.122.10', 'user_env_name': 'PI_USER', 'pass_env_name': 'PI_PASS'},
        {'host': '192.168.122.121', 'user_env_name': 'SERVER_USER', 'pass_env_name': 'SERVER_PASS'},
    ]

    main(test_inventory)
    # main(inventory)
