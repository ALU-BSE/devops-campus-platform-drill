# Every track accepts these three. See ../CONTRACT.md.

variable "project_name" {
  description = "Prefix for every resource name, so you can find and delete your own things."
  type        = string
  default     = "campus-notifier"
}

variable "app_port" {
  description = <<-EOT
    The port the Campus Notifier is reachable on.

    The default matches the cloud tracks. If something on your laptop already
    uses 8000 (a Django dev server often does), change it here. One
    environment-specific value absorbs the difference: the interface does not
    change, and session 2's Ansible does not change.
  EOT
  type        = number
  default     = 8000
}

variable "my_ip_cidr" {
  description = <<-EOT
    Your laptop's public IP in CIDR form, e.g. "41.79.12.34/32".

    On this track it is not enforced by anything — Docker has no firewall to
    apply it to. It stays in the interface anyway, because the CONTRACT is the
    same for every track. Keeping a variable you do not use is the price of a
    stable interface, and that is a real engineering trade-off, not an oversight.
  EOT
  type        = string
  default     = "0.0.0.0/0"
}

# ── Track-specific (local only) ──────────────────────────────────────────────

variable "docker_host" {
  description = <<-EOT
    Where the Docker daemon is listening.

    Leave this null. The provider will then read the DOCKER_HOST environment
    variable, which you set once per terminal with:

        export DOCKER_HOST="$(docker context inspect --format '{{.Endpoints.docker.Host}}')"

    See the comment in versions.tf for why this is necessary on macOS.
  EOT
  type        = string
  default     = null
}

variable "ssh_public_key_path" {
  description = <<-EOT
    Path to the PUBLIC half of the SSH key you will log in with.

    Generate a dedicated key for this course (pre-work) so you never put your
    personal key on a throwaway server:

        ssh-keygen -t rsa -b 4096 -f ~/.ssh/alu-devops -N ""

    RSA, deliberately: AWS accepts RSA and ed25519, but Azure's VM resource is
    strict about RSA. One key that works on every track beats three that don't.

    Your PRIVATE key (~/.ssh/alu-devops, no .pub) never leaves your laptop and
    is never committed. That is the entire point of key-based auth.
  EOT
  type        = string
  default     = "~/.ssh/alu-devops.pub"
}

variable "network_cidr" {
  description = "Address range for the user-defined bridge network."
  type        = string
  default     = "10.0.0.0/16"
}
