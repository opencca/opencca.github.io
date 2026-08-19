---
title: "Split Data + Power"
description: ""
summary: ""
date: 2026-08-01T16:04:48+02:00
lastmod: 2026-08-01T16:04:48+02:00
draft: false
weight: 1200
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

Depending on your power supply, the single USB-C PD port may not provide enough power to both flash firmware and reliably power all cores.
This can lead to boot loops when too many cores draw current at the same time.
A USB-C splitter can be used to split the single USB-C port into separate data and power ports.


<br />

{{< img src="./usb-c-splitter.jpg" class="" width="100" alt=" DSTREAM-ST JTAG 20 connection" >}}

<br />

See the PCB files on [github.com/opencca/power-data-pcb](https://github.com/opencca/power-data-pcb/).

This approach has the advantage that the RK3588 can negotiate the full available power over USB-C PD with the power supply and is not limited by the current provided by the USB-C dock ([see USB-C dock approach](/docs/guides/hardware/#usb-c-dock)) or host machine.
