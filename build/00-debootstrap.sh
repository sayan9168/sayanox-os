#!/usr/bin/env bash
#
# build/00-debootstrap.sh — Sayanox OS Phase 0
# Builds the Debian 13 "trixie" minbase rootfs using mmdebstrap.
#
# Requirements (build host):
#   - Debian host (bookworm/trixie), root/sudo access
#   - mmdebstrap, gnupg installed
#   - Network to deb.debian.org (if blocked in the sandbox, the build fails)
#
# Usage:
#   sudo ./build/00-debootstrap.sh bootstrap   # Build the rootfs
#   sudo ./build/00-debootstrap.sh image       # (optional) Build raw disk image for QEMU boot
#   ./build/00-debootstrap.sh check            # Check the environment
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

ARCH="${SAX_ARCH:-amd64}"
SUITE="${SAX_SUITE:-trixie}"
MIRROR="${SAX_MIRROR:-https://deb.debian.org/debian}"
VARIANT="${SAX_VARIANT:-minbase}"
ROOTFS_DIR="${SAX_ROOTFS:-$REPO_ROOT/rootfs}"
IMAGE_FILE="${SAX_IMAGE:-$REPO_ROOT/sayanox-0.0.1.img}"
IMAGE_SIZE="${SAX_IMAGE_SIZE:-4G}"
OVERLAY_DIR="$REPO_ROOT/overlay"

EXTRA_PKGS=(
  systemd-sysv
  dbus
  ca-certificates
  cron
  locales
)

step() { echo "==> $*"; }
err()  { echo "!! $*" >&2; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "Required command not found: $1"; return 1; }
}

require_root() {
  [ "$(id -u)" -eq 0 ] || { err "This step requires root (run with sudo)"; return 1; }
}

cmd_check() {
  echo "==> Sayanox OS Phase 0 environment check"
  local missing=0
  for c in mmdebstrap gpg qemu-system-x86_64 grub-install mksquashfs xorriso; do
    if command -v "$c" >/dev/null 2>&1; then
      echo "   [ok] $c"
    else
      echo "   [miss] $c"
      missing=1
    fi
  done
  echo "   arch: $(dpkg --print-architecture 2>/dev/null || uname -m)"
  echo "   suite: $SUITE  mirror: $MIRROR  rootfs: $ROOTFS_DIR"
  if [ "$missing" -ne 0 ]; then
    err "Some tools are missing — install them via your package manager (may not be possible if the sandbox blocks network)"
    return 1
  fi
  echo "==> All tools present"
}

cmd_bootstrap() {
  require_cmd mmdebstrap
  require_root

  step "Preparing: mmdebstrap $SUITE ($ARCH) -> $ROOTFS_DIR"
  mkdir -p "$ROOTFS_DIR"

  mmdebstrap \
    --arch="$ARCH" \
    --variant="$VARIANT" \
    --mode=chroot \
    "$SUITE" "$ROOTFS_DIR" "$MIRROR" \
    "${EXTRA_PKGS[@]}"

  step "Copying overlay files ($OVERLAY_DIR -> $ROOTFS_DIR)"
  cp -a "$OVERLAY_DIR/." "$ROOTFS_DIR/"

  step "Rootfs ready: $ROOTFS_DIR"
  echo "   Next: interactive test via sudo chroot $ROOTFS_DIR /bin/bash,"
  echo "   then build/10-branding.sh (locales, Plymouth, fonts, display manager)"
}

cmd_image() {
  require_cmd mmdebstrap || true
  require_cmd qemu-img || { err "Cannot build image without qemu-img"; return 1; }
  require_cmd grub-install || { err "Cannot build bootable image without grub-install"; return 1; }
  require_root

  if [ ! -d "$ROOTFS_DIR" ] || [ -z "$(ls -A "$ROOTFS_DIR")" ]; then
    err "Rootfs missing/empty — run 'bootstrap' first"
    return 1
  fi

  step "Creating raw disk image: $IMAGE_FILE ($IMAGE_SIZE)"
  qemu-img create -f raw "$IMAGE_FILE" "$IMAGE_SIZE"

  step "Partition + ext4"
  sfdisk "$IMAGE_FILE" <<'EOF'
label: dos
type=83, bootable
EOF
  LOOP="$(losetup -fP --show "$IMAGE_FILE")"
  mkfs.ext4 -q "${LOOP}p1"
  MNT="$(mktemp -d)"
  mount "${LOOP}p1" "$MNT"
  cp -a "$ROOTFS_DIR/." "$MNT/"

  step "Installing GRUB (i386-pc)"
  grub-install --target=i386-pc --boot-directory="$MNT/boot" --modules="part_msdos ext2" "$LOOP"

  cat > "$MNT/boot/grub/grub.cfg" <<'EOF'
set default=0
set timeout=5

menuentry "Sayanox OS" {
  linux   /boot/vmlinuz root=/dev/sda1 ro quiet
  initrd  /boot/initrd.img
}
EOF

  umount "$MNT"
  rmdir "$MNT"
  losetup -d "$LOOP"
  step "Image ready: $IMAGE_FILE  (QEMU: qemu-system-x86_64 -hda $IMAGE_FILE -m 2048)"
}

usage() {
  cat <<EOF
Usage: $0 {bootstrap|image|check}
  bootstrap - Build trixie minbase rootfs (mmdebstrap)
  image     - Build bootable raw disk image for QEMU (optional)
  check     - Check build environment
EOF
}

main() {
  case "${1:-}" in
    bootstrap) cmd_bootstrap ;;
    image)     cmd_image ;;
    check)     cmd_check ;;
    *)         usage; exit 1 ;;
  esac
}

main "$@"
