# GLA: Build and configure the Campus Notifier platform

> **Format:** team of 3 to 5 on the same cloud, formed in class. One repo for both sessions. Everyone runs their own servers.
> **Time:** 60 minutes of drills in each session
> **Builds on:** Pre-Class 1 (your image on Docker Hub) and Pre-Class 2 (the same job, by hand)
> **Due:** 6 November 2026, 23:59 Kigali time

## Scenario

The Campus Notifier runs on a laptop, and students want a URL. In session 1 your team writes the servers as code: an app server and a database server on one network. Each of you then builds them on your own account. In session 2 you configure them with Ansible and deploy the image you published. The test at the end: could someone who isn't you rebuild all of it from this repo, without asking you anything?

## How the drills work

Each drill is one idea, done in order. The TODO comments are in the files. Each one says what to write, links the docs ("Read"), and says how to check it ("Done when"). The instructions get shorter as you go, so expect to read the docs more in the later drills.

No AI for Terraform or Ansible, same rule as Formative 3.

A drill's lead writes the code and opens a pull request. Someone reviews it and it merges. Then everyone pulls `main` and runs the drill's commands on their own laptop, against their own account. Each "Done when" applies to each of you.

Your facilitator shares a reference solution for session 1 after every cohort has had session 1, and one for session 2 after the due date. Using it is optional, and the team decides together, because it replaces your Terraform on `main`. If your team fell behind in session 1, take the first one and carry on.

## Shared code, separate servers

The team shares the code. Your servers, cloud account, SSH key, Terraform state and database password are your own.

**Never send anyone a cloud key, a password or a private SSH key, and don't put one in Git or a repo secret.** Nobody on your team needs yours.

| If | Then |
|---|---|
| Your credits are dead | Use the `local` track. It teaches the same Terraform and Ansible. Do its TODOs yourself as each drill comes up, because your team's pull requests change a different folder. |
| Your teammate's run works and yours doesn't | Compare the two outputs first. The code is the same, so the difference is your account, your IP or your laptop. |
| You miss session 1 | Join a team on your cloud in session 2, or ask your facilitator to place you. Pull `main` and do the session 2 Setup. |

Your credits pay for two small servers while you use them: during each session and during Pre-Class 2. Destroy them at the end of each one. Set a budget alert before you apply ([AWS](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-create.html), [Azure](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-acm-create-budgets)).

## Roles

Claim these in Setup. Each role leads its drills: you write the code and explain the result. Everyone still runs every command.

| Role | Session 1 | Session 2 | Reviews |
|---|---|---|---|
| **R1, state and pace** | Drill 1, checks that everyone is on the same commit | Sets `app_image`, checks that everyone is on the same commit | Everything before it merges |
| **R2, network and firewall** | Drills 2 and 4 | Drill 7 | Drill 3, drill 8 |
| **R3, machines and contract** | Drill 3 | Drill 8 | Drill 2, drill 9 |
| **R4, debugger and deployer** | Drill 6 | Drill 9 | Drill 4, drill 10 |
| **R5, steward** | Keeps the clock and `team-notes.md`, drill 5 | Drills 10 and 11, the teardown | All pull requests |

With 4 people, R4 also takes R5's job. With 3, R2 also takes R3's job.

---

# Session 1: Terraform

## Setup (5 minutes)

Form your team with people on your cloud. One person creates the team repo from the link your facilitator gives you and adds the others. Everyone clones. Claim roles and write them in `team-notes.md`. R1 commits the team's cloud with `echo aws > .track` (or `azure`, or `local`).

Everyone runs:

```bash
cd terraform/<your-track>
echo "my_ip_cidr = \"$(curl -s ifconfig.me)/32\"" > terraform.tfvars
```

`local` track only: `export DOCKER_HOST="$(docker context inspect --format '{{.Endpoints.docker.Host}}')"`

## Warm-up (5 minutes, no notes)

One question each. R5 writes a one-sentence answer per question in `team-notes.md`.

1. What is Terraform state, and why can't Terraform just ask the cloud what exists each time?
2. Your firewall allows port 22 in and has no outbound rule for replies. You run `ls` over SSH and see the output. How did it get back?
3. What does `0.0.0.0/0` mean? Who can reach port 22 if you put it in that rule?
4. `terraform apply` finishes and you have a server with a public IP. What's installed on it?

## Drill 1: Get the state off the laptop (R1, 8 minutes)

Without this, the only record of your servers is one file on your laptop. Everyone does steps 1 to 3 and step 5, and R1 does step 4.

