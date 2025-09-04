output "aws_instance_public_ip" {
  value = aws_instance.aws_vm.public_ip
}

output "azure_vm_public_ip" {
  value = azurerm_linux_virtual_machine.azure_vm.public_ip_address
}