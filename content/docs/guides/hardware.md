---
title: "Hardware"
description: ""
summary: ""
date: 2023-09-07T16:04:48+02:00
lastmod: 2023-09-07T16:04:48+02:00
draft: false
weight: 200
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
  /* font-size: 0.82rem;    /* smaller text in column 2 */
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

.img-row {
  display: flex;
  gap: 16px;
  align-items: flex-start;
  flex-wrap: wrap; /* optional, helps on mobile */
}

.img-col {
  flex: 1 1 45%;
}

.img-col img {
  width: 100%;
  height: auto;
  display: block;
}
</style>


>
> _This page is still work in progress. Improve the site by [filing a pull request on GitHub.](https://github.com/opencca/opencca.github.io/blob/opencca/main/content/docs/guides/hardware.md)_
> _Switzerland and US purchase links are listed below; please add other international links via a PR._


This page lists hardware for two common setups:
1. [Minimal setup (required)](#minimal-setup):
Enough to run OpenCCA on an RK3588 ROCK 5B

2. [Box with Flashserver (optional)](#automation-box):
A small lab setup that supports remote UART access, automated flashing, and power cycling.

## Minimal setup
To get started with OpenCCA, you need the parts below.
<div class="table-compact-col2 table-parts">

| Product | Link | US Link | Comment |
| --- | --- | --- | --- |
| Radxa ROCK 5B (RK3588) | [AliExpress](https://de.aliexpress.com/item/1005007507141308.html) | [Amazon](https://a.co/d/71oIe5l) | Recommended: 16 GB RAM |
| eMMC (16 GB+) <br /> Radxa eMMC | [AliExpress](https://de.aliexpress.com/item/1005007003959424.html) | [Amazon](https://a.co/d/c1uCrou) | The microSD slot is multiplexed with SWD, so eMMC is recommended. See: [Info on SD card](https://github.com/opencca/opencca-flash/issues/1) |
| Power supply <br /> Anker Nano II 65W | [Amazon (DE)](https://www.amazon.de/dp/B094QKV6S8) | [Amazon](https://a.co/d/dtg3po5) | Not every USB-C power supply works reliably. See: [Radxa power supply discussion](https://wiki2.radxa.com/Rock5/5b/power_supply) |
| USB to TTL adapter (3.3 V) | [AliExpress](https://de.aliexpress.com/item/32668866076.html?spm=a2g0o.order_list.order_list_main.203.60565c5fXlMcqC&gatewayAdapt=glo2deu) | [Amazon](https://a.co/d/bzAH2Bm) | A CH340G (3.3 V) (Baudrate 1.5 Mbps) See: [Connect to UART](/docs/reference/rk3588/connect-to-uart)|
| USB-C cable| generic | [Amazon](https://a.co/d/9qni6GJ) | Cable for power to RK3588 |

</div>

Once you purchased the parts, [build and flash the firmware](https://github.com/opencca/opencca-build)


## Automation Box

For automated power cycling and flashing, we built a small box setup.

- A Raspberry Pi acts as a management node that you can SSH into
- The Pi provides a UART console connection to the ROCK 5B.
- Power can be toggled remotely via a smart plug
- A USB-C dock/hub connects the ROCK 5b to power and data because the 5B multiplexes power and data on the same USB-C port.
- A MOSFET circuit bypasses the Maskrom switch to enable automated firmware flashing



{{< img src="images/opencca5.png" class="" width="100" alt="Automation box overview" >}}

<br />

You find a docker container with all scripts for the management node in [opencca-flash](https://github.com/opencca/opencca-flash).

### Management Node (Flash Server)

<div class="table-compact-col2 table-parts">

| Product | Link | US Link | Comment |
| --- | --- | --- | --- |
| Raspberry Pi 5 | [Digitec (CH)](https://www.digitec.ch/en/s1/product/raspberry-pi-new-5-8gb-development-boards-kits-38955607) | [Amazon](https://a.co/d/hrj4x2w) | We recommend model 5. Install Raspberry Pi OS. |
| Raspberry Pi Power Supply <br /> (27 W) | [Digitec (CH)](https://www.digitec.ch/en/s1/product/raspberry-pi-official-5-power-supply-27w-usb-c-development-board-accessories-39631602) | [Amazon](https://a.co/d/a7tRyPy) |  |
| MicroSD card (for Raspberry Pi) | [Digitec (CH)](https://www.digitec.ch/en/s1/product/sandisk-ultra-a1-32-gb-microsdhc-u1-uhs-i-memory-card-14102757) | [Amazon](https://a.co/d/7p2nYBE) | Storage for the Raspberry Pi. |
| Ethernet switch | [Digitec (CH)](https://www.digitec.ch/en/s1/product/cudy-gs105d-network-switch-gigabit-ethernet-101001000-black-5-ports-network-switches-23907099) | [Amazon](https://a.co/d/jaDPUaA) | Optional |
| 2 short patch cables | [Digitec (CH)](https://www.digitec.ch/en/s1/product/value-utp-patch-cable-conf-cat-6-gray-05-m-uutp-cat6-050-m-network-cables-14200133) | [Amazon](https://a.co/d/eHbjbSP) | Connect Pi + ROCK 5B to the switch. |
| 1 longer patch cable | [Digitec (CH)](https://www.digitec.ch/en/s1/product/digitus-network-cable-uutp-cat6-2-m-network-cables-10255016) | [Amazon](https://a.co/d/alIhtaI) | Uplink to your network. |
| USB-C -> USB-A adapter | [AliExpress](https://de.aliexpress.com/item/1005006596688387.html) | [Amazon](https://a.co/d/1cLrjoC) | Connect USB-C dock to Pi USB-A port |
</div>

### USB-C Dock

Connect the USB-C dock to the Raspberry Pi. Connect the RK3588 to the dock as a peripheral. Finally, power the dock through its USB-C PD port with an external power supply.

<div class="table-compact-col2 table-parts">

| Product | Link | US Link | Comment |
| --- | --- | --- | --- |
| Anker PowerExpand 6-in-1 USB-C | [Amazon (DE)](https://www.amazon.de/dp/B08CKXNJZS) | [Amazon](https://a.co/d/7Bthnd5) | The ROCK 5B multiplexes power + data on one USB-C port. A dock helps you power the board and flash firmware without cable juggling. See: [Radxa power supply discussion](https://wiki2.radxa.com/Rock5/5b/power_supply) and [split Power and Data](/docs/reference/rk3588/split-data--power). |
| USB-C cable | generic | [Amazon](https://a.co/d/9qni6GJ) | Cable for power to RK3588 |
</div>


### Smart Plug

In our setup, the Raspberry Pi can still back-power the RK3588 over USB. That means toggling the smart plug alone may not fully reset the board as the the RK3588 can stay partially powered via the USB hub.

To get a true hard reset, we do
1. turns off the smart plug (cuts main power), and
2. disables USB power from the Raspberry Pi hub.

With both power sources removed, the RK3588 performs a reliable hard reset.

- See scripts in [opencca-flash/board/power](https://github.com/opencca/opencca-flash/tree/opencca/main/board/power)

<div class="table-compact-col2 table-parts">

| Product | Link | US Link | Comment |
| --- | --- | --- | --- |
| Smart plug | [Athom (EU)](https://www.athom.tech/blank-1/EU-plug) | [Amazon](https://a.co/d/f09thut) | Remote power cycling for reflashing. Any smartplug will work that exposes HTTP API. We used Tasmota Firmware.|

</div>



### Box

Optional enclosure parts to house the setup, including a power strip and fans.

<br />

{{< img src="images/opencca1.png" class="hugo-image-500" width="100" alt="Optional Box Enclosure" >}}

<div class="table-compact-col2 table-parts">

| Product | Link | US Link | Comment |
| --- | --- | --- | --- |
| Power strip | [Digitec (CH)](https://www.digitec.ch/en/s1/product/max-hauri-basic-line-5-x-type-13-5-m-socket-strips-14100119) | [Amazon](https://a.co/d/3ZCavI1) |  |
| Plastic box | [Digitec (CH)](https://www.digitec.ch/en/s1/product/kis-w-375-x-25-x-23-cm-15-l-storage-boxes-13405854) | Walmart/Target | Optional enclosure. 37.5 x 25 x 23 cm, 15 l or larger. |
| Step-up converter (optional) | [AliExpress](https://de.aliexpress.com/item/1005008374772473.html) | - | Optional, e.g. for quieter fan control. |
| 12 V or 5 V fan (optional) | generic | generic | Optional cooling. |
| Glue, tape, wood or cardboard and rubber bands | generic | generic | For assembly, [see pictures](https://github.com/opencca/opencca-box) |

</div>

- [See 3D models](#3d-print-models)

### Maskrom MOSFET

The MOSFET circuit is not strictly necessary. You can flash the firmware manually by pressing the physical button on the SoC. However, if you plan to do this thousands of times (like we did during the initial bring up), it may be worth automating this. We soldered a simple circuit to the board to bypass the physical button, using a MOSFET as a programmable switch controlled via a Raspberry Pi GPIO pin.

**Wiring (example GPIO17):**
- GPIO17 → **220Ω** → MOSFET **Gate (G)**
- **10kΩ** from Gate → **GND** (pull-down)
- MOSFET **Source (S)** → **GND** (Pi and ROCK5 share ground)
- MOSFET **Drain (D)** → **BOOT_SARADC_IN0** on ROCK5

<br />


<!-- <div>
{{< img src="images/mosfet_circuit.png" class="hugo-image-500" width="100" alt="Optional Box Enclosure" >}}

{{< img src="images/wiring2-rk3588.png" class="hugo-image-500" width="100" alt="Button wiring rk3588" >}}
</div> -->


<div class="img-row">
  <div class="img-col">
    <a href="/images/mosfet_circuit.png">{{< img src="images/mosfet_circuit.png" class="hugo-image-500" alt="Optional Box Enclosure" >}}</a>
  </div>
  <div class="img-col">
    <a href="/images/wiring2-rk3588.png">{{< img src="images/wiring2-rk3588.png" class="hugo-image-500" alt="Button wiring rk3588" >}}</a>
  </div>
</div>
Click images for large version. GND (green) is not strictly needed for circuit.

<div class="table-compact-col2 table-parts">

| Product | Link | US Purchase Link | Comment |
| --- | --- | --- | --- |
| Circuit board | [AliExpress](https://de.aliexpress.com/item/1005007204340724.html?spm=a2g0o.order_list.order_list_main.58.3e151802BGaqce&gatewayAdapt=glo2deu) | [Amazon](https://a.co/d/ciaqs2W) | For a Maskrom automation circuit. |
| Soldering Toolkit | - | [Amazon](https://a.co/d/hAcUCru) | Recommended for assembly. |
| MOSFET IRLZ44N | [AliExpress](https://de.aliexpress.com/item/1005007084578589.html?spm=a2g0o.order_list.order_list_main.365.5db418020aPOaU&gatewayAdapt=glo2deu) | [Amazon](https://a.co/d/9UDknNw) |  |
| 10kΩ resistor + 220Ω resistor | - | [Amazon](https://a.co/d/egUQ9CD) |  |
| Cables | [AliExpress](https://de.aliexpress.com/item/1005003252824475.html?spm=a2g0o.order_list.order_list_main.113.3e151802BGaqce&gatewayAdapt=glo2deu) | [Amazon](https://a.co/d/iTy9K27) | Breadboard jumpers. |
| LED | - | [Amazon](https://a.co/d/2z4iQa8) | Optional status indicator. |

- [More MOSFET wiring pictures](https://github.com/opencca/opencca-box/blob/main/mosfet-circuit)
- See scripts in [opencca-flash/board/maskrom](https://github.com/opencca/opencca-flash/tree/opencca/main/board/maskrom)
- [Entering Maskrom Mode (Radxa)](https://docs.radxa.com/en/rock5/rock5b/low-level-dev/install-os/rkdevtool_maskrom)

</div>

## 3D Print Models

You find instructions on how to obtain and print the 3D models in the
[opencca-box](https://github.com/opencca/opencca-box) repository.

