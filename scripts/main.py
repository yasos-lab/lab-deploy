import subprocess, os, time
from utils import setup_controllers, setup_inventory, export_var
from consts import TEST_INVENTORY, PROD_INVENTORY, SECRET_FILE

def main():
    setup_controllers()
    
    # Setup localhost : # To refacto
    subprocess.run(['ansible-playbook', '-i', 'inventories/local/inventory.yml', '-l', 'controllers', 'playbooks/main.yml'], check=True)
    # Create testing stack :
    subprocess.run(['docker-compose', 'up', '-d'], check=True)
    
    minutes = 2
    print(f"Waiting {minutes} minutes for containers to start...")
    time.sleep(2*60)

    setup_inventory(TEST_INVENTORY)
    #setup_inventory(PROD_INVENTORY)
    
if __name__ == "__main__":
    main()