---
title: "Connect to UART"
description: ""
summary: ""
date: 2025-08-01T16:04:48+02:00
lastmod: 2025-01-07T16:04:48+02:00
draft: false
weight: 100
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

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
- [Connect to board with Minicom](https://github.com/opencca/opencca-flash/blob/opencca/main/minicom.sh)
- [Connecting Serial Console](https://wiki2.radxa.com/Rock5/dev/serial-console)

