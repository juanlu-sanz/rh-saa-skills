---
name: openshift-poc
description: >-
  Creates a structured GitHub repository to demonstrate, reproduce, or set up anything OpenShift-related
  using Red Hat products — whether that is a bug reproduction, a new feature setup, or a capability demo.
  Use only when the user explicitly asks to create an OpenShift PoC, create an OpenShift POC,
  create a PoC for an OpenShift issue, or says something like "I need an OpenShift POC"
  or "create a POC for this OpenShift problem".
---

# PoC

Creates a GitHub repository with a clear folder-per-step structure. The PoC can be:

- **Bug / issue** — Step 1 reproduces the problem; Step 2+ resolves it.
- **New feature or capability** — Step 1 covers prerequisites and base setup; Step 2+ shows the feature working.

Choose folder names that match the context. All content must be written in English.

---

## Repository Structure

For a **bug / issue** PoC:
```
poc-<short-issue-slug>/
├── README.md
├── 01-problem-reproduction/
│   ├── README.md
│   └── *.yaml
└── 02-solution-<approach-name>/
    ├── README.md
    └── *.yaml
```

For a **feature / capability** PoC:
```
poc-<short-feature-slug>/
├── README.md
├── 01-setup/
│   ├── README.md
│   └── *.yaml
└── 02-<feature-name>/
    ├── README.md
    └── *.yaml
```

Use descriptive folder names that reflect the actual content — `01-problem-reproduction`, `01-setup`, `01-prerequisites`, etc. Add more `0N-<name>/` folders for additional steps or solutions.

---

## Step 1 — First Folder

Name this folder to match the intent:

| PoC type | Example folder name |
|---|---|
| Bug reproduction | `01-problem-reproduction` |
| Feature setup | `01-setup` or `01-prerequisites` |
| Capability demo baseline | `01-base-cluster-config` |

**README.md must include:**
- One-paragraph description of what this step covers
- Prerequisites (cluster version, required operators/tools, permissions)
- Numbered steps (apply manifests, run `oc` commands, or both)
- Expected output — what a successful (or intentionally broken) state looks like
- For bug PoCs: a "Why this fails" explanation with a link to the relevant operator docs, release notes, or bug tracker when available

YAML files live directly in the folder alongside `README.md` — no `manifests/` subfolder. Only include YAML when it is part of the step. Annotate each file with its role.

---

## Step 2+ — Subsequent Folders

Name these folders to match the intent:

| PoC type | Example folder name |
|---|---|
| Bug fix | `02-solution-<approach>` |
| Feature demo | `02-<feature-name>` |
| Multi-step setup | `02-deploy`, `03-configure`, `04-verify` |

**Goal**: Show the feature working or the problem solved, using Red Hat products where they naturally fit.

**README.md must include:**
- Solution summary (one paragraph) — mention the Red Hat product(s) used in context, not as a sales pitch
- Prerequisites specific to this solution
- Numbered steps to apply the fix
- Expected (working) output — commands and their correct output
- **Official documentation links** — every operator, API, or feature referenced must link to `https://docs.redhat.com` or `https://docs.openshift.com`; do not leave doc links as placeholders
- Optional: an "Alternatives Considered" table that neutrally compares approaches

YAML files live directly in the folder alongside `README.md` — no `manifests/` subfolder. Solutions should be expressed as YAML whenever possible — prefer declarative OpenShift resources (Operator subscriptions, CRs, ConfigMaps, Routes, etc.) over manual `oc` commands.

---

## Red Hat Product Preference

Default to Red Hat / OpenShift-native components when they cover the use case:

| Problem Area | Default Choice |
|---|---|
| Networking / Ingress | OpenShift Route, OpenShift Service Mesh |
| Security policies | Red Hat Advanced Cluster Security (ACS) |
| Multi-cluster / GitOps | ACM, OpenShift GitOps (ArgoCD) |
| Pipelines / CI | OpenShift Pipelines (Tekton) |
| Monitoring / Alerting | OpenShift Monitoring (built-in Prometheus + Alertmanager) |
| Logging | OpenShift Logging (LokiStack) |
| Storage | OpenShift Data Foundation (ODF) |
| Image registry / scanning | Red Hat Quay, ACS |
| Operator lifecycle | OLM / OperatorHub |

Mention Red Hat products because they fit the solution, not to promote them. If an OSS alternative is relevant, list it in an "Alternatives Considered" table without loaded language.

---

## Top-Level README.md

Must include:
- Title and one-paragraph summary (bug description or feature goal)
- Environment (cluster version, relevant operators)
- Repo map with links to each subfolder
- Quick-start (which folder to go to first)

---

## Quality Checklist

Before finishing:
- [ ] All README files are in English
- [ ] Every YAML file is valid and minimal (no unnecessary fields)
- [ ] Folder names reflect the actual content (not hardcoded to "problem-reproduction" or "solution" if the PoC is a feature demo)
- [ ] Step 1 README can be followed on a clean cluster with zero prior context
- [ ] Bug PoCs: "Why this fails" links to relevant docs, release notes, or bug tracker when available
- [ ] Step 2+ README has a real doc link for every operator, API, or feature mentioned — no placeholder links
- [ ] All doc links point to `https://docs.redhat.com` or `https://docs.openshift.com`
- [ ] Red Hat products are mentioned in context, not in a dedicated sales paragraph
- [ ] Folder names use the `0N-` prefix for ordering
- [ ] Top-level README links to all subfolders

---

## Additional Resources

- For README and YAML templates, see [templates.md](templates.md)
