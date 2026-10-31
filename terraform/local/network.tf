# ═══════════════════════════════════════════════════════════════════════════
# NETWORK — owned by R2
#
# You are on the local track. You have no cloud account today, and that is
# fine: everything you are about to learn — providers, resources, variables,
# outputs, state, plan, apply, destroy — is identical on AWS and Azure. The
# nouns change. The thinking does not.
#
# Docker's networking is a genuinely simplified version of the same ideas:
#
#   docker_network   a private network with an address range   (= VPC / VNet)
#   (no subnet)      Docker does not make you carve one out
#   (no gateway)     Docker NATs to the internet for you
#   published ports  the ONLY way anything from outside reaches the container
#
# Read that last line again. On this track, the "firewall" is not a firewall
# at all — it is the port publishing list. If a port is not published, there is
# no door. This matters in drill 6.
# ═══════════════════════════════════════════════════════════════════════════

resource "docker_network" "main" {
  name = "${var.project_name}-net"

  # The gateway is set so Terraform and Docker agree. Without it, every plan wants
  # to replace this network, and that fails while containers are attached to it.
  ipam_config {
    subnet  = var.network_cidr
    gateway = cidrhost(var.network_cidr, 1)
  }
}

resource "docker_image" "sshd" {
  # Ubuntu 22.04 with systemd and an SSH daemon — a stand-in for a cloud VM, so
  # that Ansible has something real to log into. Same OS the AWS and Azure tracks
  # provision. See image/Dockerfile for why that matters.
  #
  # Terraform builds this image on the first apply: about a minute, then instant.
  name = "${var.project_name}-sshd:local"

  build {
    context = "${path.module}/image"

    build_args = {
      SSH_PUBLIC_KEY = local.operator_public_key
    }
  }

  # Rebuild whenever the Dockerfile actually changes.
  #
  # Without this, Terraform sees a resource whose arguments are unchanged, decides
  # there is nothing to do, and happily keeps the STALE image — so you edit the
  # Dockerfile, run apply, get "0 changed", and spend twenty minutes debugging a
  # container built from code you no longer have.
  #
  # (This is not a hypothetical. It cost real time while building this activity.)
  triggers = {
    dockerfile_sha = filesha256("${path.module}/image/Dockerfile")
  }
}
