# ═══════════════════════════════════════════════════════════════════════════
# OUTPUTS — owned by R4
#
# These three are the contract (../CONTRACT.md). They are not decoration:
# scripts/verify_infra.py reads them, and session 2's Ansible inventory is
# built from them. Get a name wrong and the handoff silently breaks.
# ═══════════════════════════════════════════════════════════════════════════

output "instance_public_ip" {
  description = "Public IP of the app server. Ansible will SSH to this."
  value       = aws_instance.app.public_ip
}

output "ssh_user" {
  description = "Default login user for the Ubuntu AMI."
  value       = "ubuntu"
}

# TODO (drill 3): the third contract output is missing. Add it with exactly the
# name ../CONTRACT.md gives.
#
# Read: https://developer.hashicorp.com/terraform/language/values/outputs
# Done when: `terraform validate` says Success.
