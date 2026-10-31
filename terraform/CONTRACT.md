# The Infrastructure Contract

Three tracks live in this directory: `aws/`, `azure/`, and `local/`. Your team picks **one** and stays on it.

They build different things using different vocabulary. What makes them interchangeable is this contract: **the same variables go in, and the same outputs come out.** The Ansible playbook reads only those outputs. It neither knows nor cares which cloud you used.

That is the point of the exercise. Infrastructure code is not "AWS code" or "Azure code": it is a description of an environment, and the environment has a shape that other tools depend on.

---

## What every track must accept (variables)

| Variable | Type | Default | Meaning |
|---|---|---|---|
| `project_name` | string | `campus-notifier` | Name prefix for every resource, so you can find (and delete) your own things |
| `app_port` | number | `8000` | The port the Campus Notifier's Django server listens on, set in its Dockerfile |
| `my_ip_cidr` | string | *(none: you must supply it)* | Your laptop's public IP, in CIDR form, e.g. `41.79.12.34/32`. Find it with `curl ifconfig.me` |

## What every track must produce (outputs)

| Output | Example | Who consumes it |
|---|---|---|
| `instance_public_ip` | `54.221.10.7` | Ansible (SSH target), `verify_infra.py` |
| `ssh_user` | `ubuntu` / `azureuser` / `root` | Ansible (`ansible_user`) |
| `app_port` | `8000` | Ansible (which port to expose), `verify_infra.py` |
| `instance_private_ip` | `10.0.1.4` | Ansible (Postgres allows this host) |
| `db_public_ip` | `54.221.10.8` | Ansible (SSH target), `verify_infra.py` |
| `db_private_ip` | `10.0.1.5` | Ansible (the app connects to this) |
| `db_ssh_port` | `22` (`2222` on `local`) | Ansible, `verify_infra.py` |

`database.tf` already defines the last four. You write the third row's output.

Nothing else is required. Nothing else is read.

---

## What every track must build

Whatever the provider calls them, all three tracks stand up the same five things:

1. **A private network** you own, with a defined address range.
2. **A subnet** inside it, with a route to the internet.
3. **A firewall** allowing inbound SSH (port 22) and inbound app traffic (`app_port`).
4. **One Linux machine** on that subnet, with a public address, reachable over SSH.
5. **A second Linux machine** for the database, reachable on 5432 only from the first.

| Concept | AWS | Azure | Docker (local) |
|---|---|---|---|
| Private network | VPC | Virtual Network (VNet) | user-defined bridge network |
| Subdivision | Subnet | Subnet | n/a |
| Firewall | Security Group | Network Security Group (NSG) | published ports |
| Public address | `associate_public_ip_address` | Public IP resource | host port binding |
| Route to internet | Internet Gateway + route table | mostly implicit | Docker's NAT |
| The machine | EC2 instance | Virtual Machine | container |

---

## Where the tracks stop

Terraform's job ends at **two empty, reachable Linux boxes.** Nothing is installed on them: no Campus Notifier, no Docker, no Postgres.

That is not an oversight: it is the boundary. `verify_infra.py` will show you SSH `OPEN` and the app port `REFUSED`. *Both are the correct result at the end of session 1.*

Closing that gap is a different job, done by a different category of tool, in session 2.
