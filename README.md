# Fedora Workstation Security Baseline 🛡️

A personal, opinionated security baselines for **Fedora Linux Workstation**

This repository contains a collection of **Ansible Playbooks and supporting scripts** designed to configure, harden, and standardize any Fedora Workstation the same way - every time.

Whether this is a fresh install, a laptop rebuild, or a new daily driver, the goal is simple:

> **Clone ->  Run -> Secure and setup Fedora the way I want it.
---

## 🎯 Project Goals

- ✅ Provide a **repeatable, automated security baseline** for Fedora Workstation
- ✅ Support **multiple Fedora versions** (where possible)
- ✅ Be **idempotent** — safe to run multiple times
- ✅ Favor **secure-by-default** configurations without breaking usability
- ✅ Document *why* changes are made, not just *what* is changed

This is **not** intended to be a CIS/STIG compliance project (though it may borrow ideas).
This *is* intended to be a practical, daily-driver-focused security baseline.

---


## 🔒 What This Baseline Covers

Depending on enabled roles/playbooks, this project may configure:

- System hardening
  - Secure sysctl defaults
  - Kernel and bootloader hardening
  - SELinux enforcement and tuning
- User & authentication security
  - sudo configuration
  - password policies
  - SSH client/server hardening
- Network security
  - firewalld defaults
  - service exposure minimization
- Package & update hygiene
  - removal of unnecessary services
  - automatic security updates
- Workstation protections
  - USB / removable media controls
  - screen lock and idle policies
- Audit & visibility
  - journald configuration
  - auditd rules (where applicable)

Everything is **modular and opt-in**.

---

## 📁 Repository Structure

```text
.
├── ansible/
│   ├── playbooks/
│   │   └── workstation.yml
│   ├── roles/
│   │   ├── hardening/
│   │   ├── firewall/
│   │   ├── selinux/
│   │   └── updates/
│   └── inventory/
│       └── localhost
├── scripts/
│   ├── preflight-checks.sh
│   ├── validate-fedora.sh
│   └── post-install-audit.sh
├── docs/
│   ├── threat-model.md
│   └── design-decisions.md
└── README.md

🚀 Getting Started
## Prerequisites
- Fedora Workstation (supported versions documented below)
- git
- ansible-core
- sudo privileges
```

Hello
