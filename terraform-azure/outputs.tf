 
output "public_ip_addresses" {
  value = {
    for key, public_ip in azurerm_public_ip.az_ip : key => public_ip.ip_address
  }
}
