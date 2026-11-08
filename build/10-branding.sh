#!/usr/bin/env bash
#
# build/10-branding.sh — Sayanox OS Phase 1
# Apply branding to the rootfs: locales, plymouth, GRUB theme, display manager, fonts.
#
# Requirements (build host): root/sudo access, Debian bookworm/trixie, network
#
# Usage:
#   sudo ./build/10-branding.sh apply   # Apply Phase 1 branding to rootfs (chroot-based)
#   sudo ./build/10-branding.sh check   # Check required tools
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOTFS_DIR="${SAX_ROOTFS:-$REPO_ROOT/rootfs}"
OVERLAY_DIR="$REPO_ROOT/overlay"
BRANDING_DIR="$REPO_ROOT/branding"

PHASE1_PKGS=(
  plymouth
  plymouth-themes
  fonts-noto-bengali
  sddm
  grub-pc
  locales
  console-setup
  keyboard-configuration
)

step() { echo "==> $*"; }
err()  { echo "!! $*" >&2; }

require_root() {
  [ "$(id -u)" -eq 0 ] || { err "This step requires root (run with sudo)"; return 1; }
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "Required command not found: $1"; return 1; }
}

cmd_check() {
  echo "==> Sayanox OS Phase 1 environment check"
  local missing=0
  for c in chroot locale-gen update-locale mksquashfs grub-mkrescue xorriso; do
    if command -v "$c" >/dev/null 2>&1; then echo "   [ok] $c"; else echo "   [miss] $c"; missing=1; fi
  done
  echo "   rootfs: $ROOTFS_DIR"
  if [ "$missing" -ne 0 ]; then return 1; fi
  echo "==> All tools present"
}

cmd_apply() {
  require_root

  if [ ! -d "$ROOTFS_DIR" ] || [ -z "$(ls -A "$ROOTFS_DIR")" ]; then
    err "Rootfs missing/empty — run build/00-debootstrap.sh bootstrap first"
    return 1
  fi

  step "1. Copy overlay files to rootfs ($OVERLAY_DIR -> $ROOTFS_DIR)"
  cp -a "$OVERLAY_DIR/." "$ROOTFS_DIR/"

  step "2. Install Phase 1 packages (apt inside chroot)"
  # Note: network is needed inside chroot; if the sandbox blocks network, run this step on the build host
  chroot "$ROOTFS_DIR" apt-get update
  chroot "$ROOTFS_DIR" apt-get install -y --no-install-recommends "${PHASE1_PKGS[@]}"

  step "3. Locale setup (English default: en_US.UTF-8 — everything in English at boot)"
  chroot "$ROOTFS_DIR" locale-gen en_US.UTF-8
  chroot "$ROOTFS_DIR" update-locale LANG=en_US.UTF-8 LC_NUMERIC=en_US.UTF-8 LC_TIME=en_US.UTF-8 LC_MONETARY=en_US.UTF-8 LC_PAPER=en_US.UTF-8 LC_MEASUREMENT=en_US.UTF-8

  step "4. GRUB theme + wallpaper (boot/grub/themes/sayanox)"
  mkdir -p "$ROOTFS_DIR/boot/grub/themes/sayanox"
  cp -a "$BRANDING_DIR/sayanox-wallpaper.png" "$ROOTFS_DIR/boot/grub/themes/sayanox/wallpaper.png"
  cp -a "$OVERLAY_DIR/boot/grub/themes/sayanox/theme.txt" "$ROOTFS_DIR/boot/grub/themes/sayanox/theme.txt"
  if command -v grub-mkconfig >/dev/null 2>&1; then
    chroot "$ROOTFS_DIR" grub-mkconfig -o /boot/grub/grub.cfg || true
  fi

  step "5. Set plymouth theme to default (sayanox)"
  if command -v plymouth-set-default-theme >/dev/null 2>&1; then
    chroot "$ROOTFS_DIR" plymouth-set-default-theme sayanox || true
  fi
  if command -v update-initramfs >/dev/null 2>&1; then
    chroot "$ROOTFS_DIR" update-initramfs -u || true
  fi

  step "6. Display manager (sddm) — theme applied via overlay/etc/sddm.conf.d/sayanox.conf"

  step "Branding complete: $ROOTFS_DIR"
  echo "   Next step: sudo ./build/20-iso.sh iso  (squashfs + GRUB -> sayanox-0.0.1.iso)"
}

usage() {
  cat <<EOF
Usage: $0 {apply|check}
  apply  - Apply Phase 1 branding to rootfs (chroot-based)
  check  - Check build environment
EOF
}

main() {
  case "${1:-}" in
    apply) cmd_apply ;;
    check) cmd_check ;;
    *)     usage; exit 1 ;;
  esac
}

main "$@"
