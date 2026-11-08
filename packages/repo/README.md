# packages/repo/ — Sayanox APT repository (Phase 2)

Placeholder for the project's own APT repository (`deb.sayanox.org`).

Planned contents:
- dists/trixie/main/binary-amd64/   — .deb packages
- pool/main/s/sayanox-*            — package pool
- sayanox-archive-keyring.gpg      — archive signing key
- InRelease / Release files        — signed metadata

Hard constraints (Phase 2):
- aptly + gpg for repository management
- Only .deb packages — never a new package format
- Never fork Debian's repos; upstream archives stay intact

See docs/ROADMAP.md for the full Phase 2 plan.
