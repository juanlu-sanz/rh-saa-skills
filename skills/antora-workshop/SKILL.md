---
name: antora-workshop
description: >-
  Creates a structured GitHub repository for Red Hat Scholars courseware workshops using
  AsciiDoc and Antora, with progressive hands-on steps, collapsible verification blocks,
  reset/undo sections, and a published documentation site. Use when the user asks to create
  an Antora workshop, create an Antora courseware site, create a Red Hat Scholars tutorial,
  or says something like "I need an Antora workshop for X", "create a hands-on lab",
  "create a workshop repository", or "set up a training repo with Antora".
---

# OpenShift Workshop (Red Hat Scholars Courseware)

Creates a GitHub repository structured as a Red Hat Scholars courseware site built with
AsciiDoc and Antora. The workshop has progressive hands-on steps where each step builds on
the previous one, collapsible verification blocks, and a reset/undo section at the bottom
of every step page.

All content must be written in English. Use only Red Hat / OpenShift-native components
when they cover the use case. Never include customer names, user names, or email addresses.

---

## Repository Structure

```
<workshop-slug>/
├── README.adoc                          # Repo overview, local dev, structure table
├── .gitignore
├── .cursor/rules/workshop-conventions.mdc  # Cursor AI conventions
├── Dockerfile                           # Antora build + httpd container
├── package.json                         # npm dependencies (Antora, Gulp, BrowserSync)
├── gulpfile.babel.js                    # Gulp tasks for dev server
├── site.yml                             # Antora playbook (production)
├── dev-site.yml                         # Antora playbook (local dev)
├── site.sh                              # Shell shortcut for antora build
├── supplemental-ui/                     # Custom UI overrides
│   ├── .nojekyll
│   ├── ui.yml
│   ├── img/favicon.ico
│   └── partials/footer-nav.hbs
├── lib/                                 # Asciidoctor extensions
│   ├── tab-block.js
│   └── remote-include-processor.js
├── .github/workflows/docs.yml           # CI: build Antora + deploy to GitHub Pages
├── documentation/                       # Antora component source
│   ├── antora.yml
│   └── modules/ROOT/
│       ├── nav.adoc                     # Left-nav tree
│       ├── images/                      # Screenshots and diagrams
│       └── pages/
│           ├── _attributes.adoc         # Shared AsciiDoc attributes
│           ├── index.adoc               # Landing page with tile grid
│           ├── 00-setup.adoc            # Cluster/env setup (always page 00)
│           ├── 01-<step-name>.adoc      # First hands-on step
│           ├── 02-<step-name>.adoc      # Builds on step 01
│           └── ...                      # Additional steps
├── 00-<step-zero-dir>/                  # YAML manifests for step 0 (baseline)
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── route.yaml
├── 01-<step-name>/                      # YAML manifests for step 1
│   └── *.yaml
├── 02-<step-name>/                      # YAML manifests for step 2
│   └── *.yaml
├── kustomize/                           # Optional: Kustomize base + overlays
│   ├── base/
│   │   ├── kustomization.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── route.yaml
│   └── overlays/production/
│       └── kustomization.yaml
├── setup/                               # Optional: Terraform + post-install (internal)
│   ├── README.adoc
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars.example
│   └── post-install.sh
└── myenv.sh                             # Personal env file (gitignored)
```

YAML manifests live in root step directories (e.g. `01-acm/`) and are referenced
directly from AsciiDoc pages via `oc apply -f 01-acm/<file>.yaml`. No `manifests/`
subfolders. Steps are progressive: each builds on the previous one.

The `setup/` directory is internal-only (for Red Hatters provisioning infrastructure)
and is not part of the workshop itself.

---

## Documentation Framework: Antora

The courseware site uses Antora 2.x with the Red Hat Scholars UI bundle
(`rhd-tutorial-ui` v0.1.10). Copy these boilerplate files verbatim from the reference
workshop (`multi-cluster-app-distribution-demo`), then adapt URLs and titles:

- `gulpfile.babel.js`, `lib/tab-block.js`, `lib/remote-include-processor.js`
- `supplemental-ui/` (update footer links), `site.sh`, `Dockerfile`
- `.github/workflows/docs.yml`

Create `antora.yml`, `site.yml`, `dev-site.yml`, and `package.json` from templates
in [reference.md](reference.md).

