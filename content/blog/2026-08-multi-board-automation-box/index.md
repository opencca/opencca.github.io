---
title: "Multi-Board Automation Box"
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

The original [OpenCCA box](/docs/guides/hardware/) manages to automate away a lot of manual work during development, however it does not scale well to development setups with multiple people or boards, requiring for example an entire Raspberry Pi to control each board. To address this, we built a multi-board automation box, supporting board and user multiplexing through one central control server.

## Hardware setup

---

{{< img class="hugo-image" src="images/multiboard-box.jpg" width="600" alt="The multi-board OpenCCA automation box" >}}
<br>
The box consists of an array of plates `(d)` ([3D case files here](https://www.printables.com/model/330063-rock-5b-5-node-cluster)), holding a board and its accessories ([Maskrom MOSFET circuit](#maskrom-mosfet-circuit), USB-to-UART converter) stacked next to each other. Each board connects to a central USB hub`(c)` via its USB-C port for data and to a second hub `(b)` through its USB-to-UART converter. Each board has its own power delivery, gated by a wireless smart plug `(a)`. As the Rock 5B has a single USB-C port for data and power delivery, we designed and use a [USB-C splitter](/docs/reference/rk3588/split-data--power/) to split the data and power pins, preventing power back-feed from the data hub when the board power delivery is turned off.

<br>

{{< img class="hugo-image" src="images/usbc-splitter-pcb.png" width="100" alt="3D render of the USB-C splitter PCB" >}}

<br>

A ESP32 microcontroller `(e)` is connected to each board's Maskrom circuit via a GPIO pin, which is addressable on the control server via a small [custom firmware](https://github.com/opencca-multi-manager/multi-manager-esp32-gpio-controller). The box is connected to the control server via USB `(f)`, alongside ethernet and power.

<br>

{{< img class="hugo-image" src="images/multiboard-box-top.jpeg" width="100" alt="">}}

<br>

### Maskrom MOSFET circuit

[See also](/docs/guides/hardware/#maskrom-mosfet)

{{< img class="hugo-image" src="images/mosfet_circuit.png" width="100" alt="MOSFET circuit topology" >}}

<br>

This simple circuit is used to pull down the maskrom button on a board when the GPIO pin is set via ESP32, removing the need to physically press the button. The LED only indicates the input state, it can be omitted from the circuit.

{{< img class="hugo-image" src="images/mosfet_soldered.png" width="100" alt="Underside of soldered circuit" >}}
<br>
{{< img class="hugo-image" src="images/mosfet_soldered_top.jpg" width="100" alt="Top side of soldered circuit" >}}

## Management software

---

The box is controlled from a central server through the USB hub via a custom management program [rktool](https://github.com/opencca-multi-manager/multi-manager-rktool), which acts as a wrapper around [rkdeveloptool](https://github.com/opencca-multi-manager/multi-manager-rkdeveloptool). We had to patch rkdeveloptool to increase its device ID granularity to identify multiple connected boards on the same hub.

We keep a config listing each connected boards hub location, its owner (Linux user), the IP address of its smart plug and the ESP32 GPIO pin it is connected to, alongside behavioural configurations. The software then multiplexes user requests to their own boards, letting them either invoke rktool commands, put the board into maskrom mode or connect a minicom console to the UART interface (and more). A guide to setting up and configuring new boards can be found in the [rktool README](https://github.com/opencca-multi-manager/multi-manager-rktool).

The full command line interface is as follows:

```
Usage: rktool [--board NAME] <command> [args...]

Board commands:
  uart              launch minicom on the board's serial port
  power <action>    on | off | reboot | cycle  (via smartplug)
  maskrom           put board into maskrom mode
  list              show boards and their user assignments

Debug commands:
  gpio-reset                  reset the GPIO controller
  gpio-pin <pin> <high|low>   set an ESP32 GPIO pin high or low
  smartplug <on|off>          control the smartplug directly
  uhubctl <on|off>            control the USB hub directly

All other commands are forwarded to rkdeveloptool.

Flags:
  --board NAME       select board by name (default: user's assigned board)
  --log-file / -l    minicom log file path (default: minicom.txt in current directory)
  --verbose / -v     print all commands before executing them
```
