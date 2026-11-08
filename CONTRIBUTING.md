# Contributing to Sayanox OS

Sayanox OS is a language-first Linux distribution built on Debian 13 "trixie"
with mmdebstrap. The Sayanox programming language is the primary way to build
and control the OS.

## Before you contribute

Read the locked decisions in `docs/ROADMAP.md` ("Hard Constraints") and
`README.md`. These are not up for debate:

- Base: Debian 13 "trixie", mmdebstrap, x86_64 first
- `.deb` only — never a new package format
- `ID_LIKE=debian` mandatory
- Never fork Debian's repos; no Debian trademarks
- Every `sayanox-*` user-facing tool in `.sa`, zero Python/bash

## How to contribute

1. Fork the repo on GitHub.
2. Create a branch from `main` (e.g. `feature/something`).
3. Make your change.
4. Keep all code, comments, and docs in English.
5. Open a pull request against `main`.

## Build scripts

- `build/00-debootstrap.sh` — Phase 0 rootfs (mmdebstrap)
- `build/10-branding.sh`  — Phase 1 branding overlay
- `build/20-iso.sh`       — Phase 1 squashfs + GRUB ISO

Run on a Debian 13 build host with root/sudo. Not intended to run in a
sandboxed environment (no network inside chroot).

## Language

All repository text — code, comments, documentation, commit messages — is in
English. Bengali is supported only as an optional locale (`bn_IN.UTF-8`), not
the boot default.
