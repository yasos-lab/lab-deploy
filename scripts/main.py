import subprocess
import os
import time
import argparse
from utils import setup_controllers, setup_inventory, export_var
from consts import TEST_INVENTORY, PROD_INVENTORY, SECRET_FILE

def main():
    # Argument Parsing
    parser = argparse.ArgumentParser(description="Script to set up environment, inventory, and controllers.")
    parser.add_argument("--inventory", choices=["test", "prod", "both"], default="test", 
                        help="Choose the inventory to set up: test, prod, or both.")
    parser.add_argument("--prepare", choices=["all", "docker", "controllers"], default="all", 
                        help="Select what to prepare: all, docker, or controllers.")
    parser.add_argument("--controller_playbook", action="store_true", 
                        help="Run the Ansible playbook for controllers if set to true.")
    args = parser.parse_args()

    # Execute Setup Based on Arguments
    if args.prepare in ["all", "controllers"]:
        setup_controllers()
    
    if args.controller_playbook:
        print("Running Ansible playbook for controllers...")
        subprocess.run(['ansible-playbook', '-i', 'inventories/local/inventory.yml', '-l', 'controllers', 'playbooks/main.yml'], check=True)

    if args.prepare in ["all", "docker"]:
        print("Creating testing stack...")
        subprocess.run(['docker-compose', 'up', '-d'], check=True)
        
        minutes = 2
        print(f"Waiting {minutes} minutes for containers to start...")
        time.sleep(minutes * 60)

    # Setup Inventory Based on Selection
    if args.inventory in ["test", "both"]:
        print("Setting up testing inventory...")
        setup_inventory(TEST_INVENTORY)
    
    if args.inventory in ["prod", "both"]:
        print("Setting up production inventory...")
        setup_inventory(PROD_INVENTORY)

if __name__ == "__main__":
    main()
