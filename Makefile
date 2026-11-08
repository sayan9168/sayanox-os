# Sayanox OS — Makefile (build orchestrator)
#
# Targets mirror the build/ scripts. Run on a Debian 13 build host with root/sudo.
#
#   make bootstrap   # Phase 0 — trixie minbase rootfs (mmdebstrap)
#   make branding    # Phase 1 — overlay branding (locales, plymouth, GRUB, SDDM)
#   make iso         # Phase 1 — squashfs + GRUB -> sayanox-0.0.1.iso
#   make image       # Phase 0 — raw disk image for QEMU
#   make check       # Validate build scripts syntax
#   make clean       # Remove generated build artifacts
#

.PHONY: bootstrap branding iso image check clean help

SAX_ROOTFS ?= $(CURDIR)/rootfs

help:
	@echo "Sayanox OS build targets:"
	@echo "  bootstrap  - Phase 0: trixie minbase rootfs (build/00-debootstrap.sh)"
	@echo "  branding   - Phase 1: overlay branding (build/10-branding.sh)"
	@echo "  iso        - Phase 1: squashfs + GRUB -> sayanox-0.0.1.iso (build/20-iso.sh)"
	@echo "  image      - Phase 0: raw QEMU disk image (build/00-debootstrap.sh image)"
	@echo "  check      - Validate shell script syntax"
	@echo "  clean      - Remove generated build artifacts"

bootstrap:
	sudo SAX_ROOTFS=$(SAX_ROOTFS) ./build/00-debootstrap.sh bootstrap

branding:
	sudo SAX_ROOTFS=$(SAX_ROOTFS) ./build/10-branding.sh apply

iso:
	sudo SAX_ROOTFS=$(SAX_ROOTFS) ./build/20-iso.sh iso

image:
	sudo SAX_ROOTFS=$(SAX_ROOTFS) ./build/00-debootstrap.sh image

check:
	@bash -n build/00-debootstrap.sh && echo "OK: build/00-debootstrap.sh"
	@bash -n build/10-branding.sh && echo "OK: build/10-branding.sh"
	@bash -n build/20-iso.sh && echo "OK: build/20-iso.sh"

clean:
	rm -rf rootfs image sayanox-0.0.1.iso sayanox-0.0.1.img