Local dev: `npm install && npm run dev` (live-reload at http://localhost:3000).
Build: `npx antora site.yml` (output in `gh-pages/`).

---

## AsciiDoc Page Structure

### _attributes.adoc

Shared attributes for version numbers and context names. Every step page must
include it on line 2: `include::_attributes.adoc[]`

### nav.adoc

Left-nav tree using `xref:` with `#anchor` targets for sub-sections.

### index.adoc

Landing page with `:page-layout: home`, tile grid (`[.tiles.browse]`), and
environment table. See [reference.md](reference.md) for all page templates.

---

## AsciiDoc Formatting Rules

### What/Why pairs

Every numbered sub-step must start with bold What and Why:

```asciidoc
=== 1. Sub-step title

*What:* One sentence describing the concrete action.

*Why:* One sentence explaining why this step matters.
```

### Timing annotations

When a sub-step takes more than 10 seconds to complete (operator installs, pod readiness
waits, API warmup, large downloads), add a timing annotation line immediately above the
What/Why pair using the `icon:clock[]` macro. Round to the nearest meaningful unit.
Skip the annotation entirely for steps that complete in under 10 seconds.

```asciidoc
=== 5. Create the operator instance

icon:clock[] ~1 minute (CR accepted in ~10s, pods ready in ~45s)

*What:* Deploy the custom resource in the target namespace.

*Why:* This is the management plane for the product.
```

Timings should be measured by running the full workshop end-to-end and recording
wall-clock duration for each sub-step. Include a parenthetical breakdown when the wait
has distinct phases (e.g., CR creation vs pod readiness vs API warmup). Typical timings
to annotate:

- Operator installs (subscription + CSV readiness): ~30 seconds
- Custom resource deployments (pods scheduling + running): ~1-2 minutes
- API warmup after deployment (database migrations, initial loading): ~2-3 minutes
- Database hydration (vulnerability DBs, index builds, profile parsing): 15-30 minutes (background)
- Large file downloads (offline bundles, mirror content): ~5 minutes

Add an `IMPORTANT:` admonition for background processes that take 15+ minutes (like
database hydration or large index builds) so participants know to start setup early.

### Console input/output blocks

Commands the user should run:

```asciidoc
[.console-input]
[source,bash,subs="+macros,+attributes"]
----
oc apply -f 01-step/resource.yaml --context cluster-a
----
```

Expected output:

```asciidoc
[.console-output]
[source,bash]
----
NAME       READY   STATUS    RESTARTS   AGE
my-pod     1/1     Running   0          30s
----
```

### Collapsible verification blocks

Every sub-step must have a verification block:

```asciidoc
.Verify: Description of what to check
[%collapsible]
====
[.console-input]
[source,bash,subs="+macros,+attributes"]
----
oc get pods -n demo-app --context cluster-a
----

[.console-output]
[source,bash]
----
NAME       READY   STATUS    RESTARTS   AGE
my-pod     1/1     Running   0          30s
----
====
```

### Horizontal rules between steps

Use `'''` (three single quotes) between sub-steps for visual separation.

### Admonitions

```asciidoc
NOTE: Informational note.
TIP: Helpful suggestion.
IMPORTANT: Must-read information.
WARNING: Potential pitfall or danger.
```

### Cross-references and links

```asciidoc
xref:page.adoc[Label]                              # internal page
xref:page.adoc#anchor[Label]                        # internal anchor
link:https://docs.redhat.com/...[Label]             # external link
```

### Other AsciiDoc patterns

- **Tables**: `[cols="2,3",options="header"]` with `|===` delimiters
- **Images**: Place in `documentation/modules/ROOT/images/`, reference as `image::filename.png[Alt text]`
- **Collapsible blocks**: `.Title` + `[%collapsible]` + `====` delimiters (used for alternative approaches too)

---

## Screenshots from the UI

Screenshots orient participants in web consoles where navigation paths and visual
layout are hard to convey with text alone. They must always be captured by the AI
using its browser tools against the live environment - never from user-provided files,
stock images, or fabricated mockups.

### When to add screenshots

Add a screenshot only when it helps a participant find something in the UI that
words alone make ambiguous. Good candidates:

- **First time a UI section is introduced** in the workshop (e.g. the first visit
  to a product dashboard, a vulnerability results page, a network graph). One
  screenshot per major UI area is enough; do not screenshot the same page again in
  later steps unless it looks materially different.
- **Complex navigation paths** where the sidebar label, page heading, and tab names
  differ from each other (e.g. sidebar says "Results", page heading says "User
  workload vulnerabilities", sub-tabs say "User Workloads / Platform / Nodes").
- **Non-obvious UI interactions** like kebab/overflow menus, hidden filters, or
  multi-step modal dialogs where the participant needs to know what to look for.
- **Before-and-after comparisons** where a step produces a visible change (e.g.
  violations appearing after deploying workloads, risk scores dropping after
  remediation).

Do NOT add screenshots for:

- CLI-only steps with no UI component.
- Pages that are self-explanatory from the navigation path (e.g. "Platform
  Configuration > Policy Management" when the page is just a list).
- Repeated visits to the same UI page unless the data shown has changed in a way
  that matters to the narrative.
- Login screens, confirmation dialogs, or generic "success" banners.

### Capture workflow

1. **Navigate** to the target page using your browser tools with the product's
   route URL. Wait 2-3 seconds for the page to fully render before proceeding.

2. **Set up the view** before capturing. Apply any filters, expand the right
   sidebar section, or select the tab that the docs tell participants to use.
   The screenshot should show exactly what a participant would see after
   following the written instructions.

3. **Take the screenshot** using your screenshot tool. The image will be saved
   to a temporary location.

4. **Copy to the images directory**:
   ```bash
   cp <screenshot-path> \
      documentation/modules/ROOT/images/<NN>-<descriptive-name>.png
   ```
   Use the step number prefix (`04-`, `05-`, etc.) so images sort alongside
   their page files. Use lowercase kebab-case for the descriptive part.

5. **Reference in AsciiDoc** with a caption line above the `image::` macro:
   ```asciidoc
   .Dashboard - risk overview after deploying vulnerable workloads
   image::04-dashboard-risk-overview.png[ACS dashboard showing risk indicators for the acs-workshop namespace]
   ```
   The `.Title` line becomes a figure caption. The `[Alt text]` in brackets is
   for accessibility and should describe what the image shows, not repeat the
   caption.

#### Cursor-specific example

When running this skill in Cursor, the capture workflow uses these specific tools:

1. Navigate with `browser_navigate` using the product's route URL.
2. Wait for the page to render using `AwaitShell` with `block_until_ms: 3000`.
3. Apply filters or select tabs using `browser_click`, `browser_fill`, etc.
4. Capture with `browser_take_screenshot` (saves to a temporary directory,
   e.g. `/var/folders/.../cursor/screenshots/`).
5. Copy the resulting file to `documentation/modules/ROOT/images/`.

### Naming convention

```
<step-number>-<ui-area-or-feature>.png
```

Examples:
- `04-dashboard-risk-overview.png`
- `05-workload-cves.png`
- `06-network-graph.png`
- `07-violations.png`

Keep names short. One or two screenshots per step is typical; rarely more than
three.

### UI label verification

After all screenshots are placed, do a verification pass: for every navigation
instruction in the docs (bold text like `*Vulnerability Management > Results >
User Workloads*`), open that path in the browser and confirm the sidebar link
name, page heading, tab labels, filter options, and button names match exactly.
Product UIs rename elements between versions. Common mismatches to watch for:

- Sidebar link name differs from the page heading (e.g. sidebar: "Results",
  heading: "User workload vulnerabilities").
- Tab names that changed between product versions (e.g. "Authentication Tokens"
  renamed to "Authentication").
- Filter attributes that live under a non-obvious entity selector (e.g.
  "Lifecycle stage" is an attribute of the "Policy" entity, not a top-level
  filter).

Fix any mismatches in the adoc files immediately. Do not leave stale UI
references for participants to stumble over during a live session.

---

## CLI Conventions

- Every `oc` command must include an explicit `--context` flag (e.g. `hub`, `cluster-a`,
  `cluster-b`). Never use `oc login` inside step pages.
- Context setup is done once in `00-setup.adoc`.
- YAML files with `${VARIABLE}` placeholders must be applied via:
  ```bash
  envsubst < file.yaml | oc apply --context <ctx> -f -
  ```
  Document the `envsubst` requirement above the apply command so participants
  understand why a plain `oc apply -f` would fail (the `${}` tokens would be
  applied as literal strings).
- CLI tools that connect to services with self-signed TLS certificates (e.g.
  product CLIs, `curl -sk`) must include appropriate TLS skip flags
  (`--insecure-skip-tls-verify` for most Red Hat CLIs, `-sk` for `curl`). Add a `NOTE:`
  explaining that production environments should trust the CA instead.
- API commands that require a specific query parameter (e.g. `cluster_id`) must
  document how to retrieve that parameter first (e.g. querying `/v1/clusters`).
  When an API endpoint exists at different versions (`/v1/` vs `/v2/`), document
  which version to use and note discrepancies.
- All workshop variables are exported once in `00-setup.adoc`.
- Include a variables table in `00-setup.adoc`:
  ```asciidoc
  [cols="2,2,4",options="header"]
  |===
  | Variable | Used in | Description
  | `GIT_REPO_URL` | `01-step/applicationset.yaml` | Git clone URL
  |===
  ```

---

## YAML Conventions

- Every YAML file starts with a comment block: `# filename.yaml` + `# Purpose: ...`
- Use `app.kubernetes.io/part-of: <app-name>` label consistently.
- Include resource requests/limits and readiness/liveness probes on Deployments.
- YAML files live in step directories and are referenced from AsciiDoc pages.

---

## Step Page Structure

Every step page (except setup) follows this order:

1. **Title**: `= Step N - Title: Descriptive Subtitle`
2. **Include**: `include::_attributes.adoc[]`
3. **Intro paragraph**: What this step does and what problem from the previous step it solves
4. **Prerequisites**: Bullet list linking to previous step
5. **How It Works** (optional): Brief architectural explanation
6. **Steps to Apply**: Numbered sub-steps with What/Why, console blocks, and Verify blocks
7. **What This Solves**: Table comparing to previous step
8. **What This Does NOT Solve (Yet)**: Table with xref to next step
9. **Official Documentation**: Links to `docs.redhat.com`
10. **Alternatives Considered**: Neutral comparison table
11. **Reset**: Undo commands for this step

See [reference.md](reference.md) for the complete step page template.

---

## Reset / Undo Sections

Every step page MUST end with a `== Reset` section containing the exact commands to
undo everything from that step and return to the state before it. Key rules:

1. **Reverse order**: Undo resources in reverse order of creation.
2. **Use `--ignore-not-found`**: So the reset is idempotent.
3. **Wait for finalizers**: Use `--wait` or `oc wait --for=delete` when resources have
   finalizers (e.g. ApplicationSets cascade-delete Applications).
4. **Remove labels and taints**: Clean up any labels or taints added to clusters.
5. **Preserve cloud credentials**: Don't delete cloud credential secrets that are
   expensive to recreate.
6. **Explain the order**: Add a brief sentence explaining why the order matters.

---

## 00-setup.adoc Page

The setup page is special. It provides two paths:

- **Option A** - Using pre-provisioned clusters (Demo Platform): full setup from scratch
  including gathering credentials, importing clusters, installing operators.
- **Option B** - Quick login: clusters already configured by someone else.

Must include:
1. Prerequisites (tools, versions, permissions)
2. Cluster mapping table (which cluster plays which role)
3. Login and context rename instructions
4. Operator installation and verification
5. Workshop variable exports with a variable table
6. Clone repository step

---

## Content Rules

- Never include customer names, user names, or email addresses.
- All content must be in English.
- Prefer `registry.access.redhat.com` or `registry.redhat.io` images over Docker Hub.
- Use Red Hat / OpenShift-native components when they cover the use case.
- Mention Red Hat products because they fit the solution, not to promote them.
- Do not use em dashes (`-`). Use regular dashes (`-`) instead.
- All doc links must point to `docs.redhat.com` or `docs.openshift.com` - no placeholders.

---

## Platform-Specific Notes

When a workshop runs on managed OpenShift (ROSA HCP, ARO, etc.), document any
differences from self-managed OCP that affect the workshop steps. Use `NOTE:`
admonitions inline rather than separate pages. Common differences:

- **ROSA HCP / ARO**: No control plane access. Operators and features that inspect
  or configure control-plane components (e.g. etcd, API server audit config,
  platform-level compliance profiles) may be unavailable or behave differently.
  Document which profiles, APIs, or features are node-only on managed platforms.
- **Managed clusters**: May use `cluster-admin` instead of `kubeadmin` for
  authentication. The `myenv.sh` login pattern works the same way.
- **Operator versions**: Operator behavior and API endpoints can change between
  versions. When a workshop documents API calls, note the tested version in
  `_attributes.adoc` and call out any version-specific behavior (e.g. an endpoint
  that requires a query parameter in newer versions, or a v1/v2 API discrepancy).

---

## Operational Notes and Caveats

When executing the workshop reveals behaviors that are not obvious from the
documentation alone, add inline `NOTE:`, `IMPORTANT:`, or `TIP:` admonitions.
These should cover:

- **Async processes**: If an operator or service needs background time to initialize
  (e.g. a database hydrating indexes, an operator parsing profile bundles), add an
  `IMPORTANT:` admonition with a concrete log-check command so participants can
  verify readiness before proceeding.
- **API quirks**: If an API requires a precondition that is not obvious (e.g. creating
  a dependent resource before the main one, or needing a specific integration
  configured first), document the workaround inline with a `NOTE:`.
- **Behavioral differences**: If a feature behaves differently than participants might
  expect from its name or documentation (e.g. an enforcement action that works on
  Deployments but not bare Pods), explain the distinction clearly.
- **Approval workflows**: If an action creates a request that requires a different
  user to approve it, document this so participants do not get stuck waiting.
- **Certificate/TLS issues**: Self-signed certificates are common in workshop
  environments. Document TLS skip flags (e.g. `--insecure-skip-tls-verify` for CLIs,
  `-sk` for `curl`) with a note that production should trust the CA instead.
- **Image rescans**: If images are deployed before a scanner database finishes loading,
  they may show zero results. Document how to trigger a rescan or how long to wait.

---

## .cursor/rules/workshop-conventions.mdc

Create a project-specific Cursor rules file covering: repository purpose, structure,
AsciiDoc formatting, CLI conventions, content rules, and YAML conventions.
See [reference.md](reference.md) for the full template.

---

## .gitignore

Must cover: `.DS_Store`, `myenv.sh`, `t/`, Terraform state files (if `setup/` exists),
`node_modules/`, `.cache/`, `gh-pages/`, `package-lock.json`.

Also gitignore any environment-specific artifacts generated during the workshop that
contain secrets or are environment-bound:

- **Generated secret bundles** (e.g. init bundles, TLS certificates) - contain
  credentials tied to a specific deployment. Stale bundles from a previous run cause
  authentication or certificate errors on a new deployment.
- **Offline data bundles** (e.g. downloaded DB updates, mirror archives) - large binary
  files that are environment-specific.
- **CLI binaries** (e.g. downloaded product CLIs) - platform-specific, should not be
  committed.

See [reference.md](reference.md) for the full template.

---

## myenv.sh

`myenv.sh` is a personal, gitignored shell script that each workshop participant creates
to store their environment-specific credentials and cluster endpoints. Running
`source myenv.sh` authenticates to every cluster and sets up the named `oc` contexts
used throughout the workshop. It is the single place where sensitive values live — no
credentials should appear in any other file.

### Structure

The file follows this exact pattern:

```bash
# Console URLs (for quick reference — not used by scripts)
# Hub console:       https://console-openshift-console.apps.<hub-domain>
# Cluster A console: https://console-openshift-console.apps.<cluster-a-domain>
# Cluster B console: https://console-openshift-console.apps.<cluster-b-domain>

# ── Workshop variables (used by envsubst in YAML manifests) ──────────────
export HUB_API_URL="https://api.<hub-domain>:6443"
export CLUSTER_A_API_URL="https://api.<cluster-a-domain>:6443"
export CLUSTER_B_API_URL="https://api.<cluster-b-domain>:6443"

export GIT_REPO_URL="https://github.com/<org>/<repo>.git"
export REMOTE_INGRESS_IP="<set after Submariner — see step 02>"
# Add any additional workshop variables here

# ── Context cleanup (idempotent) ─────────────────────────────────────────
oc config delete-context hub 2>/dev/null
oc config delete-context cluster-a 2>/dev/null
oc config delete-context cluster-b 2>/dev/null

# ── Login + rename contexts ──────────────────────────────────────────────
oc login "$HUB_API_URL" --username <user> --password <password>
oc config rename-context "$(oc config current-context)" hub

oc login "$CLUSTER_A_API_URL" --username <user> --password <password>
oc config rename-context "$(oc config current-context)" cluster-a

oc login "$CLUSTER_B_API_URL" --username <user> --password <password>
oc config rename-context "$(oc config current-context)" cluster-b
```

### Key rules

1. **Gitignored**: `myenv.sh` must be listed in `.gitignore`. It contains passwords.
2. **Console URLs as comments**: Put web console URLs at the top as comments for quick
   copy-paste into a browser. These are not used by any script.
3. **Exports first**: All `export` variables that YAML manifests reference via `envsubst`
   go at the top, before any `oc` commands.
4. **Context cleanup before login**: Delete existing contexts before logging in so the
   script is idempotent. Running `source myenv.sh` twice must not fail.
5. **Login + rename pattern**: Each cluster follows the same three-line pattern:
   `oc login` → `oc config rename-context "$(oc config current-context)" <name>`.
   This gives deterministic context names (`hub`, `cluster-a`, `cluster-b`) regardless
   of the auto-generated context string.
6. **Match 00-setup.adoc**: The context names and variable names in `myenv.sh` must
   exactly match what `00-setup.adoc` documents. The setup page tells participants
   *what* to put in `myenv.sh`; the file itself is their personal copy.
7. **Adapt to the workshop**: If the workshop uses different or fewer clusters, adjust
   the contexts accordingly (e.g. a single-cluster workshop only needs one login block).
   Add or remove `export` lines to match the variables table in `00-setup.adoc`.

---

## GitHub Actions CI

Uses `kameshsampath/antora-site-action@master` to build and
`JamesIves/github-pages-deploy-action@v4` to deploy to `gh-pages` branch.
See [reference.md](reference.md) for the exact workflow YAML.

---

## Reference Workshop

When creating a new workshop, use the boilerplate templates in
[reference.md](reference.md). Copy these files verbatim and adapt only the
placeholders marked with `<...>`:

- `gulpfile.babel.js`, `lib/`, `supplemental-ui/`, `site.sh`, `Dockerfile`
- Adapt `site.yml`, `dev-site.yml`, `antora.yml`, `package.json`
- Update `supplemental-ui/partials/footer-nav.hbs` with new repo URLs

---

## Quality Checklist

Before finishing:

- [ ] All AsciiDoc pages are in English
- [ ] `_attributes.adoc` defines all version attributes used across pages
- [ ] Every step page includes `\include::_attributes.adoc[]` on line 2
- [ ] Every numbered sub-step has *What*/*Why* bold pairs
- [ ] Every sub-step has a `.Verify:` collapsible block
- [ ] `'''` horizontal rules separate sub-steps
- [ ] Every `oc` command has an explicit `--context` flag
- [ ] No `oc login` inside step pages (only in `00-setup.adoc`)
- [ ] YAML files with `${VARIABLE}` use `envsubst` in apply commands
- [ ] Every YAML file has a comment header (filename + purpose)
- [ ] Every step page ends with a `== Reset` section
- [ ] Reset commands use `--ignore-not-found` and reverse order
- [ ] `nav.adoc` lists all pages with anchor-level sub-items
- [ ] `index.adoc` has tile grid linking to all steps
- [ ] `00-setup.adoc` has Options A and B, variable table, and clone step
- [ ] Steps are progressive (each builds on the previous)
- [ ] "What This Solves" and "What This Does NOT Solve" tables present
- [ ] Official Documentation section links to `docs.redhat.com`
- [ ] Alternatives Considered table is neutral (no sales language)
- [ ] No em dashes, no customer names, no placeholder doc links
- [ ] `.cursor/rules/workshop-conventions.mdc` created for the project
- [ ] `.github/workflows/docs.yml` configured
- [ ] `site.yml` and `dev-site.yml` configured with correct URLs
- [ ] `.gitignore` covers all generated/sensitive files
- [ ] Screenshots captured from the live UI via the AI's browser (no fabricated images)
- [ ] Screenshots placed only where UI navigation is ambiguous or a new section is introduced
- [ ] Screenshot filenames use `<NN>-<descriptive-name>.png` convention
- [ ] Every UI navigation path in the docs verified against the actual product UI
- [ ] Sidebar labels, page headings, tab names, and button labels match the live UI exactly
