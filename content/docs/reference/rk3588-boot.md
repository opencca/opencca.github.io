---
title: "RK3588 Boot"
description: ""
summary: ""
date: 2025-08-01T16:04:48+02:00
lastmod: 2025-01-07T16:04:48+02:00
draft: false
weight: 1000
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

<style>


.box-thumb img,
img.box-thumb {
  max-width: 500px;
  height: auto;
  display: block;
  margin-left: auto;
  margin-right: auto;
}
</style>


## Bootflow

The firmware boot process begins when the SoC is powered on and continues until control is handed over to the untrusted hypervisor.

The boot flow is divided into multiple stages, all executed by the primary CPU.
The SoC includes 7 additional secondary cores that are later enabled during the normal world hypervisor boot.

{{< img class="box-thumb" src="images/bootflow_cca.png" width="300" alt="Bootflow OpenCCA" >}}
> Figure: Bootflow RK3588 with OpenCCA. Gray: propritary code, Orange: OpenCCA changes.
<br />

The **Stage 1** bootloader (**BL1**) is proprietary and embedded in the SoC's Boot ROM.
Since the SoC hardware does not have a root world, the bootloader code runs in the secure world in EL3.
**BL1** initializes the internal SRAM and searches for a **Stage 2** bootloader, which is implemented by U-Boot SPL (Secondary Program Loader).
Since DRAM is not yet available, U-Boot loads proprietary DRAM initialization code and configures the memory controller before transitioning to the next stage.
U-Boot then hands control over to **BL31**, implemented by Arm Trusted Firmware-A (TFA).

At this stage, the system is initialized.
TFA installs runtime services that are accessible via SMCs and loads the Realm Management Monitor (RMM).
The RMM initializes itself in the normal world EL2 and returns to TFA in EL3.

Additionally, TFA can initialize OP-TEE (**BL32**) that is provided by Rockchip.
OP-TEE operates in the secure world in EL1 (currently not part of our build).
Before the normal world hypervisor boots, TFA also initializes **BL33**, which serves as the normal world bootloader.
**BL33** runs in EL2 and is implemented by U-Boot.

Once **BL33** has loaded, it searches for the hypervisor in eMMC, SD card, or NVMe storage and executes it, thereby completing the boot process.

#### BL2
- [U-Boot SPL](https://github.com/opencca/u-boot)

#### BL31
- [Arm Trusted Firmware A](https://github.com/opencca/arm-trusted-firmware)

#### BL32
Although Radxa ships a binary blob of OP-TEE, there is upstream support for the RK3588
[https://optee.readthedocs.io/en/latest/general/platforms.html](https://optee.readthedocs.io/en/latest/general/platforms.html)

We have currently not looked into OP-TEE. Interested in trusted Apps and the secure world? Reach out and bootstrap OP-TEE for OpenCCA.

#### BL33
- [U-Boot Proper](https://github.com/opencca/u-boot)
