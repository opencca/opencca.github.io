---
title: "FAQ"
description: "Frequently Asked Questions"
summary: ""
date: 2025-09-07T16:04:48+02:00
lastmod: 2025-09-07T16:04:48+02:00
draft: false
weight: 20
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

This FAQ collects frequently asked questions about using OpenCCA on different hardware and configurations.


{{< details "Q: I want to run OpenCCA on Rock 5B+. What do I have to change?" >}}

_September 2025_

We have not had the chance to test the [Rock 5B+](https://radxa.com/products/rock5/5bp/) yet, but it seems that it directly addresses one of the biggest shortcomings of the Rock 5B that we have encountered:

On the 5B, power and firmware flashing both go through the same USB-C port.
When connecting the board to a host computer for firmware flashing, this often does not provide enough current for normal system operations.

One workaround was to use a USB-C dock with PD from a power brick while still exposing the data lines for flashing. However, many USB-C docks do not implement USB-C PD correctly. This causes [power resets and reboot loops](https://gitlab.collabora.com/hardware-enablement/rockchip-3588/linux/-/issues/8). Radxa hosts a community list of compatible power supplies [here](https://wiki.radxa.com/Rock5/5b/power_supply).

While the 5B+ uses the same SoC, there are still some changes required to make it work:

+ The 5B+ integrates LPDDR5 instead of LPDDR4 RAM, so the 5B+ requires new BL1 firmware blobs that bring up the DRAM before U-Boot SPL (BL2). Radxa probably provides these blobs somewhere.

+ There are device tree changes required for U-Boot proper and Linux to make use of the peripherals. A quick search shows a [device tree file](https://gitlab.collabora.com/hardware-enablement/rockchip-3588/linux/-/blob/rockchip-devel/arch/arm64/boot/dts/rockchip/rk3588-rock-5b-plus.dts) for the 5B+ already.

+ TF-A and RMM are board-agnostic and have a single configuration for the SoC, so this should work right away. To be compatible with as many configurations as possible, we currently limit the addressable RAM to 4GB as we have not implemented dynamic RAM discovery: [RMM](https://github.com/opencca/tf-rmm/blob/opencca/main/configs/rk3588_defcfg.cmake#L13), [TF-A](https://github.com/opencca/arm-trusted-firmware/blob/opencca/main/plat/rockchip/rk3588/opencca/rk3588_opencca.h#L71), [U-Boot](https://github.com/opencca/u-boot/commit/219910188adc59a6f17cc192044880ce76e8dc2a).

A ballpark estimate is that OpenCCA bring-up on the Rock 5B+ will be less work than on other RK3588 derivatives (e.g., Orange5 Plus), but it will still require some tinkering.

We typically order Rock 5B boards from Aliexpress and it takes around 3 weeks until they arrive in Switzerland:

- [Board](https://de.aliexpress.com/item/1005007507141308.html?spm=a2g0o.order_detail.order_detail_item.3.4e1d6368VO4dVf&gatewayAdapt=glo2deu)
- [Dock](https://www.amazon.de/dp/B08CKXNJZS)
- [Power Brick](https://www.amazon.de/dp/B094QKV6S8)
- [eMMC](https://de.aliexpress.com/item/1005007003959424.html?spm=a2g0o.order_list.order_list_main.35.4f2418023Ja2xZ&gatewayAdapt=glo2deu)
- [Flashing Getting Started](https://github.com/opencca/opencca-flash?tab=readme-ov-file#manual-flashing)


{{< /details >}}


{{< details "Q: How can I use more than 4GB of RAM on the Rock 5B?" >}}
_August 2025_

Our current implementation of the RK3588 platform limits the memory size exposed to Linux to 4 GB. This way OpenCCA works on all configurations of the RK3588, in particular the 4GB model.

The firmware currently does not support dynamic RAM discovery and assumes 4GB in TF-A, RMM, and Linux, but this is mostly for compatibility and can be changed in the firmware.

Some pointers to change this:
[RMM](https://github.com/opencca/tf-rmm/blob/opencca/main/configs/rk3588_defcfg.cmake#L13), [TF-A](https://github.com/opencca/arm-trusted-firmware/blob/opencca/main/plat/rockchip/rk3588/opencca/rk3588_opencca.h#L71), [U-Boot](https://github.com/opencca/u-boot/commit/219910188adc59a6f17cc192044880ce76e8dc2a).
{{< /details >}}


{{< details "Q: I want to boot from SDMMC instead of eMMC" >}}  
_October 2025_

We recommend booting from eMMC. Compatible eMMC chips cost around 10 USD:
- [Ali Express](https://de.aliexpress.com/item/1005007003959424.html?spm=a2g0o.order_list.order_list_main.35.4f2418023Ja2xZ&gatewayAdapt=glo2deu)

The prebuilt image used for the SysTEX evaluation boots from eMMC. In this build, the kernel option `OPENCCA_HW_DEBUG=y` is enabled, which disables SDMMC and enables the SWD interface. Since both SD and hardware debugging share the same pins you can either do hardware debugging or use SD card at the same time.

You can see the relevant changes here:
- [Diff](https://github.com/opencca/linux/compare/d8e18330ec8e59bc5262368961cd16aa044e0195...6d37f0d15c317804ceeb2d50354695d35783f0f6#diff-00edfaa8eb3606d42da7fb68c09687cd611602038ff3aa55436b2742d2d69bd2R3)

To fix this, you either:
- boot from eMMC
- or rebuild the kernel with `OPENCCA_HW_DEBUG=n`, and if needed, adjust the kernel cmd line arguments so the rootfs is loaded from SDMMC instead.
  
{{< /details >}}

