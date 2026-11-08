# packages/sxpkg/ — sxpkg package manager frontend (Phase 4)

Placeholder for sxpkg — the Sayanox package management experience.

sxpkg consumes Debian repositories (.deb format only — no new package format).
Implemented as a .deb at /usr/bin/sxpkg, written in Sayanox (.sa).

Planned contents:
- sxpkg.sa           — sxpkg CLI entrypoint (written in .sa)
- sxpkg.conf         — repository configuration
- repos/             — enabled .deb repository list

Hard constraints:
- .deb only — never a new package format
- Never fork Debian's repos; upstream archives stay intact
- ID_LIKE=debian mandatory — third-party .deb repositories keep working

See docs/ROADMAP.md for the full Phase 4 plan.
