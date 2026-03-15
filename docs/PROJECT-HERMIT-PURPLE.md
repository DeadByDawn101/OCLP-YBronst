# Project Hermit Purple — macOS ARM on Intel x86 via QEMU

## The Thesis

Apple Silicon macOS can be emulated on Intel x86 hardware using QEMU's TCG
(Tiny Code Generator) software instruction translation. The ChefKissInc/QEMUAppleSilicon
project has already built the critical infrastructure — full Apple A13 SoC emulation,
XNU kernel patching, SEP simulation, DART IOMMU, and the boot chain — all running
on pure TCG with ZERO hardware virtualization (HVF) dependencies.

The gap from "iOS on emulated A13" to "macOS on emulated M1" is an engineering
problem, not a physics problem. Same XNU kernel, same iBoot chain, same DART,
same AIC, same SEP. macOS just needs a scaled-up SoC definition and a different
kernelcache source.

## Why This Matters for the Cluster

The iMac Pro (Xeon W-2140B, 32GB RAM) currently runs macOS Tahoe x86 via OCLP.
If we can run macOS ARM in QEMU on the same hardware, we get:

1. **ANE software emulation path** — even without real ANE hardware, the macOS ARM
   environment exposes the CoreML/ANE API surface. Compute dispatches to CPU fallback,
   but the API contract is identical. Code written for ANE on Apple Silicon works
   unchanged.

2. **Unified development environment** — all cluster nodes speak the same macOS ARM
   dialect. No more x86 vs ARM code paths.

3. **Future-proofing** — when Apple drops Intel entirely (post-Tahoe), the Intel
   hardware in the cluster keeps running macOS ARM via emulation.

## Architecture Analysis

### What ChefKiss Already Built

```
Layer 5: XNU Kernel Patches (kernel_patches.c + patcher.c)
         ├── APFS filesystem bypass
         ├── AMFI (Apple Mobile File Integrity) bypass
         ├── SEP Manager bypass
         ├── IMG4 signature verification bypass
         ├── Code signing enforcement bypass
         ├── AMX (Apple Matrix Extensions) absence handling
         └── TrustCache validation bypass

Layer 4: SoC Hardware Emulation (t8030.c — iPhone 11)
         ├── Apple A13 CPU (6 cores, 2 clusters)
         ├── AIC (Apple Interrupt Controller)
         ├── DART (Device Address Resolution Table — Apple IOMMU)
         ├── SART (System Address Region Table)
         ├── ANS (Apple NVMe Storage)
         ├── PCIe root complex with MSI support
         ├── SEP simulator (Secure Enclave)
         ├── AES engine
         ├── Display pipeline (v2 + v4)
         ├── GPIO, I2C, SPI, UART
         ├── USB (Apple TypeC + OTG)
         ├── Watchdog timer
         ├── SMC (System Management Controller)
         ├── PMU (Power Management Unit)
         ├── SIO (System I/O DMA)
         └── Audio (AOP)

Layer 3: Boot Chain (boot.c)
         ├── IMG4 manifest parsing (ASN.1)
         ├── LZFSE/LZSS decompression
         ├── MH_FILESET kernelcache support (macOS Big Sur+)
         ├── Device tree construction
         ├── RAMDisk loading
         └── Boot argument passing

Layer 2: VMApple Device Model (vmapple.c)
         ├── GICv3 interrupt controller
         ├── Boot disk interface (BDIF)
         ├── AES engine
         ├── Graphics (apple-gfx)
         ├── UART serial
         ├── RTC
         ├── PCIe (GPEX)
         ├── GPIO
         └── Firmware loader (arm_load_kernel)

Layer 1: QEMU TCG (Software CPU Emulation)
         ├── AArch64 → x86_64 instruction translation
         ├── No HVF dependency (pure software)
         ├── Works on any x86_64 host
         └── ~10-50x performance penalty (acceptable for dev/test)
```

### Two Attack Vectors

#### Vector A: VMApple + TCG (Cleanest Path)

The VMApple device model (`hw/vmapple/vmapple.c`) was designed by Apple for running
macOS ARM in virtual machines. Amazon/QEMU upstream reimplemented it without Apple
proprietary code. It currently expects `ARM_CPU_TYPE_NAME("host")` which requires
HVF on Apple Silicon. The fix: change the default CPU to `"max"` (QEMU's fully-featured
TCG ARM CPU) when HVF is unavailable.

**Pros:** Simplest device model, designed for macOS, minimal hardware to emulate
**Cons:** Less control over Apple-specific hardware, may miss SoC-level checks

#### Vector B: T8030 Fork → T8103 (M1-like)

Fork the T8030 (iPhone 11 / A13) machine model into a new T8103 (M1-like) definition.
Scale the CPU to 8 cores (4P+4E), increase default RAM to 16GB, adjust the memory
map, add USB4/Thunderbolt stubs. Use macOS ARM kernelcache instead of iOS.

**Pros:** Full Apple SoC emulation, kernel patcher already works, total control
**Cons:** More work, must handle macOS-specific SoC differences from iOS

#### Vector C: HYBRID (Recommended)

Use VMApple's simpler device model as the machine platform, but inject ChefKiss's
kernel patcher and A13 CPU model. This gives us:
- VMApple's proven macOS boot path
- ChefKiss's battle-tested kernel patches
- A concrete Apple CPU model instead of generic "max"

