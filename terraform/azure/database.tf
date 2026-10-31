# The second machine: Postgres for the Campus Notifier.
#
# It has a public IP so it can reach apt and so Ansible can SSH straight in. Its
# firewall is what keeps it private. A production database would have no public
# address.

resource "azurerm_public_ip" "db" {
  name                = "${var.project_name}-db-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "db" {
  name                = "${var.project_name}-db-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.db.id
  }
}

resource "azurerm_network_security_group" "db" {
  name                = "${var.project_name}-db-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_ip_cidr
    destination_address_prefix = "*"
  }

  # TODO (drill 4): add two rules. Azure's built-in rule 65000 allows everything
  # from inside the virtual network, so an allow on its own changes nothing.
  #   Priority 110: allow 5432 from the app's private IP, as
  #     "${azurerm_network_interface.main.private_ip_address}/32".
  #   Priority 120: deny 5432 from everything else.
  #
  # Read: https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview#default-security-rules
  # Done when: `terraform validate` says Success, and you can say what rule 120 does.
}

resource "azurerm_network_interface_security_group_association" "db" {
  network_interface_id      = azurerm_network_interface.db.id
  network_security_group_id = azurerm_network_security_group.db.id
}

resource "azurerm_linux_virtual_machine" "db" {
  name                            = "${var.project_name}-db-vm"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = "Standard_B1s"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  network_interface_ids = [azurerm_network_interface.db.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

output "instance_private_ip" {
  description = "App server's address inside the network. Postgres allows this host."
  value       = azurerm_network_interface.main.private_ip_address
}

output "db_public_ip" {
  description = "Public IP of the database VM. Ansible will SSH to this."
  value       = azurerm_public_ip.db.ip_address
}

output "db_private_ip" {
  description = "Database VM's address inside the network. The app connects to this."
  value       = azurerm_network_interface.db.private_ip_address
}

output "db_ssh_port" {
  description = "SSH port of the database VM."
  value       = 22
}
