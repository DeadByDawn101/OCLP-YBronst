```
                          ▄▄▄▄▄▄▄▄▄▄▄▄▄
                      ▄██████████████████████▄
                   ▄████▀▀░░░░░░░░░░░░░░▀▀█████▄
                 ▄███▀░░▄▄████████████████▄▄░░▀███▄
               ▄██▀░░▄██▀▀░░░░░░░░░░░░░░▀▀██▄░░▀██▄
              ███░░▄██░░▓▓▓▓▓▒░░░░░░░▒▓▓▓▓▓░░██▄░░███
             ██▀░▄██░▓█▓░░ ▄██▄ ░░░░░ ▄██▄ ░░▓█▓░██▄░▀██
            ██░░██▀░▓█░░░ █▀▀██ ░░░░░ ██▀▀█ ░░░█▓░▀██░░██
           ██░▄█▀░▓█▓░░░░ ▀████ ░░░░░ ████▀ ░░░░▓█▓░▀█▄░██
          ██░██░░▓█▓░░░░░░░░░░░░░▓▓░░░░░░░░░░░░░░▓█▓░░██░██
         ██░██░░█▓░░░░░░░░░░░░░░▓██▓░░░░░░░░░░░░░░▓█░░██░██
         █▌▐█░░█▓░░▒▓████▓▒░░░░░░░░░░░░░▒▓████▓▒░░▓█░░█▌▐█
         █▌▐█░▓█░▒████▀▀▀████▒░░░░░░░░▒████▀▀▀████▒░█▓░█▌▐█
         █▌▐█░█▓░████░░░░░░████░░░░░░████░░░░░░████░▓█░█▌▐█
         █▌▐█░█▓░▀████▄▄▄████▀░░▓▓▓░░▀████▄▄▄████▀░▓█░█▌▐█
         █▌▐█░▓█░░▒▀▀██████▀▒░▓█████▓░▒▀██████▀▀▒░░█▓░█▌▐█
         ██░█░░█▓░░░░░░░░░░░▓███▀▀▀███▓░░░░░░░░░░░▓█░░█░██
          █░██░░█▓░░░░░░░░▓███▀░░░░░▀███▓░░░░░░░░▓█░░██░█
          ██░██░░▓█▓░░░░▓███▀░░░░░░░░░▀███▓░░░░▓█▓░░██░██
           ██░██▄░░▓██▓████░░░░░░░░░░░░░████▓██▓░░▄██░██
            ██░░██▄░░░▓████░░░░░░░░░░░░░████▓░░░▄██░░██
             ██▄░▀██▄░░░░▀████▄▄▄▄▄▄▄████▀░░░░▄██▀░▄██
              ▀██▄░░▀██▄░░░░▀▀████████▀▀░░░░▄██▀░░▄██▀
                ▀██▄░░▀███▄░░░░░░░░░░░░░░▄███▀░░▄██▀
                  ▀███▄░░▀████▄▄▄▄▄▄▄▄████▀░░▄███▀
                    ▀████▄░░░▀▀▀▀▀▀▀▀▀▀░░░▄████▀
                       ▀██████▄▄▄▄▄▄▄▄██████▀
                          ▀▀▀████████████▀▀▀

  ╔═══════════════════════════════════════════════════════════════╗
  ║   B I G   M O U T H   S T R I K E S   A G A I N             ║
  ║   ─────────────────────────────────────────────              ║
  ║   Stand User: RavenX LLC                                     ║
  ║   Stand Type: macOS Tahoe Patcher v3.1.7r                   ║
  ║   Power: A  Speed: A  Range: C  Persistence: A  Precision: A ║
  ║   "Sweetness, sweetness I was only joking                    ║
  ║    when I said I'd like to smash every Mac into Tahoe"       ║
  ╚═══════════════════════════════════════════════════════════════╝
```

# 「 BIG MOUTH STRIKES AGAIN 」

### *Stand Ability: Devours unsupported hardware restrictions. Reconstructs macOS Tahoe on machines Apple abandoned.*

