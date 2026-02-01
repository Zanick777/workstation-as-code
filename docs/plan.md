# Workstation-as-Code: Project Plan

## Overview

Automated Ansible-based security hardening, desktop customization, and developer tooling setup for Fedora Linux Workstation. Clone the repo onto any Fedora machine, run a single bootstrap script, and get a fully configured, hardened workstation.

## Goals

- Provide a repeatable, automated security baseline mapped to CIS Fedora Workstation Benchmark + custom controls
- Automate GNOME desktop environment configuration (themes, extensions, shortcuts, privacy settings)
- Automate developer tooling installation and configuration (languages, editors, CLI tools, containers)
- Support multiple machine profiles via variable files (personal, work, etc.)
- Be idempotent — safe to run multiple times without side effects
- Maintain full CI pipeline with linting, Molecule role tests, and integration tests

## Architecture

### Approach

A single Ansible playbook targets `localhost` and orchestrates three categories of roles: security hardening, desktop environment, and developer tooling. Machine-specific differences are handled through variable files — the playbook stays identical across machines, only the vars file changes.

A bootstrap shell script handles the zero-to-running path on a fresh Fedora install.

### Directory Structure

```
workstation-as-code/
├── ansible/
│   ├── playbooks/
│   │   └── workstation.yml          # Main playbook
│   ├── roles/
│   │   ├── security_baseline/       # CIS-mapped hardening
│   │   ├── firewall/                # firewalld configuration
│   │   ├── selinux/                 # SELinux enforcement
│   │   ├── updates/                 # DNF automatic security updates
│   │   ├── desktop/                 # GNOME settings, themes, extensions
│   │   └── devtools/                # Developer tooling and configs
│   ├── vars/
│   │   ├── common.yml               # Shared across all profiles
│   │   ├── personal.yml             # Personal machine overrides
│   │   └── work.yml                 # Work machine overrides
│   ├── inventory/
│   │   └── localhost.yml            # localhost connection
│   └── ansible.cfg
├── scripts/
│   └── bootstrap.sh                 # Zero-to-running script
├── docs/
│   ├── plan.md                      # This document
│   ├── threat-model.md              # Security threat model
│   └── design-decisions.md          # ADRs for key choices
├── .github/
│   └── workflows/
│       └── ci.yml                   # Linting + Molecule + integration
└── README.md
```

## Security Hardening (CIS + Custom)

The `security_baseline` role is organized into task files that map to CIS Fedora Workstation Benchmark sections.

### CIS-Mapped Controls

| Area | Description | CIS Section |
|------|-------------|-------------|
| Kernel & sysctl | Disable IP forwarding, enable ASLR, restrict `dmesg`, harden network parameters | 3.x |
| Bootloader | GRUB password protection, restrict single-user mode access | 1.4.x |
| SELinux | Enforcing mode, targeted policy, relabel if needed (separate `selinux` role) | 1.6.x |
| User & auth | Password complexity (`pwquality`), account lockout (`faillock`), sudo hardening, SSH key-only auth | 5.x |
| Filesystem | Disable unused filesystems (cramfs, squashfs, udf), `noexec`/`nosuid` on `/tmp` and `/dev/shm` | 1.1.x |
| Services | Disable unnecessary services (avahi-daemon, cups if not needed), ensure auditd/firewalld running | 2.x |
| Audit & logging | auditd rules for privilege escalation, file access, module loading; journald persistent storage | 4.x |

### Custom Controls (Beyond CIS)

- USB device authorization policies (USBGuard)
- GNOME screen lock timeout and idle policies
- Automatic security updates via `dnf-automatic`
- NetworkManager hardened DNS settings

Each task includes a comment referencing its source: `# CIS 1.1.1.1` for benchmark items, `# CUSTOM` for non-CIS items.

### Supporting Roles

- **`firewall`** — firewalld zone configuration, allowed services/ports, default deny policy
- **`selinux`** — Enforce targeted policy, manage booleans, handle relabeling
- **`updates`** — Configure `dnf-automatic` for security-only updates with notification

