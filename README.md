```
                                                                          
 ██████╗  █████╗ ██╗   ██╗███████╗███╗   ██╗██╗  ██╗    ██╗     ██╗      ██████╗
 ██╔══██╗██╔══██╗██║   ██║██╔════╝████╗  ██║╚██╗██╔╝    ██║     ██║     ██╔════╝
 ██████╔╝███████║██║   ██║█████╗  ██╔██╗ ██║ ╚███╔╝     ██║     ██║     ██║     
 ██╔══██╗██╔══██║╚██╗ ██╔╝██╔══╝  ██║╚██╗██║ ██╔██╗     ██║     ██║     ██║     
 ██║  ██║██║  ██║ ╚████╔╝ ███████╗██║ ╚████║██╔╝ ██╗    ███████╗███████╗╚██████╗
 ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝    ╚══════╝╚══════╝ ╚═════╝
                                                                          
      ┌─────────────────────────────────────────────────────────────┐
      │  TAHOE PATCHER v3.1.7r  ·  macOS 26.x on Unsupported Macs  │
      │  Built on OpenCore Legacy Patcher  ·  First to Market       │
      └─────────────────────────────────────────────────────────────┘
```

# RavenX LLC — Tahoe Patcher

**macOS Tahoe (26.x) on every Mac that deserves it.**

