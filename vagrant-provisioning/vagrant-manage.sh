#!/bin/bash

# Function to display help message
show_help() {
  echo "Usage: $0 [start|stop|remove|help]"
  echo
  echo "Options:"
  echo "  start  - Starts all Vagrant instances"
  echo "  stop   - Stops all Vagrant instances"
  echo "  remove - Stops and removes all Vagrant instances"
  echo "  help   - Displays this help message"
}

# Function to start all Vagrant instances
start_vagrant_instances() {
  echo "Starting all Vagrant instances..."
  export CONFIG_USER="test"
  export CONFIG_PASS="test"
  # Source ~/.zshrc # the real vars should be here
  vagrant up
}

# Function to stop all Vagrant instances
stop_vagrant_instances() {
  echo "Stopping all Vagrant instances..."
  vagrant halt
}

# Function to remove all Vagrant instances
remove_vagrant_instances() {
  echo "Removing all Vagrant instances..."
  vagrant destroy -f
}

# Check if any arguments are provided
if [ $# -eq 0 ]; then
  echo "Error: No arguments provided."
  show_help
  exit 1
fi

# Parse command-line arguments
case "$1" in
  start)
    start_vagrant_instances
    ;;
  stop)
    stop_vagrant_instances
    ;;
  remove)
    stop_vagrant_instances
    remove_vagrant_instances
    ;;
  help)
    show_help
    ;;
  *)
    echo "Error: Invalid option '$1'."
    show_help
    exit 1
    ;;
esac
