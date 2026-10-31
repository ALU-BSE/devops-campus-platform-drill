# ═══════════════════════════════════════════════════════════════════════════
# OUTPUTS — owned by R4
#
# These three are the contract (../CONTRACT.md). They are not decoration:
# scripts/verify_infra.py reads them, and session 2's Ansible inventory is
# built from them. Get a name wrong and the handoff silently breaks.
#
# Note that these are IDENTICAL to the AWS and Azure tracks' outputs, even
# though every resource above is different. That is the contract doing its job:
# session 2's Ansible playbook will not be able to tell which track you were on.
# ═══════════════════════════════════════════════════════════════════════════

output "instance_public_ip" {
  description = "Where the machine can be reached. On this track, your own laptop."
  value       = "127.0.0.1"
}

output "ssh_user" {
  description = "Login user for the container. Must match USER_NAME in compute.tf."
  value       = local.ssh_user
}

# TODO (drill 3): the third contract output is missing. Add it with exactly the
# name ../CONTRACT.md gives.
#
# Read: https://developer.hashicorp.com/terraform/language/values/outputs
# Done when: `terraform validate` says Success.
