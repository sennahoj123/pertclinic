# Get the public IP addresses from Terraform output
PUBLIC_IPS=$(terraform output public_ip_address)

# Write the Ansible inventory file
echo "[own_pc]
localhost ansible_connection=local ansible_user=iede

echo "[Testing]"
echo "$PUBLIC_IPS" | awk '{print $1, "ansible_user=adminuser ansible_ssh_private_key_file=~/.ssh/id_rsa.pub"}'

echo "[Acceptance]"
echo "$PUBLIC_IPS" | awk '{print $2, "ansible_user=adminuser ansible_ssh_private_key_file=~/.ssh/id_rsa.pub"}'

echo "[Production]"
echo "$PUBLIC_IPS" | awk '{print $3, "ansible_user=adminuser ansible_ssh_private_key_file=~/.ssh/id_rsa.pub"}'

