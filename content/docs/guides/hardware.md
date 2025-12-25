---
title: "Hardware"
description: ""
summary: ""
date: 2023-09-07T16:04:48+02:00
lastmod: 2023-09-07T16:04:48+02:00
draft: false
weight: 15
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

<style>
  .table-compact-col2 table td:nth-child(2),
.table-compact-col2 table th:nth-child(2) {
  /* font-size: 0.82rem;   /* smaller text in column 2 */
  /* line-height: 1.2; */ */
}

.table-compact-col2 table td:nth-child(2) {
  /* /* max-width: 28rem;  */
  /* white-space: normal;  allow wrapping */
}

.table-parts  {
  margin-top: -30px;
  font-size: 1rem;
}
</style>

>
> This page is still work in progress. Found a mistake or a better explaination? [File a pull request on GitHub.](https://github.com/opencca/opencca.github.io/blob/opencca/main/content/docs/guides/hardware.md)
>

This page lists hardware for two common setups:
1. [Minimal setup (required)](#minimal-setup):
Enough to run OpenCCA on an RK3588 ROCK 5B

2. [Box with Flashserver (optional)](#automation-box):
A small lab setup that supports remote UART access, automated flashing, and power cycling.

## Minimal setup
To get started with OpenCCA, you need the parts below.
<div class="table-compact-col2 table-parts">

| Product | Link | Comment |
| --- | --- | --- |
| Radxa ROCK 5B (RK3588) | [AliExpress](https://de.aliexpress.com/item/1005007507141308.html) | Recommended: 16 GB RAM |
| eMMC (16 GB+) <br /> Radxa eMMC | [AliExpress](https://de.aliexpress.com/item/1005007003959424.html) | The microSD slot is multiplexed with SWD, so eMMC is recommended. See: [Info on SD card](https://github.com/opencca/opencca-flash/issues/1) |
| Power supply <br /> Anker Nano II 65W | [Amazon (DE)](https://www.amazon.de/dp/B094QKV6S8) | Not every USB-C power supply works reliably. See: [Radxa power supply discussion](https://wiki2.radxa.com/Rock5/5b/power_supply) |
| USB to TTL adapter (3.3 V) | [AliExpress](https://de.aliexpress.com/item/32668866076.html?spm=a2g0o.order_list.order_list_main.203.60565c5fXlMcqC&gatewayAdapt=glo2deu) | A CH340G (3.3 V) (Baudrate 1.5 Mbps) See: [Connect to UART](/docs/reference/connect-to-uart)|
| USB-C cable| generic | Cable for power to RK3588 |

</div>

Once you purchased the parts, [build and flash the firmware](https://github.com/opencca/opencca-build)


## Automation Box

For automated power cycling and flashing, we built a small box setup.

- A Raspberry Pi acts as a management node that you can SSH into
- The Pi provides a UART console connection to the ROCK 5B.
- Power can be toggled remotely via a smart plug
- A USB-C dock/hub connects the ROCK 5b to power and data because the 5B multiplexes power and data on the same USB-C port.
- A MOSFET circuit bypasses the Maskrom switch to enable automated firmware flashing



{{< img src="images/opencca5.png" width="100" alt="Automation box overview" >}}

<br />

You find a docker container with all scripts for the management node in [opencca-flash](https://github.com/opencca/opencca-flash).

### Management Node (Flash Server)

<div class="table-compact-col2 table-parts">

| Product | Link | Comment |
| --- | --- | --- |
| Raspberry Pi 5 | [Digitec (CH)](https://www.digitec.ch/en/s1/product/raspberry-pi-new-5-8gb-development-boards-kits-38955607) | We recommend model 5. Install Raspberry Pi OS. |
| Raspberry Pi Power Supply <br /> (27 W) | [Digitec (CH)](https://www.digitec.ch/en/s1/product/raspberry-pi-official-5-power-supply-27w-usb-c-development-board-accessories-39631602) |  |
| MicroSD card (for Raspberry Pi) | [Digitec (CH)](https://www.digitec.ch/en/s1/product/sandisk-ultra-a1-32-gb-microsdhc-u1-uhs-i-memory-card-14102757) | Storage for the Raspberry Pi. |
| Ethernet switch | [Digitec (CH)](https://www.digitec.ch/en/s1/product/cudy-gs105d-network-switch-gigabit-ethernet-101001000-black-5-ports-network-switches-23907099) | Optional |
| 2 short patch cables | [Digitec (CH)](https://www.digitec.ch/en/s1/product/value-utp-patch-cable-conf-cat-6-gray-05-m-uutp-cat6-050-m-network-cables-14200133) | Connect Pi + ROCK 5B to the switch. |
| 1 longer patch cable | [Digitec (CH)](https://www.digitec.ch/en/s1/product/digitus-network-cable-uutp-cat6-2-m-network-cables-10255016) | Uplink to your network. |
| USB-C -> USB-A adapter | [AliExpress](https://de.aliexpress.com/item/1005006596688387.html) | Connect USB-C dock to Pi USB-A port |
</div>

### USB-C Dock

Connect the USB-C dock to the Raspberry Pi. Connect the RK3588 to the dock as a peripheral. Finally, power the dock through its USB-C PD port with an external power supply.

<div class="table-compact-col2 table-parts">

| Product | Link | Comment |
| --- | --- | --- |
| Anker PowerExpand 6-in-1 USB-C | [Amazon (DE)](https://www.amazon.de/dp/B08CKXNJZS) | The ROCK 5B multiplexes power + data on one USB-C port. A dock helps you power the board and flash firmware without cable juggling. See: [Radxa power supply discussion](https://wiki2.radxa.com/Rock5/5b/power_supply) |
| USB-C cable | generic | Cable for power to RK3588 |
</div>


### Smart Plug

In our setup, the Raspberry Pi can still back-power the RK3588 over USB. That means toggling the smart plug alone may not fully reset the board as the the RK3588 can stay partially powered via the USB hub.

To get a true hard reset, we do
1. turns off the smart plug (cuts main power), and
2. disables USB power from the Raspberry Pi hub.

With both power sources removed, the RK3588 performs a reliable hard reset.

- See scripts in [opencca-flash/board/power](https://github.com/opencca/opencca-flash/tree/opencca/main/board/power)

<div class="table-compact-col2 table-parts">

| Product | Link | Comment |
| --- | --- | --- |
| Smart plug | [Athom (EU)](https://www.athom.tech/blank-1/EU-plug) | Remote power cycling for reflashing. Any smartplug will work that exposes HTTP API. We used Tasmota Firmware.|

</dvid>



### Box

Optional enclosure parts to house the setup, including a power strip and fans.

<br />

{{< img src="images/opencca1.png" width="100" alt="Optional Box Enclosure" >}}


| Product | Link | Comment |
| --- | --- | --- |
| Power strip | [Digitec (CH)](https://www.digitec.ch/en/s1/product/max-hauri-basic-line-5-x-type-13-5-m-socket-strips-14100119) |  |
| Plastic box | [Digitec (CH)](https://www.digitec.ch/en/s1/product/kis-w-375-x-25-x-23-cm-15-l-storage-boxes-13405854) | Optional enclosure. 37.5 x 25 x 23 cm, 15 l or larger. |
| Step-up converter (optional) | [AliExpress](https://de.aliexpress.com/item/1005008374772473.html) | Optional, e.g. for quieter fan control. |
| 12 V or 5 V fan (optional) | generic | Optional cooling. |
| Glue, tape, wood or cardboard and rubber bands | generic | For assembly, [see pictures](https://github.com/opencca/opencca-box) |

</div>

- [See 3D models](#3d-print-models)

### Maskrom MOSFET

The MOSFET circuit is not strictly necessary. You can flash the firmware manually by pressing the physical button on the SoC. However, if you plan to do this thousands of times (like we did during the initial bring up), it may be worth automating this. We soldered a simple circuit to the board to bypass the physical button, using a MOSFET as a programmable switch controlled via a Raspberry Pi GPIO pin.

**Wiring (example GPIO17):**
- GPIO17 → **220Ω** → MOSFET **Gate (G)**
- **10kΩ** from Gate → **GND** (pull-down)
- MOSFET **Source (S)** → **GND** (Pi and ROCK5 share ground)
- MOSFET **Drain (D)** → **BOOT_SARADC_IN0** on ROCK5

<div class="table-compact-col2 table-parts">

| Product | Link | Comment |
| --- | --- | --- |
| Circuit board | [AliExpress](https://de.aliexpress.com/item/1005007204340724.html?spm=a2g0o.order_list.order_list_main.58.3e151802BGaqce&gatewayAdapt=glo2deu) | For a Maskrom automation circuit. |
| MOSFET IRLZ44N | [AliExpress](https://www.aliexpress.com/store/1102711404) |  |
| 10kΩ resistor + 220Ω resistor |  |  |
| Cables | [AliExpress](https://de.aliexpress.com/item/1005003252824475.html?spm=a2g0o.order_list.order_list_main.113.3e151802BGaqce&gatewayAdapt=glo2deu) |

- See scripts in [opencca-flash/board/maskrom](https://github.com/opencca/opencca-flash/tree/opencca/main/board/maskrom)
- [Entering Maskrom Mode (Radxa)](https://docs.radxa.com/en/rock5/rock5b/low-level-dev/install-os/rkdevtool_maskrom)

</div>

## 3D Print Models

You find instructions on how to obtain and print the 3D models in the
[opencca-box](https://github.com/opencca/opencca-box) repository.


