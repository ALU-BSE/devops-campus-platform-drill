# ═══════════════════════════════════════════════════════════════════════════
# SECURITY — owned by R3
#
# There is no security group here. Docker has no firewall object to configure.
#
# On this track, a port is reachable if and only if it is PUBLISHED — mapped
# from a port on your laptop to a port inside the container. An unpublished
# port is not "blocked"; it simply has no door at all.
#
# That difference has a visible consequence, and it is worth knowing before
# drill 6:
#
#   Cloud tracks : a firewall silently DROPS your packets  -> TIMED OUT
#   This track   : nothing is listening on the host port   -> REFUSED
#
# Same mistake — the door was never opened. Different symptom, because a port
# binding is not a firewall. Learn to read both.
#
# The actual port list lives in compute.tf, because in Docker the ports are an
# argument of the container itself. This file exists to tell you that, and to
# hold the credentials below.
# ═══════════════════════════════════════════════════════════════════════════

locals {
  # The public half of your SSH key, injected into the container at boot so
  # you (and Ansible, in session 2) can log in. Your PRIVATE key never leaves
  # your laptop — that is the whole point of key-based auth.
  operator_public_key = file(pathexpand(var.ssh_public_key_path))

  ssh_user = "devops"
}