1. In [HCP Terraform](https://app.terraform.io), create an organization `alu-devops-<your-name>`. Add a number if the name is taken.
2. Create a workspace with **CLI-Driven Workflow**, named exactly `campus-notifier-infra`.
3. Go to **Settings → General → Execution Mode**, choose **Local**, and save. HCP now stores and locks your state, and `plan` and `apply` still run on your laptop, so your cloud keys never leave it.
4. R1: in `terraform/<your-track>/versions.tf`, uncomment the `cloud` block and merge it. It names no organization, because each of you has your own. `local` track: uncomment it in your own folder.
5. Pull `main`, then in every terminal you use for Terraform:

   ```bash
   export TF_CLOUD_ORGANIZATION=alu-devops-<your-name>
   export TF_WORKSPACE=campus-notifier-infra
   terraform init
   ```

Read: [HCP Terraform CLI workflow](https://developer.hashicorp.com/terraform/cloud-docs/run/cli), [Execution modes](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings#execution-mode)

**Done when:** `terraform init` reports that HCP Terraform is initialized, and your workspace's **States** tab is open and empty. `local` track: same steps.

**Discussion (R5 records):** you all run the same code, and none of you can touch anyone else's servers. What in the repo is shared, and what stays out of it? What would have to change if the team ran one shared set of servers?

## Drill 2: Open the app's door (R2, 7 minutes)

Read `network.tf` aloud first. It's finished. Find the network's address range, the subnet's, and the line that decides whether a machine gets a public address.

Then do the `TODO (drill 2)` in `security.tf`. The `local` track has no firewall: read the top of `security.tf` and move on.

**Done when:** `terraform fmt && terraform validate` runs. Azure still fails on `network_interface_ids`, which is drill 3.

**Discussion (R5 records):** does a passing `validate` mean your firewall is correct? Name a mistake it can't catch.

## Drill 3: Finish the machine and the contract (R3, 8 minutes)

Do the `TODO (drill 3)` in `compute.tf` and `outputs.tf`. `terraform/CONTRACT.md` lists every output by name. `local` track: leave the `TODO (drill 6)` in `compute.tf` alone for now.

**Done when:** `terraform validate` says `Success!` on your track.

**Discussion (R5 records):** Azure's `validate` caught the missing network card. AWS would have passed without a subnet or a firewall. Why the difference, and what did you get instead of an error?

## Drill 4: Let only the app reach the database (R2, 6 minutes)

`database.tf` is written: a second machine on the same network, with a public IP so it can reach `apt` without a paid NAT gateway. A production database wouldn't have one. Its firewall is what keeps it private here.

Do the `TODO (drill 4)` in `database.tf`.

**Done when:** `terraform validate` says `Success!`, and R2 can say why this rule's source isn't the one the app's rule uses.

**Discussion (R5 records):** what would an attacker need in order to reach Postgres now? What would a private subnet add, and what would it cost?

## Drill 5: Plan, lock, apply (R5 leads, 10 minutes)

Predict first: how many resources will `plan` add? R5 writes the number down.

```bash
terraform plan
```

Compare. If the number's wrong, find out why before you apply.

Now start `terraform apply` in two terminals on your laptop at the same moment, with the Drill 1 exports set in both. One stops with `Error acquiring the state lock`, and that's the answer to two people applying at once. Cancel that one. In the other, type `yes`.

AWS takes 2 to 4 minutes, Azure 3 to 6, and `local` about 2. Refresh the HCP **States** tab while you wait.

**Done when:** `Apply complete!` shows your outputs, and a state version appears in your HCP workspace.

## Drill 6: Your server is unreachable (R4, 8 minutes)

```bash
python3 ../../scripts/verify_infra.py
```

Read the output before anyone speaks. One SSH port isn't `OPEN`. Before you open a file, answer aloud: did your packets reach the machine? So is the bug in the machine or in a rule? What does the database's result tell you?

Find it and fix it in one pull request. Then everyone pulls, applies and verifies again. `local` track: this is the `TODO (drill 6)`.

Read: the `probe` function in `scripts/verify_infra.py`, [Security group rules](https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html), [NSG rules](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview#security-rules)

**Done when:** SSH is `OPEN` on both machines, the app port is `REFUSED`, Postgres is `TIMED OUT` (`REFUSED` on `local`), and `terraform plan` says `No changes`. Paste one member's output in `team-notes.md`.

The app port's `REFUSED` is correct: you reached the machine and nothing is listening yet. On `local` it can say `OPEN`, because Docker holds a published port open even with nothing behind it. Postgres times out from your laptop because your laptop isn't the app server.

**Discussion (R5 records):** that bug passed `validate` and `plan`, and applied with no errors. What kind of check would have caught it?

## Close (3 minutes)

**Everyone destroys their servers.** Session 2 builds them again from this code, and your credits aren't spent in between. Run this while the round happens:

```bash
terraform destroy
terraform state list      # empty
```

Go round once: "I owned X. The decision I'd explain to a new teammate is Y, because Z." R5 commits `team-notes.md` and pushes.

---

# Session 2: Ansible

## Setup (5 minutes)

Pull `main`. Claim the session 2 role leads again if anyone is missing. Everyone rebuilds their servers, and the warm-up starts while that runs:

```bash
export TF_CLOUD_ORGANIZATION=alu-devops-<your-name>
export TF_WORKSPACE=campus-notifier-infra
cd terraform/<your-track>
echo "my_ip_cidr = \"$(curl -s ifconfig.me)/32\"" > terraform.tfvars   # your IP may have changed
terraform init
terraform apply
```

When the apply finishes:

```bash
python3 ../../scripts/verify_infra.py                                  # writes ansible/inventory.ini
cd ../../ansible
ansible-galaxy collection install -r requirements.yml
echo "db_password: $(openssl rand -hex 16)" > secrets.yml
```

Git ignores `secrets.yml` and `inventory.ini`, so your password stays on your laptop. R1 sets `app_image` in `group_vars/all.yml` to one member's image from Pre-Class 1 and merges it.

## Warm-up (5 minutes, no notes)

1. Ansible is "agentless". What must already be on a server for it to work?
2. What does idempotent mean? Give one everyday action that is and one that isn't.
3. A task says `state: present` and the package is already installed. What does Ansible do and report?
4. What's the difference between a module and `shell: apt install docker.io`?

## Drill 7: Can we talk to both machines? (R2, 5 minutes)

```bash
ansible all -m ping
ansible campus_notifier -m setup | grep -i virtualization
```

A `pong` proves that SSH, the user, the key and Python work. Check this first, so later errors point at the playbook.

Read: [How to build your inventory](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html), [Discovering facts](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html)

**Done when:** both hosts answer `pong`, and R2 can say what the virtualization facts say about your box.

## Drill 8: Read and run the database play (R3, 8 minutes)

The first play in `site.yml` is written. Read it aloud before you run it. Find the two separate things that had to agree before the app could connect (one is in `database.tf`). Compare it with what you typed in Pre-Class 2.

```bash
ansible-playbook site.yml --limit database
ansible-playbook site.yml --limit database
```

**Done when:** the second run says `changed=0`.

**Discussion (R5 records):** `pg_hba.conf` and the firewall both name the app server. Why have both?

## Drill 9: Make the box able to run containers (R4, 10 minutes)

Do the `TODO (drill 9)` in `site.yml`, using the fact you found in drill 7.

```bash
ansible-playbook site.yml --limit campus_notifier --skip-tags deploy
```

**Done when:** that run says `failed=0`, and `ansible campus_notifier -b -m shell -a "docker info | grep 'Storage Driver'"` prints `vfs` on `local` and anything else on a cloud VM.

## Drill 10: Deploy against the database (R5, 10 minutes)

Do the `TODO (drill 10)` in `site.yml`, then run the whole playbook once. If the app comes up wrong and you need another try, clear it first: `ansible campus_notifier -b -m shell -a "docker rm -f campus-notifier"`.

**Done when:** `curl http://<app-ip>:<app-port>/health/` from your laptop returns `{"status": "ok"}`, and the home page opens in a browser.

**Discussion (R5 records):** the `uri` task retries. What is it waiting for?

## Drill 11: Run it twice (R5, 10 minutes)

Run the same playbook again. Change nothing.

Read the failure. It prints the whole command, password included, on your screen. That's one more thing `shell` costs you, and it's tolerable today only because this password dies with the server this session. Why did only that task fail? What did Ansible know about that command? Replace it so it describes the container you want, using the [`docker_container` module](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_container_module.html). Keep the same name, image, ports, restart policy and database settings.

**Done when:** two runs in a row say `changed=0` on both hosts, and `/health/` still answers. Paste the recap in `team-notes.md`.

## Drill 12: Where does the data live? (R4, 4 minutes)

In Pre-Class 1 your event lived in SQLite inside the container. Make an admin user, then add an event at `/admin/`:

```bash
ADMIN_PASSWORD=$(openssl rand -hex 8); echo "$ADMIN_PASSWORD"
ansible campus_notifier -b -m shell -a "docker exec -e DJANGO_SUPERUSER_PASSWORD=$ADMIN_PASSWORD campus-notifier python manage.py createsuperuser --noinput --username admin --email admin@example.com"
```

Now delete the container and let the playbook bring it back:

```bash
ansible campus_notifier -b -m shell -a "docker rm -f campus-notifier"
ansible-playbook site.yml
```

**Done when:** your event is still on the home page. Say where it was stored, and why this differs from Pre-Class 1.

## Close and teardown (3 minutes)

R5 asks: the servers are about to go. How long would it take to get this running again on new machines, from this repo?

Everyone runs this while the round happens:

```bash
cd ../terraform/<your-track>
terraform destroy
terraform state list      # empty
```

Check your cloud portal too. Commit `team-notes.md` and push.

## Going further (optional, and useful for Formative 3)

- Run `terraform plan` on every pull request. The workflow in `.github/workflows/terraform.yml` starts you off.
- Add a firewall (UFW) and SSH hardening to the playbook, then move the tasks into a role.
- Move `db_password` into [Ansible Vault](https://docs.ansible.com/ansible/latest/vault_guide/index.html).

## Completion checklist

- [ ] Terraform and Ansible merged through pull requests, each with at least one review comment
- [ ] No key, password or state file anywhere in the repo
- [ ] `team-notes.md`: roles, warm-ups, discussions, `verify_infra.py` output, the `changed=0` recap, one line per member
- [ ] Every member has run `terraform destroy`, and one empty state list is in `team-notes.md`
