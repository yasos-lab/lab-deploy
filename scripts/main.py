import subprocess
from utils import setup_controllers, setup_inventory
from consts import TEST_INVENTORY, PROD_INVENTORY

def main():
    setup_controllers()
    
    # Setup localhost : # To refacto
    subprocess.run(['ansible-playbook', '-i', 'inventories/local/inventory.yml', '-l', 'controllers', 'playbooks/main.yml'], check=True)
    
    # Create testing stack :
    subprocess.run(['docker-compose', 'up', '-d'], check=True)
    
    setup_inventory(TEST_INVENTORY)
    #setup_inventory(PROD_INVENTORY)
    
if __name__ == "__main__":
    main()