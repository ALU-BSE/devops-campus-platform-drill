# ═══════════════════════════════════════════════════════════════════════════
# OUTPUTS — owned by R4
#
# These three are the contract (../CONTRACT.md). They are not decoration:
# scripts/verify_infra.py reads them, and session 2's Ansible inventory is
# built from them. Get a name wrong and the handoff silently breaks.
#
# Note that these are IDENTICAL to the AWS track's outputs, even though almost
# every resource above is different. That is the contract doing its job.
# ═══════════════════════════════════════════════════════════════════════════

output "instance_public_ip" {
  description = "Public IP of the app server. Ansible will SSH to this."
  value       = azurerm_public_ip.main.ip_address
}

output "ssh_user" {
  description = "Login user for the VM. Must match admin_username in compute.tf."
  value       = azurerm_linux_virtual_machine.app.admin_username
}

# TODO (drill 3): the third contract output is missing. Add it with exactly the
# name ../CONTRACT.md gives.
#
# Read: https://developer.hashicorp.com/terraform/language/values/outputs
# Done when: `terraform validate` says Success.
