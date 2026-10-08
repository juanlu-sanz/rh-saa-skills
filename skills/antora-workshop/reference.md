# Reference Files

Exact boilerplate file contents to copy when creating a new workshop repository.
Adapt placeholders marked with `<...>` to match the new workshop.

---

## gulpfile.babel.js

Copy verbatim into the workshop root. No changes needed - it reads from
`dev-site.yml` and serves `gh-pages/`.

---

## lib/tab-block.js

Copy verbatim into `lib/`. AsciiDoc extension that enables tabbed content blocks.

---

## lib/remote-include-processor.js

Copy verbatim into `lib/`. AsciiDoc extension that allows `include::` directives
with HTTP URLs.

---

## supplemental-ui/

Copy the entire directory into the workshop root. Then update
`supplemental-ui/partials/footer-nav.hbs` to point to the new repo:

```hbs
<nav class="rhd-footer-nav" aria-label="Secondary Navigation" role="navigation">
  <ul class="rhd-menu">
    <li class="menu-item menu-item--expanded">
      <h3 class="section-toggle">Resources</h3>
      <ul class="rhd-menu">
        <li class="menu-item">
          <a href="https://<github-user>.github.io/<repo-name>" title="<Workshop Title>">Course
            Site</a>
        </li>
        <li class="menu-item">
          <a href="https://github.com/<github-user>/<repo-name>/issues" title="Issue Tracker">Issue
            Tracker</a>
        </li>
      </ul>
    </li>
  </ul>
</nav>
```

---

## site.sh

```bash
#!/bin/bash

_CURR_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
rm -rf $_CURR_DIR/gh-pages $_CURR_DIR/.cache

antora --pull --stacktrace  site.yml
```

---

## Dockerfile

```dockerfile
FROM docker.io/antora/antora as builder

ADD . /antora/

RUN antora generate --stacktrace site.yml

FROM registry.access.redhat.com/rhscl/httpd-24-rhel7

COPY --from=builder /antora/gh-pages/ /var/www/html/
```

---

## .github/workflows/docs.yml

```yaml
name: docs

on:
  push:
    branches:
      - main
      - master

permissions:
  contents: write

env:
  SITE_DIR: "gh-pages"

jobs:
  build_and_deploy:
    name: "Build and deploy site"
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: "Generate site using antora site action"
        uses: kameshsampath/antora-site-action@master
        with:
          antora_playbook: site.yml

      - name: Deploy to GitHub Pages
        uses: JamesIves/github-pages-deploy-action@v4
        with:
          folder: ${{ env.SITE_DIR }}
          branch: gh-pages
          commit-message: "[CI] Publish Documentation for ${{ github.sha }}"
```

---

## package.json Template

```json
{
  "name": "<repo-name>",
  "description": "<Workshop Title> - Course Documentation Site",
  "homepage": "https://<github-user>.github.io/<repo-name>",
  "dependencies": {
    "@antora/cli": "^2.3.1",
    "@antora/site-generator-default": "^2.3.1",
    "@babel/cli": "^7.5.5",
    "@babel/core": "^7.5.5",
    "@babel/polyfill": "^7.4.4",
    "@babel/preset-env": "^7.5.5",
    "@babel/register": "^7.5.5",
    "browser-sync": "^2.26.7",
    "fs-extra": "^8.1.0",
    "gulp": "^4.0.0",
    "yaml-js": "^0.2.3"
  },
  "devDependencies": {},
  "scripts": {
    "dev": "gulp",
    "clean": "gulp clean",
    "workshop": "gulp workshopSite"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/<github-user>/<repo-name>.git"
  },
  "license": "Apache-2.0",
  "babel": {
    "presets": [
      "@babel/preset-env"
    ]
  }
}
```

---

## antora.yml Template

```yaml
name: <workshop-slug>
title: <Workshop Title>
version: master
nav:
  - modules/ROOT/nav.adoc
start_page: ROOT:index.adoc
```

---

## site.yml Template

