# Sayanox OS — শীর্ষ-স্তর Makefile (ফেজ ০–১)
# সব টার্গেট মালিকের নিজস্ব লিনাক্স মেশিনে চালান (স্যান্ডবক্সে নয়; এখানে মমডেবস্ট্র্যাপ/কিউইএম নেই)।

SAX_ROOTFS ?= rootfs
SAX_ISO    ?= sayanox-0.0.1.iso
SAX_SQUASH ?= filesystem.squashfs

.PHONY: check bootstrap brand repo squashfs iso clean help

help:
	@echo "ব্যবহার: make <লক্ষ্য>"
	@echo "  check     - সকল স্ক্রিপ্টের চেক মোড চালায় (টুল যাচাই)"
	@echo "  bootstrap - ডেবিয়ান ১৩ ট্রিক্সি মিনবেস রুটফাইলসিস্টেম বানায় (00-debootstrap.sh)"
	@echo "  brand     - ব্র্যান্ডিং প্রয়োগ (10-branding.sh)"
	@echo "  repo      - সayanoksen apt রেপোর ভিত্তি তৈরি (20-repo.sh)"
	@echo "  squashfs  - লাইভ সquashfs বানায় (30-squashfs.sh)"
	@echo "  iso       - বুটেবল লাইভ ISO বানায় (40-iso.sh)"
	@echo "  clean     - রুটফাইলসিস্টেম, সquashfs, ISO মুছে ফেলে"

check:
	./build/00-debootstrap.sh check
	./build/10-branding.sh "$(SAX_ROOTFS)" check
	./build/20-repo.sh check
	./build/30-squashfs.sh check
	./build/40-iso.sh check

bootstrap:
	sudo ./build/00-debootstrap.sh bootstrap

brand: bootstrap
	sudo ./build/10-branding.sh "$(SAX_ROOTFS)" apply

repo:
	./build/20-repo.sh apply

squashfs: brand
	sudo ./build/30-squashfs.sh "$(SAX_ROOTFS)" "$(SAX_SQUASH)" apply

iso: squashfs repo
	sudo ./build/40-iso.sh "$(SAX_ROOTFS)" "$(SAX_SQUASH)" "$(SAX_ISO)" apply

clean:
	rm -rf "$(SAX_ROOTFS)" "$(SAX_SQUASH)" "$(SAX_ISO)" sayanox-iso-*
