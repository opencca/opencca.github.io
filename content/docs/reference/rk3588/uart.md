---
title: "Connect to UART"
description: ""
summary: ""
date: 2025-08-01T16:04:48+02:00
lastmod: 2025-01-07T16:04:48+02:00
draft: false
weight: 1200
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

Connect to TX, RX and GND to the TTL usb adapter (we need 3.3V).


Pins odd | Pin | Pin | Pins even
------------------------|-----|-----|-----------------------
Vref (3.3V)             | 1   | 2   | 5V
GPIO                    | 3   | 4   | 5V
GPIO                    | 5   | **6**   | **GND**
GPIO                    | 7   | **8**   | **UART_TX**
GND                     | 9   | **10**  | **UART_RX**
...                     | ... | ... | ...


```bash
#!/bin/bash
cat > $HOME/.minirc.rock5b <<- CMD
pu baudrate         1500000
pu bits             8
pu parity           N
pu stopbits         1
pu rtscts           No
CMD

minicom -w -t xterm -l -R UTF-8 -D /dev/ttyUSB0 rock5 -C ./minicom.txt

```
- [Connecting Serial Console](https://wiki2.radxa.com/Rock5/dev/serial-console)
- [Connect to board with Minicom](https://github.com/opencca/opencca-flash/blob/opencca/main/minicom.sh)

