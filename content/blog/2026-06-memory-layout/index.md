---
title: "Extended Memory Layout"
description: ""
date: 2026-08-20T12:55:08+02:00
date: 2026-08-20T12:55:08+02:00
draft: false
weight: 49
categories: []
tags: []
contributors: []
pinned: false
homepage: false
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

The initial SysTeX release of OpenCCA limited usable memory on the platform to 4GB, and 1 GB to RMM-usable memory.
This way, OpenCCA worked on all configurations of the RK3588, in particular the 4GB model.


However, this is a limitation as some workloads/ case-studies like AI-models require much more RAM than 1 GB.

With selected changes in TF-A, RMM and U-Boot, this restriction can be lifted. With these patches, CVMs with several GB in size can be run.

- [TLDR: Pull request to enable more RAM is here](https://github.com/opencca/arm-trusted-firmware/issues/1).

In this blog post we further look into the changes involved.

## RMM's Shadow struct for Granules

The RMM keeps metadata of all tracked granules in a [shadow struct](https://github.com/opencca/tf-rmm/blob/c362b43e2652dfeb885dd00a00f6c4face6d4da3/lib/granule/src/granule.c#L18): `granules[]`.

```c
struct granule {
	uint16_t	descriptor;
};
static struct granule granules[RMM_MAX_GRANULES];
```

It stores a 16 byte descriptor for every RMM-addressable memory granule on the platform.

If the system contains more RAM, this struct also needs to grow.
As it currently is a linear array, a platform with much DRAM requires a substantial larger memory footprint for the RMM.

```
 0x040000 granules for  1 GB RMM-addressable memory: sizeof(granules) ==   4 MB
 0x800000 granules for 32 GB RMM-addressable memory: sizeof(granules) == 128 MB
```


##### What does the RMM track in `granules[]`?

##### What other changes are required?

### The new Memory Carveout
```
/*
 * New RK3588 memory layout in TF-A:
 *
 *              RK3588 DRAM Bank 0 layout:
 *  0x00000000  +----------------------------+ ARM_DRAM_RME_RESERVE_BASE
 *              | BL31 / TF-A                | ARM_DRAM_BL31_RESERVE_BASE
 *              | 128 MB                     |
 *  0x08000000  +----------------------------+ ARM_EL3_RMM_SHARED_BASE
 *              | TF-A <-> RMM shared        |
 *              | 4 KB                       |
 *  0x08001000  +----------------------------+ ARM_REALM_BASE
 *              | RMM / Realm DRAM           |
 *              | 256 MB - 4 KiB             |
 *              +----------------------------+ ARM_L0_GPT_BASE
 *              | L0 GPT                     |
 *              +----------------------------+ ARM_L1_GPT_BASE
 *              | L1 GPT                     |
 *              +----------------------------+
 *              | reserve until 512 MB       |
 *  0x20000000  +----------------------------+  RMM_NS_RAM1_BASE
 *  (at 512 MB) | NS DRAM start              |
 *              | BL33 / U-Boot/ Linux       |
 *  0xf0000000  +----------------------------+  ARM_DEVICES0_BASE
 *              | MMIO / devices             |
 */
```

## How do I use it?


#### Example: Debian CVM with 12 GB RAM

<br />
<br />
<br />