**Stand User:** [RavenX LLC](https://github.com/DeadByDawn101)
**Stand Type:** Close-Range / Colony — operates on every Mac in the cluster simultaneously
**Destructive Power:** A — tears apart 6 upstream bugs that blocked GPU acceleration
**Speed:** A — automated QA catches blockers in seconds
**Range:** C — requires physical access to target Mac
**Persistence:** A — patches survive reboots via OpenCore EFI
**Precision:** A — 21/21 QA checks, 136 Python files validated

Based on OpenCore Legacy Patcher by Dortania + YBronst Tahoe patchset.
Enhanced by RavenX LLC with critical fixes for iMac Pro, 2017 MacBook Pro,
and Intel Kaby Lake GPUs that upstream missed entirely.

### [Running from source](https://github.com/YBronst/OCLP-YBronst/blob/main/SOURCE.md)

---

## Stand Ability: 「 DEVOUR & RECONSTRUCT 」

Six restrictions devoured. Six patches applied. Hardware reborn.

| # | Restriction Devoured | What It Blocked | Machines Freed |
|---|---------------------|-----------------|----------------|
| 1 | `iMacPro1,1` excluded from SupportedSMBIOS | Patcher refused to run | iMac Pro (2017) |
| 2 | AMD Vega patches excluded AVX2 CPUs | Zero GPU acceleration | iMac Pro (Skylake Xeon) |
| 3 | iMac Pro Max OS = 99 | Patcher thought it was native | iMac Pro |
| 4 | iMacPro1,1 excluded from AGDPSupport | No AGDP patching | iMac Pro |
| 5 | Dead code in modern\_wireless.py | Unreachable return | All Macs |
| 6 | **Intel Kaby Lake iGPU missing from patches** | **No GPU at all** | **Every 2017 MacBook Pro 13"** |

Bug #6 is the one that would have sent your 2017 MacBook Pro to software rendering hell.
Big Mouth devoured it.

## Compatibility

| macOS Version | Status |
|---------------|--------|
| macOS Tahoe 26.0 (25A5316i) | ✅ |
| macOS Tahoe 26.1 – 26.3 | ✅ |
| macOS Tahoe 26.4 (25E5233c) | ✅ |

## Target Hardware

| Machine | GPU | Stand Effect |
|---------|-----|-------------|
| **iMac Pro (2017)** `iMacPro1,1` | AMD Vega 56 | Vega Metal restored |
| **MacBook Pro 13" (2017)** `MacBookPro14,1/14,2` | Intel Kaby Lake | Kaby Lake Metal restored |
| **MacBook Pro 15" (2017)** `MacBookPro14,3` | Kaby Lake + Polaris | Dual GPU patched |
| All other OCLP Macs | Various | Upstream patches apply |

## ⚠️ Stand Limitations

* **AMFIPass** causes kernel panics — use `amfi=0x80` boot argument instead
* **KDK** required for audio (AppleHDA). Download via Help menu.
* **Modern Audio toggle** in Root Patches — disable if no matching KDK.

## Summoning the Stand

```bash
# Manifest
git clone https://github.com/DeadByDawn101/OCLP-YBronst.git
cd OCLP-YBronst

# Materialize
pip3 install -r requirements.txt
python3 Build-Project.command
```

### Stand Rush (Patch Sequence)

1. **ORA** — Build OpenCore EFI → install to USB
2. **ORA** — Create macOS Tahoe installer on USB
3. **ORA** — Boot from OpenCore → install Tahoe
4. **ORA** — Run patcher → Post-Install Root Patch → Apply All
5. **ORAAAA!** — Reboot. GPU acceleration. Audio. WiFi. Everything.
6. Boot arg required: `amfi=0x80`

## What Gets Patched

### iMac Pro (2017) — Vega 56

| Component | Source | Patch |
|-----------|--------|-------|
| AMD Vega GPU | Monterey 12.5 | Legacy Metal 31001 + AMDRadeonX5000 |
| Audio | Tahoe Beta 1 KDK | AppleHDA.kext |
| OpenCL | Monterey 12.5 | AMD OpenCL downgrade |
| Video Decode | Native | GVA reverted |
| WiFi | Ventura 13.7.2 | IO80211 + WiFiPeerToPeer |
| AGDP | OpenCore | Graphics Device Policy bypass |

### 2017 MacBook Pro 13" — Intel Kaby Lake

| Component | Source | Patch |
|-----------|--------|-------|
| Intel Kaby Lake iGPU | Monterey 12.5 | AppleIntelSKLGraphics |
| Audio | Tahoe Beta 1 KDK | AppleHDA.kext |
| OpenCL | Monterey 12.5 | Intel OpenCL downgrade |
| WiFi | Ventura 13.7.2 | IO80211 + WiFiPeerToPeer |

### 2017 MacBook Pro 15" — Kaby Lake + Polaris dGPU

Same as 13" plus AMD Polaris patches (AMDRadeonX4000 stack).

## Stand Stats

```
 ╔══════════════════════════════════════════════════════╗
 ║         「 BIG MOUTH STRIKES AGAIN 」                 ║
 ║                                                      ║
 ║   Stand User ............ RavenX LLC                 ║
 ║   Version ............... 3.1.7r                     ║
 ║   Bugs Devoured ......... 6                          ║
 ║   QA Checks Passed ...... 21/21                      ║
 ║   Python Files Clean .... 136/136                    ║
 ║   Machines Freed ........ iMac Pro + 2017 MBP        ║
 ║   First to Market ....... Yes                        ║
 ║                                                      ║
 ║   "Now I know how Joan of Arc felt"                  ║
 ╚══════════════════════════════════════════════════════╝
```

## Changelog

### v3.1.7r「BIG MOUTH STRIKES AGAIN」
- **Devoured:** iMac Pro exclusion from SupportedSMBIOS + AGDPSupport
- **Devoured:** AMD Vega AVX2 CPU exclusion
- **Devoured:** iMac Pro wrong Max OS (was 99, now sequoia)
- **Devoured:** Intel Kaby Lake missing from Skylake GPU patchset
- **Devoured:** Dead code in modern\_wireless.py
- **Reconstructed:** Full Tahoe support for iMac Pro + all 2017 MacBook Pros
- **QA:** 21/21 passed, 136 files validated, 0 errors

### v3.1.7 (upstream)
- macOS Tahoe 26.0–26.4 support
- HFS+ removal adaptation
- hdiutil permissions fix
- Modern Audio toggle + KDK download

## Credits

* **[RavenX LLC](https://github.com/DeadByDawn101)** — Stand User. 6 bugs devoured, iMac Pro + Kaby Lake freed.
* [YBronst](https://github.com/YBronst) — Original Tahoe fork
* [lzhoang2801](https://github.com/lzhoang2801) — Tahoe patchset foundation
* [Acidanthera](https://github.com/Acidanthera) — OpenCorePkg
* [DhinakG](https://github.com/DhinakG) & [Khronokernel](https://github.com/Khronokernel) — OCLP
* [EduCovas](https://github.com/covasedu) — Metal patches, WiFi
* All [OCLP contributors](https://github.com/dortania/OpenCore-Legacy-Patcher)

## Part of「STAR PLATINUM」

This Stand is a component of the [Star Platinum distributed AI supercomputer](https://github.com/DeadByDawn101/star-platinum-cluster) — 5 nodes, 46.9 ANE TFLOPS, 216 GB unified memory, Thunderbolt ring topology.

Other Stands in the cluster:
- 「**Star Platinum**」 — The cluster itself
- 「**Bohemian Rhapsody**」 — Creative AI studio (ComfyUI + ANE)
- 「**Big Mouth Strikes Again**」 — This patcher
- 「**Hermit Purple**」 — macOS ARM on Intel x86 via QEMU

---

<p align="center">
<sub>RavenX LLC · 2026 · 「We don't work with what's possible. We MAKE things possible.」</sub>
</p>
