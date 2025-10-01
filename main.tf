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
  size                = var.vm_size_azure
  admin_username      = var.azure_user
  network_interface_ids = [
    azurerm_network_interface.anup_nic.id,
  ]

  admin_ssh_key {
    username   = var.azure_user
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

resource "azurerm_container_registry" "acr" {
  name                = "testacr"
  location            = azurerm_resource_group.anup-test-rg.location
  resource_group_name = azurerm_resource_group.anup-test-rg.name
  sku                 = var.acr_sku
  admin_enabled       = false
  tags = {
    created_by = "terraform"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${random_pet.rg_name.id}-aks"
  location            = azurerm_resource_group.anup-test-rg.location
  resource_group_name = azurerm_resource_group.anup-test-rg.name
  dns_prefix          = "${random_pet.rg_name.id}-k8s"
  kubernetes_version  = "1.33.0"

  default_node_pool {
    name       = "aks"
    node_count = var.node_count_kub
    vm_size    = var.vm_size_kub
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "Demo Environment"
    created_by  = "terraform"
  }
}

data "azurerm_role_definition" "acr_pull" {
  name = "AcrPull"
}

# Assign AcrPull to the AKS kubelet identity so nodes can pull images from ACR.
# Use the kubelet_identity object_id (this is the identity used by kubelets to pull images)§§§§
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope              = azurerm_container_registry.acr.id
  role_definition_id = data.azurerm_role_definition.acr_pull.id
  principal_id       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  skip_service_principal_aad_check = true

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

