# Sayanox OS — Design Document

This document captures the design decisions and build philosophy for Sayanox OS.
It complements `docs/ARCHITECTURE.md` (high-level layers) and `docs/ROADMAP.md` (phase plan).

## 1. Goals

- **Language-first userspace**: Sayanox (`.sa`) is the primary language for system tools and services.
- **Debian-compatible base**: Debian 13 "trixie" minbase via mmdebstrap — glibc, FHS, apt/dpkg as the reproducible foundation.
- **x86_64 first**: arm64 considered later, never shipped simultaneously.
- **`.deb` only**: sxpkg consumes Debian repositories; no new package format.
- **`ID_LIKE=debian` mandatory**: third-party `.deb` repositories keep working.
- **No Debian trademarks**: "Sayanox OS" is its own identity; never implies Debian endorsement.

## 2. Non-Goals (Phase 0–1)

- No from-scratch kernel — Linux is the kernel.
- No Python/bash user-facing tools — every `sayanox-*` tool is written in `.sa`.
- No fork of Debian's repositories; upstream archives stay intact.
- No own-kernel Firefox promises before community discussion.

## 3. Build Pipeline

```
rootfs/                 Phase 0 — mmdebstrap trixie minbase (build/00-debootstrap.sh)
overlay/                Files copied on top of rootfs (branding, config)
branding/               Wallpaper, themes, visual identity
build/10-branding.sh    Phase 1 — locales, plymouth, GRUB theme, SDDM, fonts
build/20-iso.sh         Phase 1 — squashfs + GRUB → sayanox-0.0.1.iso
```

Each `build/*.sh` script takes a single subcommand and requires a Debian 13 host with root/sudo. They are build definitions, not sandbox-executable.

## 4. Overlay Model

`overlay/` mirrors the target rootfs. `build/00-debootstrap.sh` copies `overlay/` onto the minbase rootfs after bootstrap. Phase 1 branding (os-release, issue, hostname, locale, plymouth, GRUB theme, SDDM) is delivered entirely through overlay files so the rootfs stays reproducible.

## 5. Localization

- `en_US.UTF-8` — system default (`LANG`)
- `bn_IN.UTF-8` — Bengali (Bangladesh) for numbers, time, money, paper
- Font: `fonts-noto-bengali`

## 6. Boot & Branding

- GRUB theme: `boot/grub/themes/sayanox/` (theme.txt + wallpaper.png)
- Plymouth theme: `usr/share/plymouth/themes/sayanox/`
- SDDM theme config: `etc/sddm.conf.d/sayanox.conf`
- KDE Plasma 6 global theme: Phase 2

## 7. Versioning

- `sayanox-0.0.1` — Phase 0/1 development bootable (rootfs + ISO)
- `sayanox-0.1-alpha` — Phase 2 milestone (Sayanox toolchain in `.sa`, own APT repo)
- `sayanox-0.2` — Phase 3 (Calamares, UEFI + Secure Boot)
- `sayanox-1.0` — Phase 4 (sxpkg, `.sa` GUI app, Bengali-first features)

## 8. Constraints (hard, from roadmap)

- Do not fork Debian repos.
- Do not ship x86_64 and arm64 together.
- No own-kernel Firefox promises pre-discussion.
- Every `sayanox-*` user-facing tool in `.sa`, zero Python/bash.
