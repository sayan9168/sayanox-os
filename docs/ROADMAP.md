# Sayanox OS Roadmap (Plan of Record)

**Decisions (do not change):**
- Base: Debian 13 "trixie" (LFS deferred to year 2+)
- Bootstrap tool: mmdebstrap (not debootstrap)
- Architecture: x86_64 first, arm64 later
- Desktop: KDE Plasma 6
- Installer: Calamares (+ custom branding module)
- Package format: .deb only (no new format)
- ID_LIKE=debian is mandatory
- Sayanox tools (.sa) only — no Python/bash user-facing tools

---

## Phase 0 (Weeks 1–2) — Completed (merged on arena/f8d691f5-sayanox-os)

[x] Repo layout: build/, overlay/, docs/
[x] build/00-debootstrap.sh — trixie minbase rootfs via mmdebstrap (x86_64)
[ ] Rootfs boot test in QEMU → sayanox-0.0.1-bootable (must be run on build host)

## Phase 1 (Weeks 2–4) — Branding + Live ISO (in progress)

[x] /etc/os-release, /etc/issue (Sayanox OS, ID_LIKE=debian) — overlay/etc/
[x] Locale en_US.UTF-8 (all-English default at boot), display manager (sddm) — overlay/etc/, build/10-branding.sh
[x] GRUB theme + Plymouth splash, Bengali font (fonts-noto-bengali) — overlay + branding/
[ ] squashfs + GRUB → sayanox-0.0.1.iso boot — build/20-iso.sh written, must be run on build host
[ ] Milestone: sayanox-0.0.1-iso

## Phase 2 (Months 1–2) — Identity Layer (highest priority)

[ ] sx as .deb at /usr/bin/sx + stdlib at /usr/lib/sayanox/stdlib
[ ] .sa MIME type (text/x-sayanox), editor grammar, man pages
[ ] 7 sayanox-* tools in .sa (fetch, welcome, install, update, doctor, backup, driver)
[ ] Own APT repo (deb.sayanox.org, aptly + gpg, sayanox-archive-keyring)
[ ] Plasma global theme, wallpaper, icons, cursor, sounds
[ ] Milestone: sayanox-0.1-alpha

## Phase 3 (Months 2–4) — Installer + Security

[ ] Calamares + branding, LUKS
[ ] UEFI + Secure Boot (Debian signed shim)
[ ] Developer toolchain toggle, website, DistroWatch listing
[ ] Milestone: sayanox-0.2

## Phase 4 (Months 4–8) — Differentiation

[ ] sxpkg (package manager frontend)
[ ] linux-image-sayanox kernel flavor
[ ] TUI apps in .sa, GTK4/Qt bindings, first GUI app in .sa
[ ] Bengali-first features (IME, TTS, offline dictionary/Wikipedia), low-spec profile
[ ] Milestone: sayanox-1.0

## Phase 5 (Year 2+) — Evolution

[ ] LFS VM learning project (not a shipping base)
[ ] Replace Debian components one at a time (init, shell, coreutils, package manager) with rollback paths

---

## Hard Constraints

- Do not fork Debian repos; keep upstream archives intact
- Do not ship x86_64 and arm64 together
- No Firefox-on-own-kernel promises before community discussion
