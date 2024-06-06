import json

# Load Terraform output from ip_addresses.json
with open('ip_addresses.json') as f:
    ip_addresses = json.load(f)['public_ip_addresses']

# Define the template for hosts file
hosts_template = """
[Testing]
{vm1} ansible_user=adminuser ansible_ssh_private_key_file=/home/adminuser/.ssh/id_rsa

[Acceptance]
{vm2} ansible_user=adminuser ansible_ssh_private_key_file=/home/adminuser/.ssh/id_rsa

[Production]
{vm3} ansible_user=adminuser ansible_ssh_private_key_file=/home/adminuser/.ssh/id_rsa
"""

# Update hosts file with Terraform IP addresses
hosts_content = hosts_template.format(vm1=ip_addresses['vm1'], vm2=ip_addresses['vm2'], vm3=ip_addresses['vm3'])

# Write updated hosts content to the hosts file
with open('/opt/pertclinic/ansible/hosts', 'w') as f:
    f.write(hosts_content)

print("Hosts file updated successfully.")

