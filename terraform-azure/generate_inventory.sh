#!/bin/bash

# Get the public IP addresses from Terraform output
PUBLIC_IPS=$(cat $1 | jq -r '.public_ip_address.value[]')

# Write the Ansible inventory file
echo "[own_pc]
localhost ansible_connection=local ansible_user=iede

[Testing]"
echo "$PUBLIC_IPS" | awk 'NR==1 {print $1, "ansible_user=adminuser ansible_ssh_private_key_file=~/.ssh/id_rsa.pub"}'

echo "[Acceptance]"
echo "$PUBLIC_IPS" | awk 'NR==2 {print $1, "ansible_user=adminuser ansible_ssh_private_key_file=~/.ssh/id_rsa.pub"}'

echo "[Production]"
echo "$PUBLIC_IPS" | awk 'NR==3 {print $1, "ansible_user=adminuser ansible_ssh_private_key_file=~/.ssh/id_rsa.pub"}'
