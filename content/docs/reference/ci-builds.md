---
title: "CI Builds"
description: ""
summary: ""
date: 2025-08-01T16:04:48+02:00
lastmod: 2025-01-07T16:04:48+02:00
draft: false
weight: 810
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

We host a [Github Runner](https://github.com/opencca/ci-scripts) that provides reproducible builds.

### Tools
| Repository                                                            | Description                                  | Build Status |
|-----------------------------------------------------------------------|----------------------------------------------|--------------|
| [tutorial](https://github.com/opencca/opencca-build/blob/opencca/main/.github/workflows/tutorial/tutorial-on-host.sh)                                                   | Quick start to build firmware                    | <a href="https://github.com/opencca/opencca-build/actions/workflows/tutorial.yml"><img src="https://github.com/opencca/opencca-build/actions/workflows/tutorial.yml/badge.svg" alt="quick-start tutorial"></a> |
|[opencca-build](https://github.com/opencca/opencca-build)              | Build docker container       | <a href="https://github.com/opencca/opencca-build/actions/workflows/build.yaml"><img src="https://github.com/opencca/opencca-build/actions/workflows/build.yaml/badge.svg" alt="build-container"></a> |


### Firmware

| Repository                                                            | Description                                  | Build Status |
|-----------------------------------------------------------------------|----------------------------------------------|--------------|
|[arm-trusted-firmware](https://github.com/opencca/arm-trusted-firmware)| Arm TF-A                                     | <a href="https://github.com/opencca/arm-trusted-firmware/actions/workflows/opencca-build.yml"><img src="https://github.com/opencca/arm-trusted-firmware/actions/workflows/opencca-build.yml/badge.svg" alt="opencca-build"></a> |
|[tf-rmm](https://github.com/opencca/tf-rmm)                            | Realm Management Monitor (TF-RMM)            | <a href="https://github.com/opencca/tf-rmm/actions/workflows/opencca-build.yml"><img src="https://github.com/opencca/tf-rmm/actions/workflows/opencca-build.yml/badge.svg" alt="opencca-build"></a> |
|[kvmtool](https://github.com/opencca/kvmtool)                          | Kvmtool VMM                                  | <a href="https://github.com/opencca/kvmtool/actions/workflows/opencca-build.yml"><img src="https://github.com/opencca/kvmtool/actions/workflows/opencca-build.yml/badge.svg" alt="opencca-build"></a> |
|[linux](https://github.com/opencca/linux)                              | CCA Enlightened Host/Guest Kernels           | <a href="https://github.com/opencca/linux/actions/workflows/opencca-build.yml"><img src="https://github.com/opencca/linux/actions/workflows/opencca-build.yml/badge.svg" alt="opencca-build"></a> |
|[u-boot](https://github.com/opencca/u-boot)                            | Second Stage Loader U-Boot                    | <a href="https://github.com/opencca/u-boot/actions/workflows/opencca-build.yml"><img src="https://github.com/opencca/u-boot/actions/workflows/opencca-build.yml/badge.svg" alt="opencca-build"></a> |



