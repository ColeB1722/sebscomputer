# Safe Phase 0 operations only. This file intentionally has no install or apply recipe.

set dotenv-load := false
set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

# Format the repository.
fmt:
    fd --extension nix --print0 | xargs -0 nix fmt --

# Check formatting and evaluate every flake output without building or applying it.
check:
    fd --extension nix --print0 | xargs -0 nix fmt -- --check
    nix flake check --no-build

# Evaluate the host system derivation.
eval-host:
    nix eval --raw .#nixosConfigurations.sebscomputer.config.system.build.toplevel.drvPath

# Print the evaluated disko device tree as JSON.
eval-storage:
    nix run .#storage-plan

# Generate the disko script path without executing the script.
disko-plan:
    nix run .#disko-plan

# Build the host closure. This does not activate or install it.
build:
    nix build .#nixosConfigurations.sebscomputer.config.system.build.toplevel
