import os, subprocess, shutil, getpass, consts
from secrets import get_var_from_gitlab_project, get_bw_secret_by_id

def install_bitwarden_cli():
    if shutil.which("bw"):
        print("Bitwarden CLI is already installed.")
        return

    url = f"https://github.com/bitwarden/clients/releases/download/cli-v{consts.BW_VERSION}/bw-linux-{consts.BW_VERSION}.zip"
    
    subprocess.run(['curl', '-L', url, '-o', '/tmp/bw.zip'], check=True)
    subprocess.run(['sudo', 'unzip', '-o', '/tmp/bw.zip', '-d', '/tmp'], check=True)
    subprocess.run(['sudo', 'mv', '/tmp/bw', '/usr/local/bin/bw'], check=True)
    subprocess.run(['sudo', 'chmod', '+x', '/usr/local/bin/bw'], check=True)

    print("Bitwarden CLI installed successfully!")

def install_packages():
    try:
        with open('/etc/os-release') as f:
            content = f.read()
            if 'ubuntu' in content or 'debian' in content:
                subprocess.run(['sudo', 'apt', 'install', '-y'] + consts.REQUIRED_PACKAGES, check=True)
            elif 'centos' in content or 'fedora' in content or 'rhel' in content:
                subprocess.run(['sudo', 'dnf', 'install', '-y'] + consts.REQUIRED_PACKAGES, check=True)
            else:
                print("Unsupported distribution.")
                exit(1)    
            
            install_bitwarden_cli()
        
            print("Successfully installed packages.")
    except subprocess.CalledProcessError as e:
        print(f"Error installing packages: {e}")
        exit(1)

def export_var(name, value):
    export_line = f'export {name}="{value}"\n'

    for rc_file in consts.RC_FILES:
        if os.path.exists(rc_file):
            with open(rc_file, 'r') as f:
                lines = f.readlines()

            with open(rc_file, 'w') as f:
                found = False
                for line in lines:
                    if line.startswith(f'export {name}='):
                        f.write(export_line)
                        found = True
                    else:
                        f.write(line)
                if not found:
                    f.write(export_line)
            os.system(f"source {rc_file}")
            print(f"Updated environment variables in {rc_file}.")
            return

    print("Neither .zshrc nor .bashrc found. Please create one manually.")

def generate_ssh_key():
    if not os.path.exists(consts.RSA_KEY_PATH):
        try:
            subprocess.run(['ssh-keygen', '-t', 'rsa', '-b', '2048', '-f', consts.RSA_KEY_PATH, '-N', ''], check=True)
            print("SSH key generated successfully.")
        except subprocess.CalledProcessError as e:
            print(f"Error generating SSH key: {e}")
            exit(1)
    else:
        print("SSH key already exists. Skipping key generation.")

def ssh_copy_id(host, user, password):
    try:
        print(f"Removing old SSH key associated with {host}...")
        subprocess.run(['ssh-keygen', '-f', consts.KNOWN_HOSTS_PATH, '-R', f'{host}'], check=True)
        print("Old SSH key removed.")
        print(f"Copying SSH key to {host}...")
        subprocess.run(['sshpass', '-p', password, 'ssh-copy-id', '-o', 'StrictHostKeyChecking=no', f'{user}@{host}'], check=True)
        print(f"SSH key copied to {host} successfully.")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error copying SSH key to {host}: {e}")
        return False

## To Refacto
def setup_controller():
    install_packages()
    generate_ssh_key()

    user = input("Enter username for localhost: ")
    password = getpass.getpass(prompt=f"Enter password for {user}@localhost: ")
    
    if ssh_copy_id('localhost', user, password):
        pass

def setup_inventory(inventory):
    try:
        for host in inventory:
            if 'bw_item_id_gitlab_var_key' in host:
                bw_item_id = get_var_from_gitlab_project(host['bw_item_id_gitlab_var_key'])
                username = get_bw_secret_by_id('username', bw_item_id)
                password = get_bw_secret_by_id('password', bw_item_id)
            elif 'username' in host and 'password' in host:
                username = host['username']
                password = host['password']
            else:
                raise KeyError("The inventory must have 'bw_item_id_gitlab_var_key' or 'username' and 'password' in host dictionary")

            if ssh_copy_id(host['ip'], username, password):
                print(f"Host {host['name']} is ready!")
            else:
                print(f"Error setting up host {host['name']}: {e}")
    except Exception as e:
        print(f"Error setting up inventory {inventory}: {e}")
