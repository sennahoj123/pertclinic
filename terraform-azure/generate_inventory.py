import os
import json

# Absolute path to the ip_addresses.json file
json_file_path = '/opt/pertclinic/terraform-azure/ip_addresses.json'

# Check if the json file exists
if not os.path.exists(json_file_path):
    print("Error: ip_addresses.json file not found.")
    exit(1)

# Load Terraform output from ip_addresses.json
with open(json_file_path) as f:
    ip_addresses = json.load(f)['public_ip_addresses']['value']

# Define the template for hosts file
hosts_template = """
[Testing]
{vm1_ip} ansible_user=adminuser ansible_ssh_private_key_file=/home/adminuser/.ssh/id_rsa

[Acceptance]
{vm2_ip} ansible_user=adminuser ansible_ssh_private_key_file=/home/adminuser/.ssh/id_rsa

[Production]
{vm3_ip} ansible_user=adminuser ansible_ssh_private_key_file=/home/adminuser/.ssh/id_rsa
"""

# Update hosts file with Terraform IP addresses
hosts_content = hosts_template.format(
    vm1_ip=ip_addresses['vm1'],
    vm2_ip=ip_addresses['vm2'],
    vm3_ip=ip_addresses['vm3']
)

# Write updated hosts content to the hosts file
with open('/opt/pertclinic/terraform-azure/hosts', 'w') as f:
    f.write(hosts_content)

print("Hosts file updated successfully.")
