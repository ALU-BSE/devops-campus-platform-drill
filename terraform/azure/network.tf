# ═══════════════════════════════════════════════════════════════════════════
# NETWORK — owned by R2
#
# Azure gives you the same four ideas as AWS, but does more of the work for you:
#
#   azurerm_resource_group        a folder holding everything (AWS has no
#                                 equivalent — this is genuinely Azure-only)
#   azurerm_virtual_network       your private network            (= AWS VPC)
#   azurerm_subnet                a slice of it                   (= AWS subnet)
#   azurerm_public_ip             a public address                (= AWS EIP)
#   azurerm_network_interface     the "network card" that glues the VM to the
#                                 subnet and the public IP together
#
# Notice what is MISSING compared to the AWS track: there is no internet gateway
# and no route table. Azure creates a default route to the internet for you.
# That is a real difference between the two clouds, not a gap in this file —
# and it is why "I know AWS" does not automatically mean "I know Azure".
# ═══════════════════════════════════════════════════════════════════════════

resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "${var.project_name}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_cidr]
}

resource "azurerm_public_ip" "main" {
  name                = "${var.project_name}-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # "Static" means the address does not change if the VM reboots. A Dynamic IP
  # would be cheaper and would also silently break the Ansible inventory you
  # generate today, the first time the box restarts.
  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.project_name}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"

    # THIS is the line that makes the VM reachable from the internet. Delete it
    # and the machine still builds, still boots, still runs — and you can never
    # reach it. Existing and being reachable are two different things.
    public_ip_address_id = azurerm_public_ip.main.id
  }
}
