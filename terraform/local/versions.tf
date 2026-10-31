terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      # Pinned exactly, not "~> 3.0". Two reasons, and the second one matters today:
      #
      # 1. Everyone on the team resolves the identical provider, so "works on my
      #    machine" cannot mean "different provider version on my machine".
      #
      # 2. Unlike the AWS and Azure providers (which HashiCorp serves from its own
      #    CDN), this one fetches its checksums from github.com/releases. On a
      #    throttled or filtered network that download fails with:
      #
      #        read: connection reset by peer
      #
      #    An exact pin means the provider cache you warmed in pre-work always
      #    hits, and the session never touches the network at all.
      version = "3.9.0"
    }
  }

  # ── DRILL 1 ───────────────────────────────────────────────────────────────
  # Uncomment this block. This is what moves your state OFF your laptop and into
  # a locked, remote backend.
  #
  # It names no organization or workspace, because each of you has your own.
  # They come from TF_CLOUD_ORGANIZATION and TF_WORKSPACE (see drill 1).
  #
  # cloud {}
  # ───────────────────────────────────────────────────────────────────────────
}

provider "docker" {
  # Left unset on purpose, so the provider falls back to the DOCKER_HOST
  # environment variable.
  #
  # Docker Desktop on macOS does NOT create /var/run/docker.sock (the path every
  # tool assumes) unless you tick "Allow the default Docker socket to be used" in
  # its settings. So before your first apply, run:
  #
  #     export DOCKER_HOST="$(docker context inspect --format '{{.Endpoints.docker.Host}}')"
  #
  # That command works on macOS, Linux and WSL — it asks Docker where Docker is,
  # rather than assuming. If you skip it you will get:
  #
  #     Cannot connect to the Docker daemon at unix:///var/run/docker.sock
  #
  # which reads like "Docker is not running" and is not. Docker is running; your
  # provider is looking in the wrong place.
  host = var.docker_host
}
