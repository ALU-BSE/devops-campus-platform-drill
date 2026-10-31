# The second machine: Postgres for the Campus Notifier.
#
# It has a public IP so it can reach apt without a billed NAT gateway, and so
# Ansible can SSH straight in. Its firewall is what keeps it private. A
# production database would sit in a private subnet with no public address.

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Inbound SSH for operators, inbound Postgres from the app server only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH for operators"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  # TODO (drill 4): allow 5432 from the app server only. Security groups can name
  # another group as the source, and that keeps working if the app's IP changes.
  #
  # Read: https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html
  # Done when: `terraform validate` says Success, and the rule has no cidr_blocks.

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

resource "aws_instance" "db" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.db.id]
  key_name               = aws_key_pair.operator.key_name

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-db"
  }
}

output "instance_private_ip" {
  description = "App server's address inside the network. Postgres allows this host."
  value       = aws_instance.app.private_ip
}

output "db_public_ip" {
  description = "Public IP of the database VM. Ansible will SSH to this."
  value       = aws_instance.db.public_ip
}

output "db_private_ip" {
  description = "Database VM's address inside the network. The app connects to this."
  value       = aws_instance.db.private_ip
}

output "db_ssh_port" {
  description = "SSH port of the database VM."
  value       = 22
}
