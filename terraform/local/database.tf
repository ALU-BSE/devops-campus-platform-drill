# The second machine: Postgres for the Campus Notifier, as a second container on
# the same Docker network.
#
# Your laptop's port 22 already goes to the app box, so this box's SSH is
# published on 2222. Port 5432 is not published at all, so nothing outside the
# Docker network can reach it. An unpublished port has no door.

resource "docker_container" "db" {
  name  = "${var.project_name}-db"
  image = docker_image.sshd.image_id

  networks_advanced {
    name = docker_network.main.name
  }

  # Same reasons as the app box: see compute.tf.
  privileged    = true
  cgroupns_mode = "host"

  mounts {
    target = "/sys/fs/cgroup"
    source = "/sys/fs/cgroup"
    type   = "bind"
  }

  # TODO (drill 4): publish SSH on your laptop's port 2222, because port 22 is the
  # app box's. Do not publish 5432.
  #
  # Read: https://registry.terraform.io/providers/kreuzwerker/docker/3.9.0/docs/resources/container#ports-1
  # Done when: `terraform validate` says Success, and db_ssh_port still says 2222.

  restart = "unless-stopped"
}

output "instance_private_ip" {
  description = "App box's address inside the network. Postgres allows this host."
  value       = docker_container.app.network_data[0].ip_address
}

output "db_public_ip" {
  description = "Where the database box can be reached. On this track, your own laptop."
  value       = "127.0.0.1"
}

output "db_private_ip" {
  description = "Database box's address inside the network. The app connects to this."
  value       = docker_container.db.network_data[0].ip_address
}

output "db_ssh_port" {
  description = "SSH port of the database box, published on your laptop."
  value       = 2222
}
