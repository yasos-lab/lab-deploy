import requests
import subprocess
import json
from utils.shell import run_command

def get_var_from_gitlab_project(variable_key, gitlab_project_id, gitlab_pat):
    url = f"https://gitlab.com/api/v4/projects/{gitlab_project_id}/variables/{variable_key}"
    headers = {"PRIVATE-TOKEN": gitlab_pat}
    
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



def check_bw_login(bw_binary):
    try:
        #result = subprocess.run([bw_binary, 'status', '--raw'], capture_output=True, text=True)
        result = run_command(f"{bw_binary} status --raw")
        status = json.loads(result.stdout)
        if status.get("status") == "unlocked":
            return False
        else:
            return True
    except Exception as e:
        print(f"Error checking Bitwarden login status: {e}")
        return False

def get_bw_session(bw_binary, bw_email, bw_password):
    try:
        if check_bw_login(bw_binary):
            #result = subprocess.run([bw_binary, 'unlock', bw_password, '--raw'], capture_output=True, text=True)
            result = run_command(f"{bw_binary} unlock {bw_password} --raw")
            session_token = result.stdout.strip()
            return session_token
        else:
            #result = subprocess.run([bw_binary, 'login', bw_email, bw_password, '--raw'], capture_output=True, text=True)
            result = run_command(f"{bw_binary} login {bw_email} {bw_password} --raw")
            session_token = result.stdout.strip()
            return session_token
    except Exception as e:
        print(f"Error getting Bitwarden session: {e}")
        return None

def get_cred_from_bitwarden(bw_binary, bw_email, bw_password, bw_item_id):
    session_token = get_bw_session(bw_binary, bw_email, bw_password)
    print(f"session_token: {session_token}")
    if session_token is None:
        return None
    try:
        #result = subprocess.run([bw_binary, 'get', 'item', bw_item_id, '--session', session_token], capture_output=True, text=True)
        result = run_command(f"{bw_binary} get item {bw_item_id} --session {session_token}")
        item = json.loads(result.stdout)

        if item['id'] == bw_item_id:
            username = item['login']['username']
            password = item['login']['password']
            return {username:password}
        else:
            return None
    except Exception as e:
        print(f"Error getting Bitwarden item details: {e}")
        return None
