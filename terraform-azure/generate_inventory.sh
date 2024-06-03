#!/bin/bash

# Check if the input file is provided and exists
if [ -z "$1" ] || [ ! -f "$1" ]; then
  echo "Usage: $0 <path_to_ip_addresses.json>"
  exit 1
fi

# Extract the public IP addresses from the JSON file and format them for Ansible inventory
jq -r '.public_ip_addresses.value | to_entries | .[] | "\(.key) ansible_host=\(.value)"' "$1" > hosts
