---
title: "Multi-Board Automation Box"
description: ""
date: 2026-08-20T12:55:08+02:00
date: 2026-08-20T12:55:08+02:00
draft: false
weight: 48
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

The original [OpenCCA box](/docs/guides/hardware/) manages to automate away a lot of manual work during development, however it does not scale well to development setups with multiple people or boards. It requires for example an entire Raspberry Pi to control each board.

To address this, we built a multi-board automation box, supporting board and user multiplexing through one central control server.


## Hardware setup

---



The box consists of an array of plates `(d)` ([3D case files here](https://www.printables.com/model/330063-rock-5b-5-node-cluster)), holding a board and its accessories (Maskrom MOSFET circuit, [USB-to-UART converter](/docs/reference/rk3588/connect-to-uart/)) stacked next to each other.

[{{< img class="" src="./multiboard-box.jpg" width="800" alt="The multi-board OpenCCA automation box" >}}](./multiboard-box.jpg)

>
> Figure: Automation box
>
> (a) smart plug
>
> (b) USB to UART
>
> (c) central USB hub
>
> (d) array of RK3588 plates
>
> (e) esp32 for maskrom
>
> (f) power
>

<br>

Each board connects to a central USB hub`(c)` that is connected to a single host machine.

An ESP32 microcontroller `(e)` is connected to each board's Maskrom circuit via a GPIO pin, which is addressable on the control server via a small [custom firmware](https://github.com/opencca-multi-manager/multi-manager-esp32-gpio-controller). The box is connected to host machine via USB `(f)`, alongside ethernet and power.


<br>

[{{< img class="" src="./multiboard-box-top.jpeg" alt="">}}](./multiboard-box-top.jpeg)



<br>

<!-- ### Maskrom MOSFET circuit

[See also](/docs/guides/hardware/#maskrom-mosfet)

{{< img class="hugo-image" src="images/mosfet_circuit.png" width="100" alt="MOSFET circuit topology" >}}

<br>

This simple circuit is used to pull down the maskrom button on a board when the GPIO pin is set via ESP32, removing the need to physically press the button. The LED only indicates the input state, it can be omitted from the circuit.

{{< img class="hugo-image" src="images/mosfet_soldered.png" width="100" alt="Underside of soldered circuit" >}}
<br>
{{< img class="hugo-image" src="images/mosfet_soldered_top.jpg" width="100" alt="Top side of soldered circuit" >}}
 -->
## Management software

---

The box is controlled from a central host machine through the USB hub `(c)` via a custom management program [rktool](https://github.com/opencca-multi-manager/multi-manager-rktool), which acts as a wrapper around [rkdeveloptool](https://github.com/opencca-multi-manager/multi-manager-rkdeveloptool).


This tool provides commands to power cycle, serial output and maskrom mode.
It otherwise forwards commands to rkdeveloptool.


```bash
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


The tool is provided __as is__ as a starting point for similar automations at:
- [opencca-multi-manager](https://github.com/opencca-multi-manager/multi-manager-rktool)
- [More Pictures of the automation box](https://github.com/opencca-multi-manager/multi-manager-rktool/tree/main/pictures).

- Thanks to Simon Hostettler.


---

## More Pictures


Mosfet Circuit that is connected to single esp32 for each board:
{{< img class="" src="images/mosfet_circuit.png" width="100" alt="MOSFET circuit topology" >}}



{{< img class="" src="images/mosfet_soldered.png" width="100" alt="Underside of soldered circuit" >}}


{{< img class="" src="images/mosfet_soldered_top.jpg" width="100" alt="Top side of soldered circuit" >}}


<br />
<br />
<br />


