#!/usr/bin/env bash
#
# build/20-repo.sh — Sayanox OS Phase 1: নিজস্ব APT রেপোর dasar
# deb.sayanox.org-এর জন্য GPG কী, sayanox-archive-keyring .deb কঙকার এবং sources.list এন্ট্রি তৈরি।
#
# দ্যাখো: আসল পাবলিক রেপো (aptly) deb.sayanox.org-এ মালিকের মেশিনে হোস্ট করবে।
# এই স্ক্রিপ্ট শুধু কী-জেনারেশন, কInflিং প্যাকেজ কঙকার এবং ক্লায়েন্ট কনফিগারেশন ভিত্তি তৈরি করে।
#
# ব্যবহার:
#   ./build/20-repo.sh check   # গpg/dpkg-deb আছে কি না
#   ./build/20-repo.sh apply   # কী ও আর্কাইভ-কInflিং রিং .deb তৈরি
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../repo-staging" && pwd)"
GPG_HOME="$REPO_DIR/gnupg"
KEY_NAME="Sayanox Archive Signing Key"
KEY_EMAIL="archive@sayanox.org"

fail() { echo "!! $*" >&2; exit 1; }
step() { echo "==> $*"; }

cmd_check() {
  echo "==> 20-repo চেক"
  local missing=0
  for c in gpg gpg-agent dpkg-deb; do
    command -v "$c" >/dev/null 2>&1 || { echo "   [miss] $c"; missing=1; }
  done
  [ "$missing" -eq 0 ] || fail "20-repo: প্রয়োজনীয় টুল অনুপস্থিত।"
  echo "   [ok] gpg, dpkg-deb উপস্থিত"
}

gen_gpg_key() {
  mkdir -p "$GPG_HOME"
  chmod 700 "$GPG_HOME"
  if ! gpg --homedir "$GPG_HOME" --list-secret-keys "$KEY_EMAIL" >/dev/null 2>&1; then
    step "GPG সাইনিং কী তৈরি ($GPG_HOME)"
    cat > "$GPG_HOME/key.batch" <<EOF
%echo Generating Sayanox archive key
Key-Type: RSA
Key-Length: 4096
Key-Usage: sign
Name-Real: $KEY_NAME
Name-Email: $KEY_EMAIL
Expire-Date: 0
%no-protection
%commit
%echo done
EOF
    gpg --homedir "$GPG_HOME" --batch --generate-key "$GPG_HOME/key.batch"
  else
    step "GPG কী پہلے থেকেই আছে, পুনরায় তৈরি করছি না"
  fi
}

cmd_apply() {
  step "স্টেজিং ডিরেক্টরি: $REPO_DIR"
  mkdir -p "$REPO_DIR"
  gen_gpg_key

  step "পাবলিক কী রপ্তানি: $REPO_DIR/sayanox-archive-keyring.gpg"
  gpg --homedir "$GPG_HOME" --export "$KEY_EMAIL" > "$REPO_DIR/sayanox-archive-keyring.gpg"

  step "sayanox-archive-keyring .deb কঙকার"
  PKG_ROOT="$REPO_DIR/keyring-pkg"
  rm -rf "$PKG_ROOT"; mkdir -p "$PKG_ROOT/usr/share/keyrings" "$PKG_ROOT/DEBIAN"
  cp "$REPO_DIR/sayanox-archive-keyring.gpg" "$PKG_ROOT/usr/share/keyrings/"
  cat > "$PKG_ROOT/DEBIAN/control" <<EOF
Package: sayanox-archive-keyring
Version: 0.0.1
Section: admin
Priority: optional
Architecture: all
Maintainer: Sayan (sayan9168) <archive@sayanox.org>
Description: Sayanox archive signing key
 GPG public key for apt repo deb.sayanox.org.
EOF
  dpkg-deb --root-owner-group -b "$PKG_ROOT" "$REPO_DIR/sayanox-archive-keyring_0.0.1_all.deb"

  step "ক্লায়েন্ট sources.list নমুনা (রեպো হোস্ট করা হবে deb.sayanox.org-এ):"
  cat <<'EOF'
# /etc/apt/sources.list.d/sayanox.list (মালিকের মেশিনে আমলাওয়া হয়ে bleiben)
deb [signed-by=/usr/share/keyrings/sayanox-archive-keyring.gpg] https://deb.sayanox.org/ trixie main
EOF

  step "20-repo রady: $REPO_DIR"
  echo "   পরের ধাপ: aptly দিয়ে deb.sayanox.org হোস্ট, তারপর build/30-squashfs.sh"
}

case "${1:-}" in
  check) cmd_check ;;
  apply) cmd_apply ;;
  *)     echo "ব্যবহার: $0 {check|apply}" >&2; exit 1 ;;
esac
