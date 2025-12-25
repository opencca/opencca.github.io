---
title: "Hardware Debugging"
description: ""
summary: ""
date: 2025-08-01T16:04:48+02:00
lastmod: 2025-01-07T16:04:48+02:00
draft: false
weight: 190
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

The RK3588 SoC shares the GPIO pins of the SD card reader with the Serial Wire Debug Port (SW-DP), multiplexing the SDMMC pins `DATA2` and `DATA3` with `TCK` and `TMS`.

We use a Micro SD breakout board that exposes the SD card pins, allowing us to connect a hardware debugger to the board.

A successful connection requires four signals: `TCK`, `TMS`, `VTref`, and `GND`.

We used DSTREAM-ST v0197A and Arm Development Studio and had limited success with ST-LINK v2 and openocd.

The table below lists the IO memory to enable hardware debugging on the SoC. We write to these locations in U-Boot and in Linux. To debug Linux in normal world EL2, we further disable all SDMMC references in the kernel's device tree.


| **Bus** | **Address** | **Value** |
|---|---|---|
| SYS_GRF_SOC_CON6 | 0xFD58C318 | 0x40004000 |
| BUS_IOC_GPIO4D_IOMUX_SEL_L | 0xFD5F8098 | 0xFF005500 |

```sh
# Run on RK3588 hypervisor after boot
sudo busybox devmem 0xfd58c318 w
sudo busybox devmem 0xfd58c318 w 0x40004000
sudo busybox devmem 0xfd58c318 w
sudo busybox devmem 0xFD5F8098 w
sudo busybox devmem 0xFD5F8098 w 0xFF005500
sudo busybox devmem 0xFD5F8098 w
```

You find more information on [wiring in our forum discussion](https://forum.radxa.com/t/debug-rock5b-rk3588-with-swd-jtag/25115).

- [Datasheets](docs/reference/datasheets/)
- [SD Card breakout](https://de.aliexpress.com/item/1005006267829221.html?spm=a2g0o.order_list.order_list_main.340.4ed918025epvAS&gatewayAdapt=glo2deu)
- `CONFIG_OPENCCA_HW_DEBUG` in [opencca-linux](https://github.com/opencca/linux)
