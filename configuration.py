import subprocess
import os
import getpass
import json

def install_bitwarden_cli(version="2024.10.0"):
    url = f"https://github.com/bitwarden/clients/releases/download/cli-v{version}/bw-linux-{version}.zip"
    
    subprocess.run(['curl', '-L', url, '-o', '/tmp/bw.zip'], check=True)
    subprocess.run(['sudo', 'unzip', '-o', '/tmp/bw.zip', '-d', '/tmp'], check=True)
    subprocess.run(['sudo', 'mv', '/tmp/bw', '/usr/local/bin/bw'], check=True)
    subprocess.run(['sudo', 'chmod', '+x', '/usr/local/bin/bw'], check=True)

    print("Bitwarden CLI installed successfully!")

def set_bitwarden_session():
    try:
        # Step 1: Check the status to see if already logged in and unlocked
        status_command = ["bw", "status"]
        status_result = subprocess.run(status_command, capture_output=True, text=True)
        
        if status_result.returncode != 0:
            return {"error": f"Failed to check status: {status_result.stderr.strip()}"}
        
        status_data = json.loads(status_result.stdout)
        
        if status_data.get("status") == "locked":
            password = getpass.getpass(prompt=f"Re-Enter your bitwarden password for {status_data.get("userEmail")}: ")

        elif status_data.get("status") == "unauthenticated":
            email = input("Enter your bitwarden email: ")
            password = getpass.getpass(prompt=f"Enter your bitwarden password for {email}: ")

            login_command = ["bw", "login", email, password, "--raw"]
            login_result = subprocess.run(login_command, capture_output=True, text=True)

            if login_result.returncode != 0:
                return {"error": f"Login failed: {login_result.stderr.strip()}"}

        unlock_command = ["bw", "unlock", password, "--raw"]
        unlock_result = subprocess.run(unlock_command, capture_output=True, text=True)

        if unlock_result.returncode != 0:
            return {"error": f"Unlock failed: {unlock_result.stderr.strip()}"}
        # Return the session token
        session_token = unlock_result.stdout.strip()
        
        export_var('BW_SESSION', session_token)

    except Exception as e:
        return {"error": str(e)}

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
            
            install_bitwarden_cli()
        
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
        known_hosts_path = os.path.expanduser('~/.ssh/known_hosts')
        print(f"Removing old SSH key associated with {host}...")
        subprocess.run(['ssh-keygen', '-f', known_hosts_path, '-R', f'{host}'], check=True)
        print("Old SSH key removed.")
        print(f"Copying SSH key to {host}...")
        subprocess.run(['sshpass', '-p', password, 'ssh-copy-id', '-o', 'StrictHostKeyChecking=no', f'{user}@{host}'], check=True)
        print(f"SSH key copied to {host} successfully.")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error copying SSH key to {host}: {e}")
        return False

def export_var(name, value):
    rc_files = [os.path.expanduser('~/.zshrc'), os.path.expanduser('~/.bashrc')]
    export_line = f'export {name}="{value}"\n'

    for rc_file in rc_files:
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

            print(f"Updated environment variables in {rc_file}.")
            return

    print("Neither .zshrc nor .bashrc found. Please create one manually.")

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

def setup_hosts(inventory):
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
    test_inventory = [
        '172.10.1.10',
        '172.10.1.20',
        '172.10.1.30',
    ]
    inventory = [
        {'host': 'localhost', 'user_env_name': 'TP_USER', 'pass_env_name': 'TP_PASSWORD'},
        {'host': '192.168.1.161', 'user_env_name': 'EB_USER', 'pass_env_name': 'EB_PASSWORD'},
        {'host': '192.168.122.10', 'user_env_name': 'PI_USER', 'pass_env_name': 'PI_PASSWORD'},
        {'host': '192.168.122.121', 'user_env_name': 'SVR_USER', 'pass_env_name': 'SVR_PASSWORD'},
    ]


    # install_packages()
    set_bitwarden_session()

    #setup_controller()

    #setup_hosts(test_inventory)
    # setup_hosts(inventory)