### The Boot Sequence

```
1. QEMU starts on Intel x86 host with TCG (aarch64-softmmu)
2. VMApple machine model initializes:
   - Creates ARM CPU cores (A13 type via TCG)
   - Sets up GIC, PCIe, UART, AES, display
   - Loads macOS firmware (iBoot/AVPBooter)
3. Firmware loads kernelcache from disk image
4. ChefKiss kernel patcher intercepts kernelcache:
   - Patches APFS, AMFI, SEP, IMG4, code signing
   - NOPs hardware checks that would fail in emulation
5. XNU kernel boots with patched checks
6. launchd starts, userspace initializes
7. macOS desktop appears (software rendering, no Metal)
```

### What macOS Needs That iOS Doesn't

| Component | iOS (T8030) | macOS (M1/T8103) | Status |
|-----------|-------------|-------------------|--------|
| CPU cores | 6 (2P+4E) | 8 (4P+4E) | Config change |
| RAM | 4 GB | 8-16 GB | Config change |
| PCIe | Basic | Full (TB, NVMe, USB4) | Already in VMApple |
| Display | Mobile MIPI | Desktop DP/HDMI | VMApple has apple-gfx |
| Keyboard/Mouse | Touch | USB HID | VMApple has XHCI |
| Storage | eMMC/NVMe | NVMe (APFS) | Already in both |
| SEP | Required | Required | sep-sim.c exists |
| Rosetta 2 | N/A | x86 translation | Not needed |

### Performance Expectations

TCG emulation on a Xeon W-2140B (8C/16T @ 3.2 GHz):
- **Single-core:** ~200-500 MHz equivalent ARM performance
- **Multi-core:** Scales with host threads (up to 8 ARM cores on 16 threads)
- **Memory:** Direct mapping, no penalty beyond TLB emulation
- **Storage:** Near-native (virtio-blk passthrough)
- **Network:** Near-native (virtio-net)
- **Graphics:** Software rendering only (no Metal/GPU)

This is enough for: terminal work, compilation, Python/ML development, exo cluster
testing, ANE API development (CPU fallback), and headless server workloads.

## Implementation Plan

### Phase 1: Build ChefKiss QEMU on x86 (Week 1)

1. Build `qemu-system-aarch64` from ChefKissInc/QEMUAppleSilicon on the iMac Pro
   or Beast (both Intel x86)
2. Configure: `--target-list=aarch64-softmmu --enable-tcg`
3. Verify T8030 machine model compiles and initializes on x86

### Phase 2: VMApple TCG Boot Attempt (Week 1-2)

1. Patch VMApple to fall back from "host" CPU to "max" when HVF unavailable
2. Obtain macOS ARM restore image (publicly available from Apple)
3. Prepare disk images (IPSW → APFS volume)
4. Attempt boot: `qemu-system-aarch64 -M vmapple -cpu max -m 8G -accel tcg`
5. Debug boot failures via serial console output

### Phase 3: Kernel Patcher Integration (Week 2-3)

1. If VMApple alone fails, integrate ChefKiss kernel patcher into VMApple boot path
2. The patcher handles: APFS, AMFI, SEP, IMG4, code signing — all the checks
   that fail without real Apple hardware
3. This is the same approach OCLP uses at a different layer — OCLP patches kexts
   post-install, ChefKiss patches the kernel at load time

### Phase 4: macOS Desktop (Week 3-4)

1. Get to launchd → login window
2. Enable VNC/SSH for remote access (no Metal means no GPU UI acceleration)
3. Install development tools (Xcode CLI, Python, exo)
4. Validate ANE API surface (CoreML framework loads, dispatches to CPU fallback)

### Phase 5: Cluster Integration (Week 4+)

1. Run exo on the emulated macOS ARM environment
2. Join the cluster ring alongside native Apple Silicon nodes
3. Unified ARM macOS across all nodes

## Key Insight

The ChefKiss team has done 90% of the hardest work. They reverse-engineered Apple's
boot chain, SoC hardware, SEP protocol, kernel protection mechanisms, and built
working emulation of all of it. They just haven't pointed it at macOS yet because
their focus is iOS security research.

We're not building from scratch. We're combining:
- **ChefKiss QEMU** (Apple Silicon emulation + kernel patcher)
- **VMApple** (Apple's own macOS VM device model, reimplemented)
- **RavenX philosophy** (patch what blocks you, leave the rest alone)
- **Apple's public restore images** (legal source of macOS ARM binaries)

This is not theory. Every individual component exists and works. The integration
is the challenge.

## Files

- `QEMUAppleSilicon/` — ChefKiss fork (cloned)
- `RavenX Tahoe Patcher` — OCLP Tahoe patches (our fork, iMac Pro enabled)
- This document — architecture plan

## References

- https://github.com/ChefKissInc/QEMUAppleSilicon
- https://github.com/ChefKissInc/QEMUAppleSilicon/wiki
- https://developer.apple.com/documentation/virtualization/installing-macos-on-a-virtual-machine
- https://www.qemu.org/docs/master/system/arm/vmapple.html
- https://github.com/Coopydood/ultimate-macOS-KVM
