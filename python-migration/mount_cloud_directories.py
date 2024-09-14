import os
import subprocess
import utils.const as const
from utils.secret_manager import get_var_from_gitlab_project, get_cred_from_bitwarden
from utils.shell import run_command

def setup_rclone():
    if subprocess.call(["which", "rclone"], stdout=subprocess.PIPE, stderr=subprocess.PIPE) != 0:
        print("rclone not found. Installing...")
        run_command("curl https://rclone.org/install.sh | sudo bash")
    else:
        print("rclone is already installed.")
    
    os.makedirs(f"{const.HOME_DIR}/.config/rclone", exist_ok=True)
    open(f"{const.HOME_DIR}/.config/rclone/rclone.conf", 'a').close()
    print("rclone config file created.")

def mount_cloud(provider, mount_label, username, password):
    subprocess.run(f"rclone config create {provider} {provider} user {username} pass {password}", shell=True, check=True)
    mount_point = os.path.join(const.HOME_DIR, mount_label)
    os.makedirs(mount_point, exist_ok=True)
    mount_command = f"rclone mount {provider}:/ {mount_point} --daemon"

    zshrc_path = f"{const.HOME_DIR}/.zshrc"
    with open(zshrc_path, 'a+') as zshrc:
        if mount_command not in zshrc.read():
            zshrc.write(f"\n{mount_command}\n")
            print(f"Mount command for {provider} added to .zshrc.")
        else:
            print(f"Mount command for {provider} already exists in .zshrc.")

if __name__ == "__main__":
    # Setup Rclone
    setup_rclone()

    # Get BW creds
    bw_email = get_var_from_gitlab_project(const.BW_EMAIL_GITLAB_VAR_KEY, const.GITLAB_PID, const.GITLAB_PAT)
    bw_password = get_var_from_gitlab_project(const.BW_PASSWORD_GITLAB_VAR_KEY, const.GITLAB_PID, const.GITLAB_PAT)
    
    # Mount multiple cloud providers
    for provider in const.CLOUD_PROVIDERS:
        provider_bw_id = get_var_from_gitlab_project(provider['gitlab_var_key_bw_id'], const.GITLAB_PID, const.GITLAB_PAT)
        print(f"{provider['label']} bw id is : {provider_bw_id}")
        provider_username, provider_password = get_cred_from_bitwarden(const.BW_BINARY, bw_email, bw_password, provider_bw_id)
        mount_cloud(provider['provider'], provider['label'], provider_username, provider_password)


