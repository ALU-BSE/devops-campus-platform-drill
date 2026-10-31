# ═══════════════════════════════════════════════════════════════════════════
# COMPUTE — owned by R4
#
# One machine. Nothing installed on it. That is correct and intentional —
# see the last section of ../CONTRACT.md.
# ═══════════════════════════════════════════════════════════════════════════

resource "azurerm_linux_virtual_machine" "app" {
  name                = "${var.project_name}-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s" # smallest burstable size; free-tier eligible

  # This is the username Ansible will log in as in session 2. It must match the
  # ssh_user output exactly. If these two ever disagree, the handoff breaks and
  # nothing will tell you why.
  admin_username = "azureuser"

  # Passwords off. Keys only. This is not optional hardening — it is the
  # baseline, and Azure will happily let you do the wrong thing if you ask.
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  # TODO (drill 3): the VM has no network card. Attach azurerm_network_interface.main.
  # This argument is required, so `validate` fails until you do.
  #
  # Read: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine#network_interface_ids-1
  # Done when: `terraform validate` says Success.

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
