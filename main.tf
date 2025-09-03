# Create a random name for the resource group using random_pet
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

# Create a resource group using the generated random name
resource "azurerm_resource_group" "anup-test-rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}