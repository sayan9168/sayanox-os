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
- [ ] Phase 0: mmdebstrap minbase Trixie rootfs + QEMU boot (build/00-debootstrap.sh)
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
