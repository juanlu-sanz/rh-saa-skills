# Templates

Use these templates verbatim. Fill in every `[PLACEHOLDER]`.

---

## Top-Level `README.md`

```markdown
# PoC: [Short Issue Title]

## Issue Summary

[One paragraph describing the problem. Include: what was being attempted,
what went wrong, and the impact on the workload.]

## Environment

| Item | Value |
|---|---|
| OpenShift / Kubernetes version | [e.g., OpenShift 4.15] |
| Relevant Operators / components | [e.g., OpenShift Logging 5.8, ODF 4.14] |
| Cloud provider / platform | [e.g., AWS, bare metal, ROSA] |

## Repository Structure

| Folder | Purpose |
|---|---|
| [`01-problem-reproduction/`](./01-problem-reproduction/) | Reproduces the issue on an empty cluster |
| [`02-solution-[name]/`](./02-solution-[name]/) | Resolves the issue using [Red Hat product] |

## Quick Start

Start with [`01-problem-reproduction/`](./01-problem-reproduction/) to understand the issue,
then proceed to [`02-solution-[name]/`](./02-solution-[name]/) to apply the fix.
```

---

## `01-problem-reproduction/README.md`

```markdown
# Step 1 — Problem Reproduction

## Description

[One paragraph: what was configured, what was expected, and what actually happened.]

## Prerequisites

- OpenShift [version] cluster (fresh install is fine)
- `oc` CLI authenticated as cluster-admin
- [Any additional operator or tool required]

## Steps to Reproduce

1. Clone this repository:
   ```bash
   git clone https://github.com/[org]/[repo].git
   cd [repo]/01-problem-reproduction
   ```

2. Apply the manifests:
   ```bash
   oc apply -f *.yaml
   ```

3. Wait for resources to be ready:
   ```bash
   oc get pods -n [namespace] -w
   ```

4. Observe the failure:
   ```bash
   oc describe pod [pod-name] -n [namespace]
   oc logs [pod-name] -n [namespace]
   ```

## Expected (Broken) Output

```
[Paste the exact error message or broken state here]
```

## Why This Fails

[Technical explanation of the root cause. Reference relevant Kubernetes/OpenShift internals,
API fields, or known upstream issues if applicable.]
```

---

## `02-solution-<name>/README.md`

```markdown
# Step 2 — Solution: [Solution Name]

## Summary

[One paragraph: what this solution does. Name the component or operator used naturally
in the description — e.g. "...using ACM's PlacementRule to drive the cutover".]

## Prerequisites

- OpenShift [version] cluster
- [Operator name] installed via OperatorHub / OLM ([link to OperatorHub page])
- `oc` CLI authenticated as cluster-admin

## Steps to Apply the Fix

1. Install the [operator/component] if not already present:
   ```bash
   oc apply -f 01-subscription.yaml
   ```

2. Wait for the operator to be ready:
   ```bash
   oc get csv -n [namespace] -w
   ```

3. Apply the solution manifests:
   ```bash
   oc apply -f *.yaml
   ```

4. Verify the fix:
   ```bash
   oc get [resource] -n [namespace]
   oc describe [resource] [name] -n [namespace]
   ```

## Expected (Working) Output

```
[Paste the correct output / state that confirms the fix works]
```

## Official Documentation

<!-- Fill in real URLs — do not leave placeholders. Every operator, API, or feature
     referenced in this README must have a link here pointing to docs.redhat.com
     or docs.openshift.com. -->
- [Topic 1](https://docs.openshift.com/container-platform/[version]/[path])
- [Topic 2](https://docs.redhat.com/en/documentation/[product]/[version]/[path])
- [Upstream issue / KEP if relevant](https://github.com/kubernetes/enhancements/...)

## Alternatives Considered

| Approach | Notes |
|---|---|
| [This solution] | [Brief neutral description of how it works and any tradeoffs] |
| [Alternative 1] | [Brief neutral description] |
| [Alternative 2] | [Brief neutral description] |
```

---

## Example Manifest Annotations

Use inline comments to explain intent:

```yaml
# 01-deployment.yaml
# Purpose: Reproduces OOMKilled by omitting resource limits on a memory-hungry container.
# Remove this file and apply 02-solution-rh-limitrange/ to fix it.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memory-hog
  namespace: poc-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: memory-hog
  template:
    metadata:
      labels:
        app: memory-hog
    spec:
      containers:
        - name: memory-hog
          image: registry.access.redhat.com/ubi9/ubi:latest
          command: ["stress", "--vm", "1", "--vm-bytes", "512M"]
          # No resources.limits defined — this triggers OOMKilled
```

Always prefer `registry.access.redhat.com` or `registry.redhat.io` images over Docker Hub.
