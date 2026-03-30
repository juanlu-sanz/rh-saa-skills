# Ansible POC Templates

## Top-Level README.md

```markdown
# PoC: <Short Title>

<One paragraph describing the PoC goal, the customer scenario, and what is demonstrated.>

## Environment

| Component | Version |
|---|---|
| Red Hat Ansible Automation Platform | 2.x |
| RHEL (managed nodes) | 9.x |
| Ansible Core | 2.1x |

## Required Subscriptions

- Red Hat Ansible Automation Platform subscription
- Red Hat Enterprise Linux subscription

## Quick Start

1. Install required collections:

```bash
ansible-galaxy collection install -r requirements.yml \
  --server https://cloud.redhat.com/api/automation-hub/
```

2. Configure your inventory (`inventory/hosts.yml`) for your environment.

3. Run the PoC:

```bash
ansible-playbook playbooks/site.yml
```

## Repository Map

| Directory | Purpose |
|---|---|
| `inventory/` | Hosts, group variables, host variables |
| `playbooks/` | Entry-point playbooks (site.yml, verify.yml, …) |
| `roles/` | Reusable Ansible roles |
| `docs/` | Setup guide, procedures, and verification steps |

## References

- [Red Hat Ansible Automation Platform Documentation](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/)
- [Ansible Documentation](https://docs.ansible.com/)
```

---

## inventory/hosts.yml

```yaml
all:
  children:
    web:
      hosts:
        web01.example.com:
        web02.example.com:
    db:
      hosts:
        db01.example.com:
  vars:
    ansible_user: ansible
    ansible_become: true
```

## inventory/group_vars/all.yml

```yaml
# Variables shared across all groups.
# Sensitive values must be encrypted with ansible-vault:
#   ansible-vault encrypt_string 'mysecret' --name 'my_var'
```

---

## requirements.yml

```yaml
---
collections:
  - name: ansible.builtin
  - name: ansible.posix
  - name: redhat.rhel_system_roles
    source: https://cloud.redhat.com/api/automation-hub/

roles: []
```

---

## ansible.cfg

```ini
[defaults]
inventory          = inventory/hosts.yml
roles_path         = roles
collections_paths  = ~/.ansible/collections
host_key_checking  = False
stdout_callback    = yaml
```

---

## playbooks/site.yml

```yaml
# Description: Main entry point — imports all PoC playbooks in order.
---
- name: Import setup play
  ansible.builtin.import_playbook: deploy.yml

- name: Import verification play
  ansible.builtin.import_playbook: verify.yml
```

## playbooks/deploy.yml (example)

```yaml
# Description: <What this playbook achieves>
# Docs: <link to relevant official documentation>
---
- name: <Descriptive play name>
  hosts: all
  become: true
  gather_facts: true

  collections:
    - ansible.builtin
    - redhat.rhel_system_roles    # replace with actual collections

  pre_tasks:
    - name: Verify minimum Ansible version
      ansible.builtin.assert:
        that: ansible_version.full is version('2.14', '>=')
        msg: "Ansible 2.14 or higher is required"
      tags: always

  tasks:
    - name: <What the task achieves>
      ansible.builtin.<module>:
        # parameters
      tags: [configure]
      notify: Restart <service>

  handlers:
    - name: Restart <service>
      ansible.builtin.service:
        name: <service>
        state: restarted
```

---

## roles/<role-name>/tasks/main.yml

```yaml
---
# Role: <role-name>
# Description: <What this role does>
# Docs: <link to official documentation>

- name: Include setup tasks
  ansible.builtin.import_tasks: setup.yml
  tags: [setup]

- name: Include configuration tasks
  ansible.builtin.import_tasks: configure.yml
  tags: [configure]
```

## roles/<role-name>/defaults/main.yml

```yaml
---
# Default variables for <role-name>.
# All variables are documented here and safe to override.

# <var_name>: <description, type, example>
my_role_var: "default_value"
```

## roles/<role-name>/meta/main.yml

```yaml
---
galaxy_info:
  role_name: <role-name>
  author: <author>
  description: <one-line description>
  license: Apache-2.0
  min_ansible_version: "2.14"
  platforms:
    - name: EL
      versions: ["9"]

dependencies: []
```

---

## docs/setup.md

```markdown
# Setup

## Prerequisites

- Red Hat Ansible Automation Platform 2.x subscription
- RHEL 9.x managed nodes reachable via SSH
- Ansible Core 2.14+ on the control node

## Install Collections

```bash
ansible-galaxy collection install -r requirements.yml \
  --server https://cloud.redhat.com/api/automation-hub/
```

## Configure Inventory

Edit `inventory/hosts.yml` and replace placeholder hostnames with your managed nodes.
Add any host-specific variables to `inventory/host_vars/<hostname>.yml`.

## Vault Setup (if secrets are required)

```bash
ansible-vault create inventory/group_vars/vault.yml
# Add sensitive variables inside, e.g.:
# vault_db_password: "changeme"
```

Reference the vault file in your playbook run:
```bash
ansible-playbook playbooks/site.yml --vault-id @prompt
```
```

---

## docs/procedures.md

```markdown
# Procedures

## 1. Verify connectivity

```bash
ansible all -m ansible.builtin.ping
```

Expected: `pong` from all hosts.

## 2. Run the PoC

```bash
ansible-playbook playbooks/site.yml
```

## 3. Run only a specific phase

```bash
ansible-playbook playbooks/site.yml --tags configure
```

## 4. Verify the end state

```bash
ansible-playbook playbooks/verify.yml
```
```
