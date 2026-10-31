# ═══════════════════════════════════════════════════════════════════════════
# COMPUTE — the box Ansible will configure
#
# One container, standing in for one machine. It runs systemd and an SSH daemon
# and NOTHING ELSE. The Campus Notifier is not on it. Docker is not on it.
#
# That is the whole point. Terraform's job ended here in session 1. This session
# you close the gap.
# ═══════════════════════════════════════════════════════════════════════════

resource "docker_container" "app" {
  name  = "${var.project_name}-app"
  image = docker_image.sshd.image_id

  networks_advanced {
    name = docker_network.main.name
  }

  # ── Making this box behave like a real VM ─────────────────────────────────
  #
  # A cloud VM boots systemd and can run a container engine. A plain Docker
  # container can do neither. These three settings close that gap, and they are
  # the ONLY thing that differs from the cloud tracks:
  #
  #   privileged      lets systemd manage cgroups, and lets a Docker daemon run
  #                   INSIDE this box (your playbook is about to install one)
  #   cgroupns_mode   systemd needs to see the host's cgroup hierarchy
  #   the /sys/fs/cgroup mount  same reason
  #
  # `privileged = true` is a genuinely dangerous setting on a real server — it
  # hands the container the keys to the host kernel. It is acceptable here for
  # exactly one reason: this box is a disposable local stand-in, on your own
  # laptop, that you will destroy at the end of the session.
  #
  # If you ever find yourself typing it on something that matters, stop.
  privileged    = true
  cgroupns_mode = "host"

  mounts {
    target = "/sys/fs/cgroup"
    source = "/sys/fs/cgroup"
    type   = "bind"
  }

  # ── Published ports ───────────────────────────────────────────────────────
  # 22 so Ansible can log in. app_port so you can see the Campus Notifier once the
  # playbook has actually deployed it — right now, nothing is listening there.
  ports {
    internal = var.app_port
    external = var.app_port
  }

  # TODO (drill 6): nothing is published for SSH yet. Leave this until drill 6, and
  # predict now: will `terraform apply` fail? What breaks, and when do you find out?
  # Then publish container port 22 on your laptop's port 22.
  #
  # Read: https://registry.terraform.io/providers/kreuzwerker/docker/3.9.0/docs/resources/container#ports-1
  # Done when: verify_infra.py says SSH is OPEN on both boxes.

  restart = "unless-stopped"
}
