# Workstation Playbook Usage

## Prerequisites

- Ansible installed on the local machine
- sudo privileges for the target user

## Running the Playbook

From the repository root:

```bash
ansible-playbook ansible/playbooks/workstation.yml
```

This applies **all** roles (Security Baseline and Quality of Life).

## Using Tags

You can selectively run specific roles by passing `--tags`:

| Tag   | Role              | Description                                      |
|-------|-------------------|--------------------------------------------------|
| `SEC` | security-baseline | Applies security hardening configurations        |
| `QOF` | quality_of_life   | Deploys dotfiles, bash functions, and preferences |

### Run only the Security Baseline role

```bash
ansible-playbook ansible/playbooks/workstation.yml --tags SEC
```

### Run only the Quality of Life role

```bash
ansible-playbook ansible/playbooks/workstation.yml --tags QOF
```

### Run multiple specific tags

```bash
ansible-playbook ansible/playbooks/workstation.yml --tags "SEC,QOF"
```