Based on OpenCore Legacy Patcher by Dortania + YBronst Tahoe patchset by lzhoang2801.
Enhanced by [RavenX LLC](https://github.com/DeadByDawn101) with critical fixes for
iMac Pro, 2017 MacBook Pro, and Intel Kaby Lake GPUs.

---

## What We Fixed (Upstream Had 6 Bugs)

| # | Bug | Impact | Machines Affected |
|---|-----|--------|-------------------|
| 1 | `iMacPro1,1` missing from `SupportedSMBIOS` | Patcher refuses to run | iMac Pro (2017) |
| 2 | AMD Vega patches excluded CPUs with AVX2 | No GPU acceleration | iMac Pro (Skylake Xeon has AVX2) |
| 3 | iMac Pro `Max OS` set to 99 (max_os) | Patcher thinks it's natively supported | iMac Pro |
| 4 | `iMacPro1,1` missing from `AGDPSupport` | No Apple Graphics Device Policy patch | iMac Pro |
| 5 | Dead code in `modern_wireless.py` | Unreachable return statement | All Macs |
| 6 | **Intel Kaby Lake iGPU not in Skylake patchset** | **No GPU acceleration at all** | **All 2017 MacBook Pros (13")** |

Bug #6 was found during our HARD QA pass. Every 2017 MacBook Pro 13" running Tahoe
via upstream OCLP-YBronst would have booted into software rendering — unusable.

## Compatibility

| macOS Version | Status |
|---------------|--------|
| macOS Tahoe 26.0 (25A5316i) | ✅ Supported |
| macOS Tahoe 26.1 – 26.3 | ✅ Supported |
| macOS Tahoe 26.4 (25E5233c) | ✅ Supported |
| Future 26.x builds | Should work |

## Tested / Target Hardware

| Machine | GPU | Patches Applied | Status |
|---------|-----|-----------------|--------|
| **iMac Pro (2017)** `iMacPro1,1` | AMD Vega 56 (8GB HBM2) | Vega Metal + Audio + WiFi | RavenX fixed |
| **MacBook Pro 13" (2017)** `MacBookPro14,1` | Intel Iris Plus 640 | Kaby Lake Metal + Audio + WiFi | RavenX fixed |
| **MacBook Pro 13" (2017)** `MacBookPro14,2` | Intel Iris Plus 650 | Kaby Lake Metal + Audio + WiFi | RavenX fixed |
| **MacBook Pro 15" (2017)** `MacBookPro14,3` | Intel HD 630 + Polaris dGPU | Kaby Lake + Polaris Metal | Upstream OK |
| All other OCLP-supported Macs | Various | Per upstream | Upstream OK |

## ⚠️ Important Notes

* **AMFIPass cannot be used** — causes kernel panics on 3.1.7. Use `amfi=0x80` boot argument.
* **Kernel Debug Kit (KDK)** required for audio patches. Download via Help menu in the patcher.
* **Modern Audio toggle** in Root Patches menu — disable if no matching KDK installed.
* **HFS+ removed in Tahoe 26.4** — patching logic adapted for APFS-only environment.

## Quick Start

### Prerequisites
- A working Mac to build the patcher and create the installer
- 16GB+ USB drive
- Target Mac running macOS Sequoia or earlier

### Install

```bash
# Clone
git clone https://github.com/DeadByDawn101/OCLP-YBronst.git
cd OCLP-YBronst

# Build
pip3 install -r requirements.txt
python3 Build-Project.command

# Or download from Releases:
# https://github.com/DeadByDawn101/OCLP-YBronst/releases
```

### Patch Your Mac

1. **Build OpenCore EFI** — Open the patcher, select your Mac model, build + install to USB/internal
2. **Create Tahoe USB** — Use the patcher to download and create a macOS Tahoe installer
3. **Install Tahoe** — Boot from OpenCore, install macOS Tahoe
4. **Apply Root Patches** — After install, open patcher → Post-Install Root Patch → Apply All
5. **Reboot** — GPU acceleration, audio, WiFi should all work
6. **Required:** `amfi=0x80` boot argument

## What Gets Patched

### iMac Pro (2017)

| Component | Source | Patch |
|-----------|--------|-------|
| AMD Vega GPU | Monterey 12.5 | Legacy Metal 31001 + AMDRadeonX5000 drivers |
| Audio | Tahoe Beta 1 KDK | AppleHDA.kext restoration |
| OpenCL | Monterey 12.5 | AMD OpenCL downgrade |
| Video Decode | Native | GVA reverted (Vega supports current stack) |
| WiFi | Ventura 13.7.2 | IO80211, WiFiPeerToPeer, wifip2pd |
| AGDP | OpenCore | Apple Graphics Device Policy bypass |

### 2017 MacBook Pro (13")

| Component | Source | Patch |
|-----------|--------|-------|
| Intel Kaby Lake iGPU | Monterey 12.5 | AppleIntelSKLGraphics + framebuffers |
| Audio | Tahoe Beta 1 KDK | AppleHDA.kext restoration |
| OpenCL | Monterey 12.5 | Intel OpenCL downgrade |
| WiFi | Ventura 13.7.2 | IO80211, WiFiPeerToPeer, wifip2pd |

### 2017 MacBook Pro (15")

Same as 13" plus AMD Polaris dGPU patches (AMDRadeonX4000 driver stack).

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                 RavenX LLC Tahoe Patcher                 │
│                                                          │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐  │
│  │  EFI Builder │  │  Root Patcher │  │  KDK Handler   │  │
│  │  (OpenCore)  │  │  (sys_patch)  │  │  (kdk_handler) │  │
│  └──────┬───────┘  └──────┬───────┘  └───────┬────────┘  │
│         │                 │                   │           │
│  ┌──────▼─────────────────▼───────────────────▼────────┐  │
│  │                  Patchset Detection                  │  │
│  │  AMD Vega · Polaris · GCN · Intel SKL/KBL · Audio   │  │
│  │  Modern Wireless · Bluetooth · USB · GMUX            │  │
│  └──────────────────────┬──────────────────────────────┘  │
│                         │                                 │
│  ┌──────────────────────▼──────────────────────────────┐  │
│  │              SMBIOS / Hardware Detection             │  │
│  │  iMacPro1,1 · MacBookPro14,x · MacPro6,1 · ...     │  │
│  └─────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

## Changelog

### v3.1.7r (RavenX LLC)
- **Added:** iMac Pro (`iMacPro1,1`) full Tahoe support
- **Added:** Intel Kaby Lake to Skylake GPU patchset (covers all 2017 MacBook Pros)
- **Fixed:** AMD Vega patches now apply to Skylake+ CPUs with AVX2
- **Fixed:** iMac Pro Max OS set to Sequoia (was incorrectly max_os)
- **Fixed:** iMac Pro added to AGDPSupport array
- **Fixed:** Dead code removed from `modern_wireless.py`
- **QA:** 21/21 checks passed, 136 Python files validated, 0 errors

### v3.1.7 (upstream YBronst)
- Full support for macOS Tahoe 26.0 through 26.4
- HFS+ removal adaptation for APFS-only Tahoe 26.4
- hdiutil permissions fix for Tahoe 26.4
- Modern Audio toggle in Root Patches menu
- KDK download button in Help menu

## Credits

```
 ╔══════════════════════════════════════════════════╗
 ║              RavenX LLC Engineering              ║
 ║  "We don't work with what's possible now.       ║
 ║   We MAKE things possible."                     ║
 ╚══════════════════════════════════════════════════╝
```

* **[RavenX LLC](https://github.com/DeadByDawn101)** — iMac Pro support, Kaby Lake fix, QA automation
* [YBronst](https://github.com/YBronst) — Original OCLP Tahoe fork
* [lzhoang2801](https://github.com/lzhoang2801) — Tahoe patchset foundation
* [Acidanthera](https://github.com/Acidanthera) — OpenCorePkg and core kexts
* [DhinakG](https://github.com/DhinakG) & [Khronokernel](https://github.com/Khronokernel) — OCLP co-authors
* [EduCovas](https://github.com/covasedu) — Metal patches, GCN/Vega shims, legacy WiFi
* All [OCLP contributors](https://github.com/dortania/OpenCore-Legacy-Patcher)

## Part of the Star Platinum Cluster Project

This patcher is a component of the [Star Platinum distributed AI supercomputer](https://github.com/DeadByDawn101/star-platinum-cluster) — a first-of-its-kind local cluster unifying Apple Neural Engine compute, Thunderbolt networking, and distributed inference across Mac hardware from 2013 to 2024.

## Disclaimer

This is not an official Dortania release. Use at your own risk. Always have a backup.

**Community:** [InsanelyMac thread](https://www.insanelymac.com/forum/topic/362042-experimental-fork-of-oclp-300-nightly-–-wi-fi-airdropairplay-and-applehda-fully-working-under-tahoe/)

---

<p align="center">
<sub>RavenX LLC · 2026 · First to Market</sub>
</p>
