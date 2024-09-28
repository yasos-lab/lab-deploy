import subprocess

def run_command(command):
    process = subprocess.run(command, shell=True, capture_output=True, check=True, text=True)
    return process