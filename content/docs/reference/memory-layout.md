---
title: "RK3588 Memory"
description: ""
summary: ""
date: 2025-08-01T16:04:48+02:00
lastmod: 2025-01-07T16:04:48+02:00
draft: false
weight: 10
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "rk3588-memory" # custom canonical URL (optional)
  noindex: false # false (default) or true
---

<style>

.box-thumb img,
img.box-thumb {
  max-width: 500px;
  height: auto;
  display: block;
  margin-left: auto;
  margin-right: auto;
}
</style>

## Layout

We load the firmware at the beginning of the first DRAM.
<!-- TODO: There is a typo in the comment in the source, fix that first -->

{{< img class="box-thumb" src="images/memorylayout1.png" width="300" alt="Memory Layout" >}}
> Figure: Memory region DRAM Bank 1. Color: Firmware memory. Not to scale.
<br />

- [How to use more than 4GB on Rock 5B](/docs/guides/faq/)
