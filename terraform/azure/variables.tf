# Every track accepts these three. See ../CONTRACT.md.

variable "project_name" {
  description = "Prefix for every resource name, so you can find and delete your own things."
  type        = string
  default     = "campus-notifier"
}

variable "app_port" {
  description = "The port the Campus Notifier's Django server listens on (set in its Dockerfile)."
  type        = number
  default     = 8000
}

variable "my_ip_cidr" {
  description = <<-EOT
    Your laptop's public IP address in CIDR form, e.g. "41.79.12.34/32".

    Find it with:  curl ifconfig.me

    The /32 on the end means "exactly this one address, nothing else".
    Set it in terraform.tfvars — never commit that file.
  EOT
  type        = string
}

# ── Track-specific (Azure only) ──────────────────────────────────────────────

variable "location" {
  description = "Azure region. westeurope has reliable Standard_B1s capacity."
  type        = string
  default     = "westeurope"
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

variable "vnet_cidr" {
  description = "Address range for the whole private network. /16 = 65,536 addresses."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Address range for the subnet, carved out of vnet_cidr. /24 = 256 addresses."
  type        = string
  default     = "10.0.1.0/24"
}
