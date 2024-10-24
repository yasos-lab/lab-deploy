import subprocess
import os
import getpass
import json
import shutil
import consts

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