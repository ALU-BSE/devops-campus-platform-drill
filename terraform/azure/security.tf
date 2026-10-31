# ═══════════════════════════════════════════════════════════════════════════
# SECURITY — owned by R3
#
# A Network Security Group is a STATEFUL ALLOW-LIST.
#
#   Allow-list : nothing gets in unless a rule explicitly permits it.
#   Stateful   : if you allow a connection IN, the reply is allowed OUT
#                automatically. You never write a rule for the reply.
#
# Azure differs from AWS in two visible ways:
#   - Rules have an explicit `priority` (100 = evaluated first). Lower wins.
#   - The NSG is a separate object that must be ASSOCIATED with something.
#     An NSG that protects nothing is just a list of good intentions.
# ═══════════════════════════════════════════════════════════════════════════

resource "azurerm_network_security_group" "main" {
  name                = "${var.project_name}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # ── Inbound: SSH ──────────────────────────────────────────────────────────
  # Locked down to the project network range rather than left open to the world.
  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
  }

  # ── Inbound: the application ──────────────────────────────────────────────
  # TODO (drill 2): nothing can reach the app on var.app_port. Add a security_rule
  # with priority 110. SSH is for you. Who is the app for? destination_port_range
  # is a string, so use tostring(var.app_port).
  #
  # Read: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group#security_rule-1
  # Done when: `terraform fmt` changes nothing, and the rule is in the plan in drill 5.
}

# An NSG does nothing until it is attached to something.
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}
