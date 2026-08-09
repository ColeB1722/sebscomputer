# sebscomputer

NixOS system configuration for the physical `sebscomputer` desktop. The initial
scope is the inert Phase 2 foundation: a bootable TTY system on its own ZFS NVMe.

The migration plan and phase gates live in `~/docs/sketches/transition/`.

## Safety boundary

This repository does not authorize disk changes. Its Phase 0 disko target is an
intentionally nonexistent path:

```text
/dev/disk/by-id/PHASE1_REPLACE_WITH_NEW_NVME_BY_ID
```

Do not replace it until Phase 1 has recorded the new drive's live model, serial,
capacity, empty partition state, and `/dev/disk/by-id/` path. Immediately before
running disko, verify all of those facts again and obtain explicit human
confirmation. Never use `/dev/nvme*`, `/dev/sd*`, or `/dev/vd*`.

The Windows 980 PRO and data 860 PRO must not appear in this configuration. The
new drive receives its own ESP; the Windows ESP is never mounted or referenced.

## Phase 0 scope

Included:

- A direct, pinned NixOS flake with a small `mkHost` helper
- One explicit host, `sebscomputer`
- systemd-boot, NetworkManager, OpenSSH, Fish, Git, and rescue tools
- A dedicated 1 GiB ESP and single-drive ZFS pool
- Explicit datasets for `/`, `/nix`, `/var`, `/home`, and `/data`
- Unmounted reservations for VM images and service volumes
- An 8 GiB ARC cap, monthly scrub, scheduled TRIM, and Sanoid snapshots
- Formatting, evaluation, dry-run, and build commands

Excluded until their planned phases:

- Home Manager, Stylix, Hyprland, and desktop applications
- NVIDIA
- Agenix, 1Password integration, and real secrets
- Tailscale and gaming
- Lanzaboote and Secure Boot enrollment
- Containers, microvms, bridges, and workloads
- Data copying or any disk operation

## Safe checks

```bash
just fmt
just check
just eval-host
just eval-storage
just disko-plan
just build
```

`just disko-plan` renders the full destroy/format/mount script with disko's
`--dry-run` flag. It returns the generated script path for inspection and does
not execute that script. There is deliberately no install, provision, apply, or
destructive disko recipe.

## Storage layout

```text
new NVMe
├── GPT ESP, 1 GiB, FAT32 -> /boot
└── ZFS partition, remainder -> tank
    ├── tank/root       -> /
    ├── tank/nix        -> /nix
    ├── tank/var        -> /var
    ├── tank/home       -> /home
    ├── tank/data       -> /data
    └── tank/vm/{images,volumes} (unmounted and unused)
```

Only `tank/home` and `tank/data` receive automatic snapshots. Single-drive ZFS
provides integrity checks and snapshots, not redundancy or a backup.

## Hardware configuration gate

`hosts/sebscomputer/hardware-configuration.nix` is an evaluation stub. From the
installer environment, replace it with configuration generated on the physical
machine, then inspect it for references to existing disks or the Windows ESP.
Re-run every safe check before any destructive command.

The user password is also set interactively during installation. No password or
password hash belongs in this repository. SSH uses the committed public key;
root login and SSH password authentication are disabled.

## Boot policy

Windows remains the default global UEFI boot entry through Phase 8. After NixOS
installation, inspect `efibootmgr -v` and restore Windows Boot Manager to first
place if necessary. Both systems must boot directly from their separate ESPs.
