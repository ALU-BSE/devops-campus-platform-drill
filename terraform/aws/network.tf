# ═══════════════════════════════════════════════════════════════════════════
# NETWORK — owned by R2
#
# Four resources, in a chain. Read them in order; each one exists because the
# previous one is not enough on its own.
#
#   aws_vpc                    a private network that belongs to you
#   aws_subnet                 a slice of it, where machines actually live
#   aws_internet_gateway       a door between your network and the internet
#   aws_route_table            the sign that tells traffic to USE that door
#
# A VPC with no internet gateway is a sealed room. An internet gateway with no
# route table entry is a door nobody has been told about. You need all four.
# ═══════════════════════════════════════════════════════════════════════════

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  # Without these two, your instance gets an IP but no name resolution,
  # and `apt-get update` will hang forever in session 2.
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr

  # This is what actually earns the subnet the name "public": machines launched
  # here are handed a public IP automatically. Set this to false and your VM
  # exists, boots, runs — and is permanently unreachable from your laptop.
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-subnet-public"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    # 0.0.0.0/0 means EVERY address on the internet. Read as a sentence:
    # "for any destination I don't otherwise know about, send it to the gateway."
    # This is a routing rule, not a firewall rule — it says where traffic GOES,
    # not who is ALLOWED. Those are different questions, answered in security.tf.
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-rt-public"
  }
}

# A route table does nothing until it is attached to a subnet.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
