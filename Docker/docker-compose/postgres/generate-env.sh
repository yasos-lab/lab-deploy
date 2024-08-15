#!/bin/bash

source ~/.env

# Ensure .env file exists
touch .env

# Populate .env file with variables from current environment
echo "POSTGRES_USER=${POSTGRES_USER}" > .env
echo "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}" >> .env