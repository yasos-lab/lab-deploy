import os, subprocess, getpass
import requests, json
from consts import GITLAB_PAT, GITLAB_PID

def get_gitlab_pat():
    if('GITLAB_PAT' in os.environ):
        return os.getenv('GITLAB_PAT')
    else:
        correct_pat = False
        while(correct_pat == False):
            gitlap_pat = getpass.getpass(prompt=f"Enter your gitlab access token: ")
            if requests.get("https://gitlab.com/api/v4/user", headers={"Private-Token": gitlap_pat}).status_code == 200:
                print("The provided GitLab access token is valid !")
                correct_pat = True
            else:
                print("The provided GitLab access token is invalid.")
        export_var('GITLAB_PAT', gitlap_pat)
        
        return gitlap_pat

def get_var_from_gitlab_project(variable_key):
    url = f"https://gitlab.com/api/v4/projects/{GITLAB_PID}/variables/{variable_key}"
    headers = {"PRIVATE-TOKEN": GITLAB_PAT}
    
    response = requests.get(url, headers=headers)
    response_data = response.json()

    # Check for errors in the response
    if 'error' in response_data:
        raise Exception(f"Error retrieving variable {variable_key}: {response_data['error']}")
    
    # Retrieve and return the value of the variable
    variable_value = response_data.get('value')
    
    if not variable_value:
        raise Exception(f"Failed to retrieve the value of the variable: {variable_key}")
    
    return variable_value

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

        session_token = unlock_result.stdout.strip()
        
        export_var('BW_SESSION', session_token)

    except Exception as e:
        return {"error": str(e)}

def get_bw_secret_by_id(secret, item_id):
    try:
        result = subprocess.run(['bw', 'get', secret, item_id], capture_output=True, check=True)
        return result.stdout.decode('utf-8')
    
    except subprocess.CalledProcessError:
        raise RuntimeError(f"Secret '{secret}' or item with ID '{item_id}' not found.")

def test():
    item_id = get_var_from_gitlab_project('TP_HOST_BW_ID')
    set_bitwarden_session()
    print(get_bw_secret_by_id('username', item_id))

if __name__ == "__main__":
    test()