## Desktop Environment Role

The `desktop` role configures GNOME via `dconf`/`gsettings`:

- **Appearance** — Dark/light theme, accent color, wallpaper, font settings, cursor theme
- **Extensions** — Install and enable GNOME Shell extensions (managed via a list in vars)
- **Dock/Dash** — Position, size, favorite apps, auto-hide behavior
- **Keyboard shortcuts** — Custom keybindings for window management, app launchers
- **Privacy** — Screen lock timeout, location services, file history, usage reporting

All values are driven by variable files so different profiles can have different configurations.

## Developer Tooling Role

The `devtools` role installs and configures the development environment:

- **Package groups** — Defined as lists in vars: `base_packages`, `dev_packages`, `optional_packages`
- **Languages/runtimes** — Python (pyenv or system), Node (nvm or system), Go, Rust — toggled per profile
- **Containers** — Podman (pre-installed on Fedora), optionally Docker, kubectl, kind
- **Editors** — VS Code (repo + extensions list), Neovim (with config), JetBrains Toolbox
- **CLI utilities** — git config, tmux, fzf, ripgrep, jq, bat, etc.
- **Dotfiles** — Symlink or template dotfiles (.bashrc, .gitconfig, .tmux.conf) from the repo
- **Flatpaks** — Application list installed via Flatpak (browsers, communication tools, etc.)

Package lists live in variable files — adding or removing a tool is just editing a YAML list.

## Variable-Driven Profiles

### common.yml

Shared settings applied to all machines: security baseline parameters, base packages, core GNOME settings.

### personal.yml / work.yml

Profile-specific overrides:

```yaml
# Example: personal.yml
profile_name: personal
desktop_theme: dark
install_gaming_tools: true
dev_languages:
  - python
  - rust
  - go
extra_flatpaks:
  - com.spotify.Client
  - org.signal.Signal
```

The bootstrap script prompts the user to select a profile, or accepts it as a CLI argument.

## Bootstrap Script

`scripts/bootstrap.sh` handles the fresh-install workflow:

1. Verify running on Fedora (check `/etc/os-release`)
2. Install Ansible via `dnf install ansible-core`
3. Install required Ansible collections (`community.general`, `ansible.posix`)
4. Prompt user to select a profile (personal/work) or accept a CLI argument
5. Run the playbook: `ansible-playbook -K --extra-vars @vars/<profile>.yml playbooks/workstation.yml`

The script is idempotent — safe to re-run at any time.

## Testing & CI Pipeline

Three layers of quality assurance:

### 1. Linting

`ansible-lint` and `yamllint` run on every push and pull request. Catches syntax issues, deprecated modules, and style violations.

### 2. Molecule Tests

Each role gets a Molecule scenario using the Podman driver (native on Fedora). Tests verify:

- Role converges without errors
- Role is idempotent (second run reports no changes)
- Key assertions pass (e.g., SELinux is enforcing, firewalld is active)

### 3. Integration Tests

GitHub Actions workflow spins up a Fedora container image, runs the full playbook, and validates the end state. Runs on pull requests to `main`.

### CI Workflow

```
Push/PR → yamllint → ansible-lint → Molecule (per role) → Integration (full playbook)
```

## Implementation Phases

| Phase | Focus | Deliverables |
|-------|-------|-------------|
| 1 — Foundation | Project structure and automation scaffolding | Directory structure, `ansible.cfg`, `localhost.yml` inventory, `bootstrap.sh`, CI pipeline (linting + empty Molecule) |
| 2 — Security | Core security hardening | `security_baseline`, `firewall`, `selinux`, `updates` roles with Molecule tests |
| 3 — Desktop | GNOME desktop configuration | `desktop` role (appearance, extensions, shortcuts, privacy) with Molecule tests |
| 4 — Dev Tools | Developer environment setup | `devtools` role (packages, languages, editors, dotfiles, Flatpaks) with Molecule tests |
| 5 — Polish | Profiles, docs, full test coverage | Variable profiles (personal/work), `threat-model.md`, `design-decisions.md`, integration tests, README updates |
