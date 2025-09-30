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

resource "azurerm_network_interface" "anup_nic" {
  name                = "anup-nic"
  location            = azurerm_resource_group.anup-test-rg.location
  resource_group_name = azurerm_resource_group.anup-test-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "anup_vm" {
  name                = "anup-virtual-machine"
  resource_group_name = azurerm_resource_group.anup-test-rg.name
  location            = azurerm_resource_group.anup-test-rg.location
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.anup_nic.id,
  ]

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
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${random_pet.rg_name.id}-aks"
  location            = azurerm_resource_group.anup-test-rg.location
  resource_group_name = azurerm_resource_group.anup-test-rg.name
  dns_prefix          = "${random_pet.rg_name.id}-k8s"
  kubernetes_version  = "1.33.0"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "Demo Environment"
  }
}

