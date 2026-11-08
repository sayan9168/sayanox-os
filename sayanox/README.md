# sayanox/ — Sayanox language tools (Phase 2: identity layer)

This directory holds the `sayanox-*` system tools written in the Sayanox
language (`.sa`). Per the project's locked decisions:

- Every `sayanox-*` user-facing tool is written in `.sa` — zero Python/bash.
- Installed as `.deb` packages at `/usr/bin/sx` etc.
- Stdlib lives at `/usr/lib/sayanox/stdlib`.

## Planned tools (7)

| Tool          | Purpose                          | Status     |
|---------------|----------------------------------|------------|
| `sx`          | Main Sayanox CLI entrypoint      | stub below |
| `sayanox-fetch`   | System information fetcher       | stub below |
| `sayanox-welcome` | First-boot welcome screen        | stub below |
| `sayanox-install` | Package/system installer helper  | stub below |
| `sayanox-update`  | System update helper             | stub below |
| `sayanox-doctor`  | System diagnostics / self-check  | stub below |
| `sayanox-backup`  | System backup/restore helper     | stub below |
| `sayanox-driver`  | Hardware driver management       | stub below |

## Implementation note

These `.sa` files are **Phase 2 stubs**. The Sayanox language syntax is
defined in the sister repo `sayan9168/sayanox`. Replace each stub with a real
`.sa` implementation once the language spec is final, then package each as a
`.deb` per `packages/manifest.txt`.
