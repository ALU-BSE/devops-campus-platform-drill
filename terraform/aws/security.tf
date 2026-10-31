# ═══════════════════════════════════════════════════════════════════════════
# SECURITY — owned by R3
#
# A security group is a STATEFUL ALLOW-LIST.
#
#   Allow-list : nothing gets in unless a rule explicitly permits it.
#                There is no "deny" rule, because the default is already deny.
#
#   Stateful   : if you allow a connection IN, the reply is allowed OUT
#                automatically. You never write a rule for the reply.
#                This is why there is no "outbound rule for SSH responses"
#                anywhere in this file, and why you shouldn't add one.
#
# Two questions to keep separate in your head:
#   network.tf asks  "where does traffic GO?"      (routing)
#   security.tf asks "who is ALLOWED to arrive?"   (firewall)
# ═══════════════════════════════════════════════════════════════════════════

resource "aws_security_group" "app" {
  name        = "${var.project_name}-sg"
  description = "Inbound SSH for operators, inbound HTTP for the app"
  vpc_id      = aws_vpc.main.id

  # ── Inbound: SSH ──────────────────────────────────────────────────────────
  # Locked down to the project network range rather than left open to the world.
  ingress {
    description = "SSH for operators"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # ── Inbound: the application ──────────────────────────────────────────────
  # TODO (drill 2): nothing can reach the app on var.app_port. Add an ingress rule.
  # SSH is for you. Who is the app for? Say your answer before you pick the
  # source range.
  #
  # Read: https://registry.terraform.io/providers/hashicorp/aws/5.100.0/docs/resources/security_group#ingress
  # Done when: `terraform validate` says Success.

  # ── Outbound: everything ──────────────────────────────────────────────────
  # protocol = "-1" means "any protocol". The box needs to reach the internet
  # to install packages in session 2 (apt, docker pull, ghcr.io).
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# The public half of your SSH key, uploaded to AWS so it can be baked into the
# instance at boot. Your PRIVATE key never leaves your laptop — that is the
# whole point of key-based auth.
resource "aws_key_pair" "operator" {
  key_name   = "${var.project_name}-key"
  public_key = file(pathexpand(var.ssh_public_key_path))
}
