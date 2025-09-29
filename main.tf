# Create a random name for the resource group using random_pet
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

# Create a resource group using the generated random name
resource "azurerm_resource_group" "anup-test-rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

# Create a Virtual netwok and associated subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "anup-vnet"
  location            = azurerm_resource_group.anup-test-rg.location
  resource_group_name = azurerm_resource_group.anup-test-rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "anup-subnet"
  resource_group_name  = azurerm_resource_group.anup-test-rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine_scale_set" "anup_vm" {
  name                = "anup-vm"
  resource_group_name = azurerm_resource_group.anup-test-rg.name
  location            = azurerm_resource_group.anup-test-rg.location
  sku                 = "Standard_F2"
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  network_interface {
    name    = "anup_ni"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.subnet.id
    }
  }
}
