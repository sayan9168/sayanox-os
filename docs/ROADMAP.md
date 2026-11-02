# Sayanox OS Roadmap

## Phase 1 — Foundation (Current Focus)

**Goal**: Create a working Minimal Debian base that can boot and run basic commands.

- [ ] Write debootstrap script for clean Minimal Debian (bookworm or stable)
- [ ] Create basic chroot and enter scripts
- [ ] Set hostname, timezone, locale
- [ ] Install essential packages (ca-certificates, curl, sudo, etc.)
- [ ] Document how to build the base rootfs

## Phase 2 — Sayanox Integration

**Goal**: Make Sayanox language available system-wide.

- [ ] Install / bootstrap Sayanox compiler inside the system
- [ ] Add Sayanox to PATH and create proper environment
- [ ] Create first Sayanox-written system helpers
- [ ] Test compiling and running simple `.sa` programs on the OS

## Phase 3 — Identity & Core Tools

**Goal**: Make the system feel like Sayanox OS.

- [ ] Custom MOTD / issue / branding
- [ ] Hostname and system identity
- [ ] First set of core utilities written in Sayanox
- [ ] Basic service / init helpers

## Phase 4 — Packages & Apps

**Goal**: Usable system with application support.

- [ ] Integrate or wrap `sxpkg`
- [ ] Add Flatpak support for browsers and desktop apps
- [ ] AppImage support
- [ ] Document how users can install software

## Phase 5 — Polish & Release

- [ ] ISO or image build process
- [ ] Documentation website / getting started guide
- [ ] First public alpha release

---

**Principle**: Progress over perfection. Keep uniqueness through Sayanox while staying practical.
