# Phase 1 → Phase 2 Handover

The exact procedure for replacing the Phase 0 placeholder with the real drive
identity, and for replacing the hardware stub with generated configuration.
Nothing here authorizes a destructive command; disko execution keeps its own
live human confirmation gate at Phase 2.

## Preconditions

- Phase 1 is complete: the drive is installed, Windows boots normally, and
  `transition-evidence/procedures/PHASE1-RECORD.md` is fully signed off — all
  three serial identities (label, Windows, installer `by-id`) agree.
- The drive at hand is the Lexar NQ780 2 TB. The Samsung 980 PRO (Windows) and
  860 PRO (`D:`) must never appear in this repository.

## Step 1 — Replace the disko placeholder

In `hosts/sebscomputer/storage.nix`, replace:

```text
/dev/disk/by-id/PHASE1_REPLACE_WITH_NEW_NVME_BY_ID
```

with the recorded `/dev/disk/by-id/` path. Rules:

- Use the `nvme-<model>_<serial>` form copied from the signed-off Phase 1
  record, which itself was copied from live installer output — never typed from
  memory, a photo caption, or this document.
- It must begin with `/dev/disk/by-id/` (the module asserts this).
- Cross-check: the serial embedded in the path must equal the label serial and
  the Windows-reported serial in the Phase 1 record.

Commit this change alone, with the record reference in the message.

## Step 2 — Replace the hardware stub (from the installer environment)

On the physical machine, from the installer USB:

```bash
nixos-generate-config --no-filesystems --show-hardware-config
```

Replace `hosts/sebscomputer/hardware-configuration.nix` with the output, then
inspect it before committing:

- No reference to the 980 PRO, 860 PRO, their partitions, or the Windows ESP.
- No `fileSystems` entries (disko owns filesystems; `--no-filesystems`
  should guarantee this).
- Kernel modules and CPU microcode lines are plausible for a 5950X desktop.

## Step 3 — Re-run every gate from a clean clone

This re-run is a Phase 0/2 exit requirement, not a formality:

```bash
git clone git@github.com:ColeB1722/sebscomputer.git /tmp/sebscomputer-gate
cd /tmp/sebscomputer-gate
just check
just eval-host
just eval-storage
just disko-plan
just build
```

Then review the rendered disko plan text and confirm the target is the NQ780
by-id path and nothing else.

## Step 4 — Stop

The next action after a green gate is the Phase 2 go/no-go: live verification
of model, serial, capacity, empty partition table, and by-id path against the
Phase 1 record, followed by explicit human confirmation immediately before
disko runs. That confirmation happens at execution time and cannot be
pre-granted here.
