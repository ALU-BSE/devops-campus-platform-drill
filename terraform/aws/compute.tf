# ═══════════════════════════════════════════════════════════════════════════
# COMPUTE — owned by R4
#
# One machine. Nothing installed on it. That is correct and intentional —
# see the last section of ../CONTRACT.md.
# ═══════════════════════════════════════════════════════════════════════════

# A data source READS something that already exists; it does not create anything.
# Here it asks AWS "what is the newest Ubuntu 22.04 image, right now?" so that
# we never hardcode an AMI id that goes stale in three months.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical, the publisher of Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # free-tier eligible on old and new AWS accounts

  # TODO (drill 3): three optional arguments are missing, so `validate` passes
  # and you would get a server you cannot reach. Set the subnet (aws_subnet.public),
  # the firewall list (aws_security_group.app) and the key (aws_key_pair.operator).
  #
  # Read: https://registry.terraform.io/providers/hashicorp/aws/5.100.0/docs/resources/instance#subnet_id-1
  # Done when: `terraform validate` says Success and all three are set.

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-app"
  }
}
