# Sayanox OS Roadmap (Plan of Record)

**সিদ্ধান্ত (পরিবর্তন করব না):**
- বেস: Debian 13 "trixie" (LFS বছর ২+-এ স্থগিত)
- বুটস্ট্র্যাপ টুল: mmdebstrap (debootstrap নয়)
- আর্কিটেকচার: x86_64 প্রথম, arm64 পরে
- ডেস্কটপ: KDE Plasma 6
- ইন্সটলার: Calamares (+ কাস্টম ব্র্যান্ডিং মডিউল)
- প্যাকেজ ফরম্যাট: .deb কেবল (নতুন ফরম্যাট নেই)
- ID_LIKE=debian বাধ্যতামূলক
- Sayanox টুল (.sa) শুধু — পাইথন/ব্যাশ ব্যবহারকারী ব্যবহারকারিমুখী টুল নেই

---

## Phase 0 (সপ্তাহ ১–২) — এখন চলছে
[r ] রেপো লেআউট: build/, overlay/, packages/, installer/, live/, docs/
[ ] build/00-debootstrap.sh — mmdebstrap দিয়ে trixie minbase রুটফাইলসিস্টেম (x86_64)
[ ] রুটফাইলসিস্টেম কিউইএমে বুট টেস্ট → sayanox-0.0.1-bootable

## Phase 1 (সপ্তাহ ২–৪) — ব্র্যান্ডিং + লাইভ আইএসও
[ ] /etc/os-release, /etc/issue (Sayanox OS, ID_LIKE=debian)
[ ] GRUB থিম + পlymouth স্প্ল্যাশ, Bengali ফন্ট (fonts-noto-bengali)
[ ] লোকেল bn_IN.UTF-8 + en_US.UTF-8, ডিসপ্লে ম্যানেজার
[ ] squashfs + GRUB → sayanox-0.0.1.iso বুট

## Phase 2 (মাস ১–২) — পরিচয় স্তর (সর্বাধিক গুরুত্বপূর্ণ)
[ ] sx as .deb at /usr/bin/sx + stdlib at /usr/lib/sayanox/stdlib
[ ] .sa MIME type (text/x-sayanox), এডিটর গ্রামার, ম্যান পেইজ
[ ] 7 টি sayanox-* টুল .sa-এ (fetch, welcome, install, update, doctor, backup, driver)
[ ] নিজস্য APT রেপো (deb.sayanox.org, aptly + gpg, sayanox-archive-keyring)
[ ] Plasma গ্লোবাল থিম, वालপেপার, আইকন, কার্সার, শব্দ
[ ] মাইলস্টোন: sayanox-0.1-alpha

## Phase 3 (মাস ২–৪) — ইন্সটলার + সুরক্ষা
[ ] Calamares + ব্র্যান্ডিং, LUKS
[ ] UEFI + সিকিউর বুট (ডেবিয়ান সাইনড শিম)
[ ] ডেভেলপার টুলচেইন টগল, ওয়েবসাইট, DistroWatch লিস্টিং
[ ] মাইলস্টোন: sayanox-0.2

## Phase 4 (মাস ৪–৮) — পার্থক্য
[ ] sx pkg (প্যাকেজ ম্যানেজার ফ্রন্টএンド)
[ ] linux-image-sayanox কার্নেল ফ্লেভার
[ ] .sa-এ টুইউ অ্যাপ, GTK4/Qt বাইন্ডিং, প্রথম GUI অ্যাপ .sa-এ
[ ] বাংলা ফাস্ট-ফিচার (IME, TTS, অফলাইন ডিকশনারি/উইকিপিডিয়া), লো-স্পেস প্রোফাইল
[ ] মাইলস্টোন: sayanox-1.0

## Phase 5 (বছর ২+) — এক Évolution
[ ] LFS VM শেখার প্রজেক্ট (শিপিং বেস নয়)
[ ] ডেবিয়ান কম্পোনেন্ট এক-এক করে প্রতিস্থাপন (ইনিশ, শেল, কোরউটিলস, প্যাকেজ ম্যানেজার) রোলব্যাক পাথে

---

## নিষেধাজ্ঞা (হার্ড কনস্ট্রেইন্ট)
- ডেবিয়ান রেপো ফর্ক করব না; আপস্ট্রিম আর্কাইভ অক্ষত থাকবে
- একই সাথে x86_64 ও arm64 শিপ করব না
- নিজস্ব কার্নেলে ফায়ারফক্সের প্রতিশ্রুতি দেব না (此之前 ডিসকাশন-এ বন্ধ)
