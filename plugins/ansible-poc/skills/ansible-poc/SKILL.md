---
name: ansible-poc
description: >-
  Creates a structured GitHub repository for Ansible proof of concepts, customer demos,
  or automation scenarios using official Red Hat Ansible Automation Platform (AAP) products
  and Red Hat Certified Ansible Collections. Use when the user asks to create an Ansible POC,
  Ansible Customer POC, Ansible PoC, Ansible demo repository, or says something like
  "I need an Ansible POC", "create an Ansible proof of concept", or
  "set up an Ansible customer demo".
---

# Ansible POC

Creates a GitHub repository following the official Ansible recommended directory layout.
The PoC can be:

- **Feature demo** — showcases an Ansible Automation Platform capability end to end.
- **Customer scenario** — automates a real customer use case with production-grade patterns.
- **Integration demo** — shows Ansible working with another Red Hat product (Satellite, Insights, OpenShift, etc.).

All content must be written in English. Use only official Red Hat Certified Collections and
reference official Red Hat documentation for every module, role, or feature used.

Reference: [Ansible Sample Setup](https://docs.ansible.com/ansible/latest/tips_tricks/sample_setup.html)

---

## Repository Structure

```
poc-<short-slug>/
├── README.md
├── ansible.cfg
├── requirements.yml          # collection and role dependencies
├── inventory/
│   ├── hosts.yml             # managed nodes
│   ├── group_vars/
│   │   └── all.yml           # variables shared across all groups
│   └── host_vars/            # per-host variables (if needed)
├── playbooks/
│   ├── site.yml              # main entry-point playbook
│   ├── <concern>.yml         # one playbook per logical concern
│   └── verify.yml            # idempotency / smoke-test playbook
├── roles/
│   └── <role-name>/
│       ├── tasks/
│       │   └── main.yml
│       ├── handlers/
│       │   └── main.yml
│       ├── templates/        # Jinja2 templates (.j2)
│       ├── files/            # static files for copy/script modules
│       ├── vars/
│       │   └── main.yml      # role variables (higher priority)
│       ├── defaults/
│       │   └── main.yml      # role defaults (lowest priority)
│       └── meta/
│           └── main.yml      # role metadata and dependencies
└── docs/
    ├── setup.md              # environment prerequisites and installation
    ├── procedures.md         # step-by-step guide to run the PoC
    └── verification.md       # how to validate expected outcomes
```

Keep roles focused on a single concern. Use separate playbooks per logical operation rather
than one monolithic `site.yml` when the PoC has multiple distinct phases.

---

## Key Files

### ansible.cfg

Minimal config scoped to this repo — do not rely on system-wide defaults:

```ini
[defaults]
inventory          = inventory/hosts.yml
roles_path         = roles
collections_paths  = ~/.ansible/collections
host_key_checking  = False
stdout_callback    = yaml
```

### requirements.yml

Declare **all** collection dependencies — never assume collections are pre-installed:

```yaml
---
collections:
  - name: ansible.builtin
  - name: redhat.rhel_system_roles
    source: https://cloud.redhat.com/api/automation-hub/
  # add further collections here

roles: []
```

Install with:
```bash
ansible-galaxy collection install -r requirements.yml
# Prefer Automation Hub for customer PoCs (certified content):
ansible-galaxy collection install -r requirements.yml \
  --server https://cloud.redhat.com/api/automation-hub/
```

Reference: [Automation Hub](https://console.redhat.com/ansible/automation-hub)

---

## Inventory

Use YAML format. Group variables in `inventory/group_vars/`, host variables in
`inventory/host_vars/`. Never put secrets in inventory files — use `ansible-vault`.

- Reference: [Ansible Inventory Guide](https://docs.ansible.com/ansible/latest/inventory_guide/index.html)
- Reference: [AAP Inventory Management](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/latest/html/automation_controller_user_guide/controller-inventories)

---

## Playbooks

- One playbook per logical concern (`deploy.yml`, `configure.yml`, `verify.yml`).
- `site.yml` imports the other playbooks in order and serves as the single entry point.
- Always declare `collections:` explicitly in each play — never rely on implicit FQCN resolution.
- Use FQCNs for all modules: `ansible.builtin.template`, not just `template`.
- Annotate each playbook with a `# Description:` header comment.

```yaml
# Description: <what this playbook achieves>
---
- name: <Descriptive play name>
  hosts: all
  become: true
  gather_facts: true

  collections:
    - ansible.builtin
    - redhat.rhel_system_roles    # replace with actual collections

  tasks:
    - name: <What the task achieves, not what it does>
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

## Roles

Create a role when logic is reused across playbooks or the task list exceeds ~20 tasks.
Initialize with `ansible-galaxy role init roles/<role-name>`.

- `tasks/main.yml` — task entry point; import sub-task files for clarity.
- `defaults/main.yml` — user-overridable defaults; document every variable.
- `vars/main.yml` — role-internal constants not intended to be overridden.
- `meta/main.yml` — set `galaxy_info` and list role dependencies.
- No hardcoded secrets anywhere in roles; use `ansible-vault` encrypted vars.

Reference: [Roles — Ansible Docs](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html)

---

## docs/ — Procedures and Verification

All human-readable step-by-step instructions live in `docs/`, keeping automation code and
prose separate.

### docs/setup.md — must include:
- Environment requirements: AAP version, RHEL version, required subscriptions
- How to install collections: `ansible-galaxy collection install -r requirements.yml`
- How to configure inventory for the PoC environment
- Any `ansible-vault` setup needed for secrets

### docs/procedures.md — must include:
- Step-by-step commands to run the PoC in order
- Exact `ansible-playbook` invocations with relevant flags (`-i`, `--tags`, `--vault-id`)
- Expected output for each step

### docs/verification.md — must include:
- How to run `playbooks/verify.yml` and what a passing run looks like
- Manual checks (if any) with exact commands and expected output
- Links to official docs for every feature or module being verified

---

## Ansible Best Practices

- **FQCNs everywhere** — `ansible.builtin.template`, not `template`.
- **Idempotency** — every task must be safe to run multiple times; document exceptions.
- **Tags** — tag tasks (`setup`, `configure`, `verify`) for selective execution.
- **Handlers** — use handlers for service restarts; never `ansible.builtin.command: systemctl restart`.
- **No hardcoded secrets** — encrypt with `ansible-vault`; document vault usage in `docs/setup.md`.
- **Variable precedence** — put overridable defaults in `defaults/`, role constants in `vars/`.

Reference: [Red Hat Ansible Best Practices](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/latest/html/getting_started_with_playbooks/index)

---

## Approved Collections

Use **only** Red Hat Certified or Red Hat Validated Collections.

| Use Case | Collection | Documentation |
|---|---|---|
| Core modules | `ansible.builtin` | [ansible/builtin](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/) |
| POSIX / files / users | `ansible.posix` | [ansible/posix](https://docs.ansible.com/ansible/latest/collections/ansible/posix/) |
| RHEL System Roles | `redhat.rhel_system_roles` | [RHEL System Roles](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/latest/html/administration_and_configuration_tasks_using_system_roles_in_rhel/index) |
| AAP Controller API | `ansible.controller` | [Controller Collection](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/latest/html/automation_controller_user_guide/index) |
| AAP Hub | `ansible.hub` | [Private Automation Hub](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/latest/html/managing_red_hat_certified_and_ansible_galaxy_collections_in_automation_hub/index) |
| Red Hat Satellite | `redhat.satellite` | [Satellite Ansible Modules](https://docs.redhat.com/en/documentation/red_hat_satellite/latest/html/managing_configurations_using_ansible_integration_in_red_hat_satellite/index) |
| Red Hat Insights | `redhat.insights` | [Insights Collection](https://docs.redhat.com/en/documentation/red_hat_insights/latest) |
| OpenShift / Kubernetes | `redhat.openshift` / `kubernetes.core` | [OpenShift Collection](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/playbook_reference/index) |
| Networking (validated) | `network.base` | [Network Validated Content](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/latest/html/getting_started_with_ansible_network_automation/index) |
| IdM / FreeIPA | `redhat.rhel_idm` | [IdM System Roles](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/latest/html/automating_system_administration_by_using_rhel_system_roles/index) |

---

## Top-Level README.md

Must include:

- **Title** and one-paragraph summary (what the PoC demonstrates and for whom)
- **Environment** — AAP version, RHEL version, required subscriptions
- **Quick start** — `ansible-galaxy collection install -r requirements.yml` then the first `ansible-playbook` command
- **Repository map** — table describing each top-level directory
- **References** — all official Red Hat and Ansible documentation links used in the PoC

---

## Documentation Sources

Cite documentation inline in every `docs/` file. Preferred sources (in order):

1. [Red Hat Ansible Automation Platform Docs](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/)
2. [Ansible Upstream Docs](https://docs.ansible.com/)
3. [Red Hat Customer Portal KBs](https://access.redhat.com/solutions)
4. [AAP Console](https://console.redhat.com/ansible/)

Do **not** link to unofficial blogs, third-party tutorials, or community forum posts.

---

## Quality Checklist

Before finishing:

- [ ] All files are in English
- [ ] `ansible.cfg` is present and scoped to this repo
- [ ] `requirements.yml` lists every collection used, with Automation Hub as source
- [ ] Every playbook uses FQCNs and declares `collections:` explicitly
- [ ] No hardcoded secrets — all sensitive values use `ansible-vault`
- [ ] Every collection, module, or role links to official Red Hat or Ansible docs — no placeholder links
- [ ] All doc links point to `https://docs.redhat.com`, `https://docs.ansible.com`, or `https://console.redhat.com`
- [ ] `docs/setup.md` can be followed from scratch with zero prior context
- [ ] `playbooks/verify.yml` exists and validates the expected end state
- [ ] Playbooks are idempotent and tagged

---

## Additional Resources

- For file templates (README, playbook, role), see [templates.md](templates.md)
