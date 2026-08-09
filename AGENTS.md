# Agent Guidance

This repository configures a physical machine with two existing data-bearing
drives. Treat storage work as safety-critical.

## Hard rules

- Never run disko, format, partition, mount, install, or change EFI variables
  without explicit human confirmation at execution time.
- Never replace the Phase 0 disk placeholder from documentation or memory. Use
  live model, serial, capacity, partition-table, and `/dev/disk/by-id/` evidence.
- Never use enumeration-dependent device paths such as `/dev/nvme*` or `/dev/sd*`.
- Never reference or mount the Windows ESP.
- Preserve Windows as the default UEFI entry until the migration plan says
  otherwise.
- A dry run may generate a script for inspection. Never execute that script as
  part of validation.

## Phase boundary

The foundation is TTY-only. Do not add Home Manager, Stylix, NVIDIA, Hyprland,
secrets, Tailscale, gaming, Secure Boot, containers, microvms, bridges, or
workloads until their documented phase.

Use `just check`, `just eval-host`, `just eval-storage`, and `just disko-plan` for
safe evaluation. `just build` builds a closure but does not activate it.