```yaml
runtime:
  cache_dir: ./.cache/antora

site:
  title: <Workshop Title>
  url: https://<github-user>.github.io/<repo-name>
  start_page: <workshop-slug>::index.adoc

content:
  sources:
    - url: ./
      branches: HEAD
      start_path: documentation

asciidoc:
  attributes:
    release-version: master
    page-pagination: true
  extensions:
    - ./lib/tab-block.js
    - ./lib/remote-include-processor.js

ui:
  bundle:
    url: https://github.com/redhat-developer-demos/rhd-tutorial-ui/releases/download/v0.1.10/ui-bundle.zip
    snapshot: true
  supplemental_files:
    - path: ./supplemental-ui
    - path: .nojekyll
    - path: ui.yml
      contents: "static_files: [ .nojekyll ]"

output:
  dir: ./gh-pages
```

---

## dev-site.yml Template

```yaml
runtime:
  cache_dir: ./.cache/antora

site:
  title: <Workshop Title> (Dev Mode)
  url: http://localhost:3000
  start_page: <workshop-slug>::index.adoc

content:
  sources:
    - url: .
      branches: HEAD
      start_path: documentation
asciidoc:
  attributes:
    title: <Workshop Title> (Dev Mode)
  extensions:
    - ./lib/remote-include-processor.js
    - ./lib/tab-block.js
ui:
  bundle:
    url: https://github.com/redhat-developer-demos/rhd-tutorial-ui/releases/download/v0.1.10/ui-bundle.zip
    snapshot: true
  supplemental_files: ./supplemental-ui
output:
  dir: ./gh-pages
```

---

## _attributes.adoc Template

```asciidoc
:experimental:
:source-highlighter: highlightjs
:title: <Workshop Title>
:hub-context: hub
:cluster-a-context: cluster-a
:cluster-b-context: cluster-b
:<product-1>-version: X.Y+
:<product-2>-version: X.Y+
```

Adapt the context names and product versions to match the workshop topic. For
single-cluster workshops, remove the multi-cluster context attributes.

---

## index.adoc Template

```asciidoc
= <Workshop Title>
:page-layout: home
:!sectids:
include::_attributes.adoc[]

[.text-center.strong]
== <Workshop Tagline>

<One-paragraph workshop description.>

[.tiles.browse]
== Browse Modules

[.tile]
.xref:00-setup.adoc[Cluster Setup]
* xref:00-setup.adoc#prerequisites[Prerequisites]
* xref:00-setup.adoc#export-variables[Export Variables]

[.tile]
.xref:01-<step>.adoc[Step 0: <Title>]
* xref:01-<step>.adoc#anchor[Sub-step]

== Environment

[cols="2,3",options="header"]
|===
| Item | Value
| OpenShift version | {ocp-version}
|===
```

---

## nav.adoc Template

```asciidoc
* xref:index.adoc[Overview]
* xref:00-setup.adoc[Cluster Setup]
** xref:00-setup.adoc#export-variables[Export Workshop Variables]
** xref:00-setup.adoc#login-clusters[Log In to Clusters]
* xref:01-<step>.adoc[Step 0: <Title>]
** xref:01-<step>.adoc#anchor[Sub-step]
* xref:02-<step>.adoc[Step 1: <Title>]
** xref:02-<step>.adoc#anchor[Sub-step]
```

---

## Step Page Template

```asciidoc
= Step N - Title: Descriptive Subtitle
include::_attributes.adoc[]

<One-paragraph description of what this step does, what problem it solves,
and how it builds on the previous step.>

== Prerequisites

* <Prerequisite 1>
* <Previous step> from xref:previous-page.adoc[Step N-1] fully operational
* `oc` CLI authenticated as cluster-admin
* Contexts renamed as described in the xref:00-setup.adoc[Cluster Setup] section

NOTE: <Any important context or assumptions.>

== How It Works

<Brief architectural explanation. Use numbered lists or diagrams.>

== Steps to Apply

[#anchor-1]
=== 1. First sub-step title

*What:* One sentence describing the concrete action.

*Why:* One sentence explaining why this step matters.

[.console-input]
[source,bash,subs="+macros,+attributes"]
----
oc apply -f NN-step/resource.yaml --context cluster-a
----

.Verify: Description of what to check
[%collapsible]
====
[.console-input]
[source,bash,subs="+macros,+attributes"]
----
oc get <resource> --context cluster-a
----

[.console-output]
[source,bash]
----
<expected output>
----
====

'''

[#anchor-2]
=== 2. Second sub-step title

*What:* ...

*Why:* ...

...

'''

== What This Solves (Compared to Step N-1)

[cols="2,3",options="header"]
|===
| Problem from Step N-1 | How This Step Solves It

| <problem>
| <solution>
|===

== What This Does NOT Solve (Yet)

[cols="2,3",options="header"]
|===
| Remaining Problem | Addressed In

| <problem>
| xref:next-step.adoc[Step N+1]
|===

== Official Documentation

* link:https://docs.redhat.com/...[<Product Documentation>]

== Alternatives Considered

[cols="2,4",options="header"]
|===
| Approach | Notes

| <This solution>
| <Why chosen>

| <Alternative>
| <Why not chosen>
|===

'''

== Reset

<Brief explanation of what the reset does and why the order matters.>

[.console-input]
[source,bash]
----
<undo commands in reverse order, all with --ignore-not-found>
----
```

