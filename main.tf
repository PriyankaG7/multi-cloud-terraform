# ---------- AWS EC2 ----------
# Use a data source to dynamically fetch the latest Amazon Linux 2 AMI in us-east-2
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "aws_vm" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  tags = {
    Name = "multi-cloud-aws-vm"
  }
}

# ---------- Azure Resources ----------
# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "multiCloudRG"
  location = "East US"
}

# 2. Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "multiCloudVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 3. Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "multiCloudSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4. Public IP (Static for Standard SKU)
resource "azurerm_public_ip" "public_ip" {
  name                = "multiCloudPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 5. Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "multiCloudNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# 6. Azure Linux VM with SSH key from variable
variable "azure_ssh_pub_key" {
  description = "Public SSH key for Azure VM"
  type        = string
}

resource "azurerm_linux_virtual_machine" "azure_vm" {
  name                = "multiCloudAzureVM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [azurerm_network_interface.nic.id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.azure_ssh_pub_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}