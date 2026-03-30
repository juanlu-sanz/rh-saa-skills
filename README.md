# rh-saa-skills

Claude Code plugin marketplace for Red Hat Solution Architects. Provides AI-assisted skills for generating structured proof-of-concept repositories.

## Available Plugins

| Plugin | Description |
|---|---|
| **openshift-poc** | Generates structured OpenShift PoC repos — bug reproductions, feature demos, and capability setups with Red Hat products |
| **ansible-poc** | Generates structured Ansible PoC repos — customer demos and automation scenarios using Red Hat AAP and certified collections |

## Quick Start

### 1. Add the marketplace

From inside Claude Code, run:

```
/plugin marketplace add juanlu-sanz/rh-saa-skills
```

### 2. Install a plugin

```
/plugin install openshift-poc@rh-saa-skills
```

```
/plugin install ansible-poc@rh-saa-skills
```

### 3. Use the skills

Once installed, the skills activate automatically based on context. Ask Claude Code to create a PoC and it will follow the skill's structure:

```
> Create an OpenShift PoC for reproducing OOMKilled pods without resource limits

> Create an Ansible POC for automating RHEL system hardening with RHEL System Roles
```

The skills are model-invoked — Claude detects when you're asking for a PoC and applies the right structure, templates, and Red Hat product preferences automatically.

## What Each Plugin Does

### openshift-poc

When triggered, Claude will scaffold a complete PoC repository with:

- Folder-per-step structure (`01-problem-reproduction/`, `02-solution-<name>/`, etc.)
- Valid, minimal OpenShift/Kubernetes YAML manifests
- README files with prerequisites, step-by-step instructions, and expected output
- Official Red Hat documentation links (docs.redhat.com, docs.openshift.com)
- Red Hat product preference table (ACS, ACM, ODF, Pipelines, etc.)

### ansible-poc

When triggered, Claude will scaffold a complete PoC repository with:

- Official Ansible directory layout (inventory, playbooks, roles, docs)
- `ansible.cfg`, `requirements.yml`, and `inventory/hosts.yml`
- Playbooks using FQCNs and explicit collection declarations
- Verification playbook (`verify.yml`) for smoke testing
- `docs/` folder with setup, procedures, and verification guides
- Only Red Hat Certified or Validated Collections

## Local Development

To test the plugins locally without adding the marketplace:

```bash
# Test a single plugin
claude --plugin-dir ./plugins/openshift-poc

# Test both plugins
claude --plugin-dir ./plugins/openshift-poc --plugin-dir ./plugins/ansible-poc
```

Inside Claude Code, reload after making changes:

```
/reload-plugins
```

## Validating

Run the built-in validator to check plugin structure:

```bash
claude plugin validate ./plugins/openshift-poc
claude plugin validate ./plugins/ansible-poc
```

## Repository Structure

```
rh-saa-skills/
├── .claude-plugin/
│   └── marketplace.json            # Marketplace catalog
├── plugins/
│   ├── openshift-poc/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json         # Plugin manifest
│   │   └── skills/
│   │       └── openshift-poc/
│   │           ├── SKILL.md         # Skill instructions
│   │           └── templates.md     # README/YAML templates
│   └── ansible-poc/
│       ├── .claude-plugin/
│       │   └── plugin.json          # Plugin manifest
│       └── skills/
│           └── ansible-poc/
│               ├── SKILL.md         # Skill instructions
│               └── templates.md     # Playbook/role templates
└── README.md
```

## Requirements

- Claude Code **1.0.33** or later (`claude --version` to check)
- A GitHub-hosted copy of this repository (for marketplace installs)

## Contributing

Contributions are welcome. Follow the steps below to add a new skill or improve an existing one.

### Adding a new plugin

1. Create the plugin directory:

```bash
mkdir -p plugins/<plugin-name>/.claude-plugin
mkdir -p plugins/<plugin-name>/skills/<skill-name>
```

2. Create the plugin manifest at `plugins/<plugin-name>/.claude-plugin/plugin.json`:

```json
{
  "name": "<plugin-name>",
  "description": "One-line description of what the plugin does",
  "version": "1.0.0",
  "author": {
    "name": "Your Name",
    "email": "you@redhat.com"
  },
  "keywords": ["relevant", "tags"],
  "license": "Apache-2.0"
}
```

3. Write the skill instructions in `plugins/<plugin-name>/skills/<skill-name>/SKILL.md`. The file needs YAML frontmatter with `name` and `description`, followed by the full instructions Claude should follow:

```markdown
---
name: my-skill
description: >-
  When and why Claude should activate this skill.
  Be specific about trigger phrases.
---

# Skill Title

Instructions for Claude go here...
```

4. Register the plugin in `.claude-plugin/marketplace.json` by adding an entry to the `plugins` array:

```json
{
  "name": "<plugin-name>",
  "source": "./plugins/<plugin-name>",
  "description": "Same description as in plugin.json"
}
```

5. Validate and test:

```bash
# Validate structure
claude plugin validate ./plugins/<plugin-name>

# Test locally
claude --plugin-dir ./plugins/<plugin-name>
```

### Modifying an existing plugin

1. Edit the `SKILL.md` and/or `templates.md` files under the plugin's `skills/` directory.
2. Bump the `version` in the plugin's `plugin.json` (follow [semver](https://semver.org/) — patch for fixes, minor for new features, major for breaking changes).
3. Test locally with `claude --plugin-dir ./plugins/<plugin-name>` and run `/reload-plugins` after changes.
4. Open a pull request with a clear description of what changed and why.

### Skill writing guidelines

- Write all content in English.
- Be prescriptive — tell Claude exactly what structure, files, and conventions to produce.
- Include a quality checklist at the end so Claude can self-verify.
- Link to official Red Hat documentation (`docs.redhat.com`, `docs.openshift.com`, `docs.ansible.com`) — never to unofficial blogs or community forums.
- If the skill references templates, put them in a `templates.md` file alongside the `SKILL.md`.

### Pull request process

1. Fork this repository and create a feature branch.
2. Make your changes.
3. Validate all plugins: `claude plugin validate ./plugins/<name>`.
4. Test the skill end-to-end by running Claude Code with `--plugin-dir` and asking it to generate a PoC.
5. Open a PR against `main`. Include:
   - What plugin was added or changed
   - A sample prompt and summary of the output Claude produces
   - Confirmation that `claude plugin validate` passes

## Maintainer

Juanlu Sanz (jsanzmor@redhat.com)

## License

Apache-2.0
