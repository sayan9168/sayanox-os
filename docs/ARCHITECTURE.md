# Sayanox OS Architecture

## High-Level Design

Sayanox OS is intentionally **not** a from-scratch kernel.  
It uses the **Linux kernel** for hardware support and stability, while pushing uniqueness into the **userspace** through the Sayanox language.

### Layers

1. **Hardware**
2. **Linux Kernel**
3. **Minimal Debian Base** (glibc, FHS, apt/dpkg as temporary foundation)
4. **Sayanox Runtime & Toolchain**
5. **Sayanox-written system tools & services**
6. **Applications** (native + Flatpak + AppImage)

## Design Principles

- **Language-first**: Sayanox should feel native, not bolted on.
- **Practical uniqueness**: Prefer deep integration over reinventing everything.
- **Reproducibility**: Builds and system state should be as reproducible as possible.
- **App compatibility**: Users should be able to run browsers and common tools.
- **Progressive replacement**: Start with Debian base, gradually replace components with Sayanox versions.

## Key Decisions

| Decision              | Choice                  | Reason                                      |
|-----------------------|-------------------------|---------------------------------------------|
| Kernel                | Linux                   | Hardware support + stability                |
| Base                  | Minimal Debian          | glibc + app compatibility + practical start |
| Primary Language      | Sayanox                 | Project identity                            |
| Package experience    | sxpkg (long-term)       | Native to Sayanox ecosystem                 |
| App distribution      | Flatpak + AppImage      | Easy browser & desktop app support          |

## Future Direction

Over time, more of the userspace (and possibly later parts of the system) can be rewritten or controlled by Sayanox, while keeping the Linux kernel.
