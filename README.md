# OCLP-YBronst 3.1.7 — Tahoe Patch Set (iMac Pro Enabled)

**Based on the lzhoang2801 Tahoe patchset (Dec 24, 2025 state).**
**Fork: [DeadByDawn101/OCLP-YBronst](https://github.com/DeadByDawn101/OCLP-YBronst)**

## What this fork adds

This fork enables **iMac Pro (2017)** support on macOS Tahoe, which was missing from the upstream OCLP-YBronst. The iMac Pro has a unique combination of Skylake Xeon (with AVX2) and AMD Vega GPU that upstream didn't properly handle.

### Fixes applied

| Fix | File | Issue |
|-----|------|-------|
| **iMac Pro in SupportedSMBIOS** | `model_array.py` | `iMacPro1,1` was commented out — OCLP refused to run |
| **Vega AVX2 exclusion removed** | `amd_vega.py` | Vega patches only applied to CPUs *without* AVX2. The iMac Pro's Skylake Xeon *has* AVX2, so Vega GPU patches silently skipped. Apple dropped Vega by GPU arch, not CPU feature. |
| **Max OS set to Sequoia** | `smbios_data.py` | Was `max_os` (99), making patcher think iMac Pro is still natively supported. Changed to `sequoia` since Tahoe dropped all Intel Macs. |
| **iMac Pro in AGDPSupport** | `model_array.py` | Needed for Apple Graphics Device Policy patching |
| **Dead code removed** | `modern_wireless.py` | Unreachable `return _base` after a return statement |

## Compatibility

| macOS Version | Status |
|---------------|--------|
| macOS Tahoe 26.0 (25A5316i) | Supported |
| macOS Tahoe 26.1 | Supported |
| macOS Tahoe 26.2 | Supported |
| macOS Tahoe 26.3 | Supported |
| macOS Tahoe 26.4 (25E5233c) | Supported |

## Tested / Target Hardware

| System | GPU | Status |
|--------|-----|--------|
| **iMac Pro (2017)** `iMacPro1,1` | AMD Radeon Pro Vega 56 (8GB HBM2) | Patched — Vega Metal + Audio |
| Mac Pro (2013) `MacPro6,1` | AMD FirePro D-series | Supported via upstream |
| All other OCLP-supported Macs | Various | Supported via upstream |

## ⚠️ Important Notes

* **AMFIPass cannot be used** with OCLP 3.1.7 due to persistent kernel panics. Use the `amfi=0x80` boot argument instead.
* **Kernel Debug Kit (KDK)** is required for audio patches (AppleHDA). Download via the Help menu button in OCLP.
* **Modern Audio toggle** in Root Patches menu controls AppleHDA restoration. Disable it if you don't have a matching KDK.
* **HFS+ removed in macOS 26.4** — this version adapts patching logic for the APFS-only environment.

## Quick Start — iMac Pro on Tahoe

### Prerequisites
- A working Mac to build OCLP and create the installer
- 16GB+ USB drive for the macOS Tahoe installer
- Your iMac Pro currently running macOS Sequoia (or earlier)

### Step 1: Build OCLP

On any working Mac:

```bash
git clone https://github.com/DeadByDawn101/OCLP-YBronst.git
cd OCLP-YBronst
pip3 install -r requirements.txt
python3 Build-Project.command
```

Or download the pre-built app from [Releases](https://github.com/DeadByDawn101/OCLP-YBronst/releases).

### Step 2: Create OpenCore EFI + USB Installer

1. Open OpenCore-Patcher
2. Select **iMac Pro (2017)** as the target model (should auto-detect if running on the iMac Pro)
3. Build and install the OpenCore EFI to USB or internal drive
4. Use OCLP to download and create a macOS Tahoe installer on USB

### Step 3: Install macOS Tahoe

1. Boot from the OpenCore USB drive
2. Select the Tahoe installer
3. Install macOS Tahoe (will take ~30–60 minutes)
4. After install, boot again from OpenCore

### Step 4: Apply Root Patches

1. Open OpenCore-Patcher on the fresh Tahoe install
2. Go to **Post-Install Root Patch**
3. Apply all detected patches (Vega GPU, Audio, etc.)
4. Reboot

### Step 5: Verify

After reboot, verify:
- GPU acceleration works (About This Mac → Radeon Pro Vega 56 with Metal)
- Audio works (System Preferences → Sound)
- Wi-Fi works
- Thunderbolt 3 ports are functional

## What Gets Patched on iMac Pro

| Component | Patch | Source |
|-----------|-------|--------|
| **AMD Vega GPU** | Legacy Metal 31001 + AMDRadeonX5000 framebuffers, MTL/GL/VA drivers | Monterey 12.5 binaries |
| **Audio (AppleHDA)** | Restored from Tahoe Beta 1 (removed in release) | KDK required |
| **OpenCL** | Monterey OpenCL + AMD OpenCL downgrade | Monterey 12.5 |
| **GVA (Video Decode)** | Reverted to native (Vega supports current GVA) | Native |
| **Wireless** | Modern wireless common patches (IO80211, WiFiPeerToPeer, wifip2pd) | Ventura 13.7.2 |
| **AGDP** | Apple Graphics Device Policy bypass | OpenCore |

## Changelog

### 3.1.7-imacpro (this fork)
- **Added:** iMac Pro (iMacPro1,1) to SupportedSMBIOS and AGDPSupport
- **Fixed:** AMD Vega patches now apply to Skylake+ CPUs with AVX2
- **Fixed:** iMac Pro Max OS set to Sequoia (was incorrectly max_os)
- **Fixed:** Dead code removed from modern_wireless.py

### 3.1.7 (upstream YBronst)
- Full support for macOS Tahoe 26.0 through 26.4
- HFS+ removal adaptation for APFS-only Tahoe 26.4
- hdiutil permissions fix for Tahoe 26.4
- Modern Audio toggle in Root Patches menu
- KDK download button in Help menu

## Credits

* [YBronst](https://github.com/YBronst) — Original OCLP Tahoe fork maintainer
* [lzhoang2801](https://github.com/lzhoang2801) — Tahoe patchset foundation
* [Acidanthera](https://github.com/Acidanthera) — OpenCorePkg and core kexts
* [DhinakG](https://github.com/DhinakG) & [Khronokernel](https://github.com/Khronokernel) — OCLP co-authors
* [EduCovas](https://github.com/covasedu) — Metal bundle patches, GCN/Vega shims, legacy WiFi
* All other [OCLP contributors](https://github.com/dortania/OpenCore-Legacy-Patcher) — see full credits in upstream

## Disclaimer

This is **not an official Dortania release**. Use at your own risk. Always have a backup before upgrading macOS.

**Community discussion:** [InsanelyMac thread](https://www.insanelymac.com/forum/topic/362042-experimental-fork-of-oclp-300-nightly-%E2%80%93-wi-fi-airdropairplay-and-applehda-fully-working-under-tahoe/)
