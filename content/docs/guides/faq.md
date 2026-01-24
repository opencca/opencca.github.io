---
title: "FAQ"
description: "Frequently Asked Questions"
summary: ""
date: 2025-09-07T16:04:48+02:00
lastmod: 2025-09-07T16:04:48+02:00
draft: false
weight: 300
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

{{< details "Q: What is the MOSFET circuit used for?" >}}
_November 2025_

I read there is a MOSFET circuit for flashing, do I need this?

>
> The RK3588 connects over ethernet to a
> flash server (Raspberry Pi). It controls a MOSFET and power circuit to
> flash new firmware and exposes UART access.
>

The MOSFET circuit is not strictly necessary. You can flash the firmware
manually by pressing the physical button on the SoC. However, if you plan to do
this thousands of times (like we did during the initial bring up), it may be
worth automating this. We soldered a simple circuit to the board to bypass the
physical button, using a MOSFET as a programmable switch controlled via a
Raspberry Pi GPIO pin.

You can find plenty of guides online. It is a quick job once you have the parts
(MOSFET, 10kΩ, 220Ω resistors) and should be doable in a few minutes of
soldering. A google search for "MOSFET as a switch" should give you the gist
what to do.

{{< /details >}}


{{< details "Q: What about Support for Orange Pi 5 Plus or other RK3588 variants?" >}}

_December 2025_

We chose the Rock 5B as the reference platform because its Linux kernel support
was more up to date at the time of kickoff. Although the Orange Pi 5 Plus uses
the same SoC, you will likely need to adjust MMIO offsets (either in code or the
device tree) in TFA and U-Boot, and possibly find or adapt a suitable Linux
kernel for better peripheral support. [Collabora](https://www.collabora.com/) does upstream work for RK3588 in
Linux, so they may have merged better support for other variants of the RK3588
by now.

Feel invited to send patches to OpenCCA.

{{< /details >}}


{{< details "Q: I bought the RK3588 Rock 5B with 32 GB instead of 16 GB. It does not Boot." >}}

_January 2026_

The [SysTeX release](https://github.com/opencca/opencca-releases/releases/tag/opencca/systex25) works for a Rock 5B Model with 16 GB. See [these changes](https://github.com/opencca/opencca-flash/issues/2) to the Firmware to run opencca on the 32 GB Model.

{{< /details >}}

{{< details "Q: How do I run a realm VM on several cores?" >}}

_January 2026_

The [SysTeX release]() root filesystem for the RK3588 includes a convenience script to launch realm VMs:

```sh
sudo lkvm run  \
  --realm --restricted_mem \ 
  --disable-sve -c 1 -m 100m -p "debug loglevel=8"
```

For benchmarking, we preconfigured the host kernel to isolate the cores with `isolcpus=`.


`Isolcpus` disables normal scheduler load balancing on the isolated CPUs. As a result, all `kvm-vcpu-*` threads can end up on the same physical core, degrading performance (and sometimes triggering timer/RCU warnings under load).

**Solution**: keep `isolcpus`, but explicitly pin each kvm-vcpu-* thread to a dedicated core after the CVM starts.


```sh
# Example host kernel cmdline (hardware-debugging friendly):
rootwait maxcpus=4 isolcpus=1,2,3 nohlt cpuidle.off=1 \
rcupdate.rcu_cpu_stall_suppress=1 nmi_watchdog=0 \
rcutree.rcu_cpu_stall_timeout=600 rcu_nocb_poll rcu_nocbs=1-3
```

```sh
# Run CVM on 2 cores
function pin {
  sleep 4
  local pid=$(pgrep -n lkvm)

  # ps -T -p "$pid" -o tid,psr,comm
  sudo taskset -pc 1 $(ps -T -p "$pid" -o tid=,comm= | awk '$2=="kvm-vcpu-0"{print $1}')
  sudo taskset -pc 2 $(ps -T -p "$pid" -o tid=,comm= | awk '$2=="kvm-vcpu-1"{print $1}')
}

pin &

sudo lkvm run  --vcpu-affinity 1,2 \
  --realm --restricted_mem --disable-sve \
  -c 2 -m 512m -p "debug loglevel=8 ip=off"
```

This explicitly pins each vCPU thread to a dedicated physical core after the VM starts, ensuring the realm VM actually runs on multiple cores even with `isolcpus` enabled.


Related:
- [`CONFIG_BOOTARGS_OVERWRITE` in U-Boot](https://github.com/opencca/u-boot/blob/a515a10c2a36772161b5653961bc25247a9b6c32/rk3588_fragment.config#L7)

{{< /details >}}