# A stand-in for a cloud VM: Ubuntu 22.04, systemd as PID 1, and an SSH daemon.
#
# Two things are here so that Ansible cannot tell the difference between this box
# and a real EC2 instance:
#
#   systemd   Ansible's `service` module talks to an init system. A cloud VM has
#             systemd; a normal container has no init at all, so `systemctl start
#             docker` would fail and half your playbook would be untestable. We
#             run systemd as PID 1 so that it doesn't.
#
#   python3   Ansible is agentless — but "agentless" does not mean "nothing on the
#             target". It needs an SSH daemon to talk to and a Python interpreter
#             to execute its modules. That is the entire dependency list.
#
# Docker is deliberately NOT installed. Installing it is the playbook's job, and
# pre-baking it would be marking your own homework.
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG SSH_PUBLIC_KEY

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        systemd systemd-sysv \
        openssh-server \
        sudo \
        python3 \
        ca-certificates \
        curl \
        gnupg \
    && rm -rf /var/lib/apt/lists/*

# The user Ansible logs in as. Matches ssh_user in outputs.tf, and therefore the
# ansible_user in the inventory that scripts/verify_infra.py generates.
RUN useradd --create-home --shell /bin/bash devops \
    && echo 'devops ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/devops \
    && chmod 0440 /etc/sudoers.d/devops

# Your PUBLIC key, baked in at build time. The private half never leaves your laptop.
RUN mkdir -p /home/devops/.ssh \
    && printf '%s\n' "$SSH_PUBLIC_KEY" > /home/devops/.ssh/authorized_keys \
    && chown -R devops:devops /home/devops/.ssh \
    && chmod 700 /home/devops/.ssh \
    && chmod 600 /home/devops/.ssh/authorized_keys

# Keys only, no passwords — the same baseline the cloud tracks enforce.
RUN sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
    && mkdir -p /run/sshd \
    && systemctl enable ssh

# systemd in a container tries to start units that make no sense here (udev,
# filesystem mounts). Strip them, or the boot hangs.
RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
          /etc/systemd/system/*.wants/* \
          /lib/systemd/system/local-fs.target.wants/* \
          /lib/systemd/system/sockets.target.wants/*udev*

# Put back the two units we actually need, AFTER the purge above.
#
# systemd-user-sessions is not optional, and its absence is vicious. During boot
# systemd writes /run/nologin, and PAM then refuses every non-root login with:
#
#     "System is booting up. Unprivileged users are not permitted to log in yet."
#
# This unit is what deletes that file once boot completes. Without it the box
# boots, sshd runs, port 22 answers OPEN — and Ansible can never log in.
# Everything looks healthy and nothing works.
#
# Note it must be SYMLINKED, not `systemctl enable`d: it is a `static` unit with
# no [Install] section, so `enable` silently does nothing at all. The purge above
# removed the link that multi-user.target normally provides, so we restore it by
# hand.
RUN systemctl enable ssh \
    && mkdir -p /etc/systemd/system/multi-user.target.wants \
    && ln -sf /lib/systemd/system/systemd-user-sessions.service \
              /etc/systemd/system/multi-user.target.wants/systemd-user-sessions.service

# systemd expects SIGRTMIN+3 to mean "shut down cleanly" — not SIGTERM.
STOPSIGNAL SIGRTMIN+3

EXPOSE 22
CMD ["/sbin/init"]
