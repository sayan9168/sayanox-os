# Sayanox OS

**Sayanox OS** is a Linux kernel-based operating system that makes the [Sayanox programming language](https://github.com/sayan9168/sayanox) a first-class citizen.

> Minimal. Powerful. Language-first. Reproducible.

## Vision

- **Kernel**: Linux
- **Base**: Minimal Debian 13 "trixie" (mmdebstrap bootstrap)
- **Soul**: Sayanox language deeply integrated into userspace
- **Identity**: Not just another distro — a system where Sayanox is the primary way to build and control the OS

## Core Goals

1. Sayanox as the primary systems language of the OS
2. `sxpkg` evolving into the main package management experience
3. Strong reproducibility and self-hosting philosophy
4. Ability to run normal Linux applications and browsers (via Flatpak/AppImage + native libs)
5. Clean, unique identity and branding

## Architecture Overview

```
┌─────────────────────────────────────┐
│           Applications              │
│     (Flatpak / AppImage / Native)   │
├─────────────────────────────────────┤
│         Sayanox Userspace           │
│  (tools, services, shell helpers)   │
├─────────────────────────────────────┤
│     Minimal Debian Base + glibc     │
├─────────────────────────────────────┤
│           Linux Kernel              │
└─────────────────────────────────────┘
```

## Current Status

- [x] Repository created
- [ ] Phase 0: mmdebstrap minbase Trixie rootfs + QEMU boot (build/00-debootstrap.sh) — written, on branch, unmerged

## Roadmap (plan of record, 6 phases)

- **Phase 0** — Foundation: mmdebstrap Debian 13 "trixie" minbase rootfs (x86_64), boot in QEMU. (`build/00-debootstrap.sh`)
- **Phase 1** — Branding + live ISO: `/etc/os-release` (`ID_LIKE=debian`), GRUB theme, Plymouth, `fonts-noto-bengali`, locales `bn_IN.UTF-8`+`en_US.UTF-8`, display manager, squashfs + GRUB → `sayanox-0.0.1.iso`.
- **Phase 2** — Identity layer: `sx` as `.deb` at `/usr/bin/sx` + stdlib at `/usr/lib/sayanox/stdlib`, `.sa` MIME `text/x-sayanox`, editor grammar, man pages, all 7 `sayanox-*` tools in `.sa`, own APT repo (`deb.sayanox.org`, aptly+gpg+`sayanox-archive-keyring`), full visual identity. → `sayanox-0.1-alpha`
- **Phase 3** — Calamares installer + branding, LUKS, UEFI+Secure Boot (Debian signed shim), website, DistroWatch → `sayanox-0.2`
- **Phase 4** — Differentiation: `sxpkg`, `linux-image-sayanox`, TUI apps in `.sa`, GTK4/Qt bindings, first GUI app in `.sa`, Bengali-first features (IME/TTS/offline dictionary), low-spec profile → `sayanox-1.0`
- **Phase 5** (year 2+) — LFS in a VM; replace Debian components one at a time with rollback paths.

## Locked decisions

Base Debian 13 "trixie" (not LFS, not Arch) · mmdebstrap (not debootstrap) · x86_64 only first · KDE Plasma 6 · Calamares · `.deb` only, never a new package format · `ID_LIKE=debian` mandatory · never fork Debian's repos · no Debian trademarks · every `sayanox-*` user-facing tool written in `.sa`, zero Python/bash.

- [ ] Phase 2: Sayanox toolchain integration
- [ ] Phase 3: Core utilities & branding
- [ ] Phase 4: Package system + Flatpak support

## Repository Structure

```
sayanox-os/
├── README.md
├── docs/
│   ├── ROADMAP.md
│   ├── ARCHITECTURE.md
│   └── DESIGN.md
├── scripts/
│   └── (build & bootstrap scripts)
├── branding/
└── sayanox/
    └── (integration related files)
```

## Related Projects

- [Sayanox Language](https://github.com/sayan9168/sayanox) — The programming language powering this OS

## Author

**Sayan Mahata** (Sayan The Researcher)  
GitHub: [sayan9168](https://github.com/sayan9168)

---

Built with focus on systems thinking, language design, and long-term vision.