---

## .cursor/rules/workshop-conventions.mdc Template

```markdown
---
description: Conventions for the <workshop-title> workshop
globs: "**/*.adoc,**/*.yaml,**/*.yml"
alwaysApply: false
---

# Workshop Conventions

## Repository Purpose

<One-paragraph description of the workshop.>

## Structure

- `documentation/` contains all AsciiDoc courseware content (Antora component)
- `documentation/modules/ROOT/pages/` contains the course pages in `.adoc` format
- YAML manifests live in the root step directories
- <list each step directory and its purpose>
- Steps are progressive: each builds on the previous one

## AsciiDoc Formatting

- Every numbered step must have a *What* and *Why* pair in bold
- Every step must have a collapsible verification block
- Use `[.console-input]` before source blocks for commands
- Use `[.console-output]` before source blocks showing expected output
- Reference YAML manifests by file path in `oc apply -f` commands
- Do not use em dashes. Use regular dashes (`-`) instead
- Use `'''` for horizontal rules between steps
- Cross-reference other pages with `xref:page.adoc[Label]`
- External links use `link:URL[Label]`
- Use `NOTE:`, `TIP:`, `IMPORTANT:`, `WARNING:` admonitions
- All doc links must point to `docs.redhat.com` or `docs.openshift.com`
- Use attributes from `_attributes.adoc` for version numbers

## CLI Conventions

- Every `oc` command must include an explicit `--context` flag
- Never use `oc login` inside step pages
- YAML files with `${VARIABLE}` placeholders use `envsubst`
- All workshop variables are exported once in `00-setup.adoc`

## Content Rules

- Never include customer names, user names, or email addresses
- All content must be in English
- Prefer `registry.access.redhat.com` or `registry.redhat.io` images
- Use Red Hat / OpenShift-native components when they cover the use case
- Mention Red Hat products because they fit the solution, not to promote them

## YAML Conventions

- Every YAML file starts with a comment block: filename and purpose
- Use `app.kubernetes.io/part-of: <app-name>` label consistently
- Include resource requests and limits on Deployments
- Include readiness and liveness probes where applicable
```

---

## .gitignore Template

```
.DS_Store
t/
myenv.sh

# Terraform (if setup/ exists)
setup/.terraform/
setup/.terraform.lock.hcl
setup/terraform.tfstate
setup/terraform.tfstate.backup
setup/terraform.tfvars
setup/*.tfplan

# Antora / Node.js
node_modules/
.cache/
gh-pages/
package-lock.json
yarn.lock
yarn-error.log
```

---

## README.adoc Template

```asciidoc
= <Workshop Title>

<One-paragraph summary of the workshop.>

== View the Course

The full course is published at: https://<github-user>.github.io/<repo-name>

== Local Development

To preview the course site locally:

[source,bash]
----
npm install
npm run dev
----

This starts a live-reload server at http://localhost:3000.

== Build the Site

[source,bash]
----
npx antora site.yml
----

The generated site is output to `gh-pages/`.

== Repository Structure

[cols="2,4",options="header"]
|===
| Directory | Purpose

| `documentation/`
| Antora courseware source (AsciiDoc pages, navigation, attributes)

| `00-<step>/`
| YAML manifests for Step 0 - <description>

| `01-<step>/`
| YAML manifests for Step 1 - <description>

| `setup/`
| Terraform + post-install script (internal, for provisioning clusters)
|===
```
