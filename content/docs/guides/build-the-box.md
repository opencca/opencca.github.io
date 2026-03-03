---
title: "Build the Box"
description: ""
summary: ""
date: 2023-09-07T16:04:48+02:00
lastmod: 2023-09-07T16:04:48+02:00
draft: false
weight: 250
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---


This page provides assembly instructions for the OpenCCA automation box. Before starting, make sure you have all the parts listed in [Hardware](/docs/guides/hardware#automation-box).


## Physical Layout

The box is organized in three layers:

- **Top**: ROCK 5B (RK3588) board, along with MOSFET circuit
- **Middle**: Raspberry Pi 5 (management node)
- **Bottom**: Ethernet switch

{{< img src="images/box-description.png" class="" width="100" alt="Automation box overview" >}}

<br />

More assembly pictures can be found in the [opencca-box repository](https://github.com/opencca/opencca-box/tree/main).

## Connecting the Parts
**Dock (Anker PowerExpand)** connects to:
- Pi (main USB-C host port)
- Power supply (USB-C PD input) and smart plug
- RK3588 (USB-C data port)

**Raspberry Pi (Flash Server)** connects to:
- Switch (Ethernet)
- Dock
- USB-TTL adapter
- Breadboard/MOSET via GPIO header

**RK3588** connects to:
- Switch
- Dock
- USB-TTL via GPIO header
- Breadboard/MOSFET wiring via GPIO header and soldering

## Raspberry Pi

Install [Raspberry Pi OS](https://www.raspberrypi.com/software/) onto the SD card of the Pi.

The Pi serves as the flashing and power management node. For firmware compilation, use a dedicated
[x86 machine](https://github.com/opencca/opencca-build) and mount the build directories into the Pi via `sshfs`. This setup allows you to compile
on a faster x86 machine while the Pi handles flashing operations.

The docker container in [opencca-flash](https://github.com/opencca/opencca-flash) provides the required environment for the Pi.

#### Network Setup
Connect the Raspberry Pi to the Ethernet switch using a short patch cable. Connect the switch to your network using a longer uplink cable. The RK3588 also connects to the same switch for network access.

#### UART Console
Connect the USB-TTL adapter to a USB port on the Raspberry Pi. See [Connect to UART](/docs/reference/rk3588/connect-to-uart) for detailed pinout.

#### Power Control

The Raspberry Pi can back-power the RK3588 over USB even when the smart plug is off. To achieve a true hard reset, both power sources must be removed:

1. Turn off the smart plug (cuts main power)
2. Disable USB power from Raspberry Pi using `uhubctl`

See scripts in [opencca-flash/board/power](https://github.com/opencca/opencca-flash/tree/opencca/main/board/power).
