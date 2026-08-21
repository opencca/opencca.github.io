---
title: "Extended Memory Layout"
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

The initial SysTeX release of OpenCCA limited usable memory on the platform to 4GB.
This way, OpenCCA worked on all configurations of the RK3588, in including the 4GB model.

However, for workloads such as AI models, 4 GB quickly become restrictive.
With selected changes in TF-A, RMM and U-Boot, this limit can be lifted.

- [TLDR: Pull request for more RAM](https://github.com/opencca/arm-trusted-firmware/issues/1).

This post looks at the main changes required.

---

##### Table of Contents

* [RMM Granule Metadata](#rmm-granule-metadata)
  * [Granule Descriptor](#granule-descriptor)
* [New Memory Carveout](#new-memory-carveout)
* [How do I use it?](#how-do-i-use-it)
  * [Example: Debian CVM with 12 GB RAM](#example-debian-cvm-with-12-gb-ram)


---

## RMM Granule Metadata

The RMM keeps metadata of all tracked granules in a [shadow struct](https://github.com/opencca/tf-rmm/blob/c362b43e2652dfeb885dd00a00f6c4face6d4da3/lib/granule/src/granule.c#L18): `granules[]`.

A granule is the unit at which the RMM tracks memory.
The RMM v0.6 currently hard-codes this to 4KB.

```c
struct granule {
	uint16_t	descriptor;
};
static struct granule granules[RMM_MAX_GRANULES];
```

The `struct granule` stores a 16-bit descriptor for every RMM-addressable memory granule on the platform.

If the system contains more RAM, the array also needs to grow.
Because `granules[]` is a linear array, its size grows linearly with the amount of RMM-addressable memory:

```
 for  1 GB RMM-addressable memory: sizeof(granules) ==  0.5 MB
 for 64 GB RMM-addressable memory: sizeof(granules) == 32.0 MB
```

As a result, supporting more memory also requires reserving more memory for the RMM itself.

{{< details "Detour: **What does RMM store in the Granule Descriptor?**" >}}

##### Granule Descriptor

The 16-bit descriptor contains these three fields:

```c
                     /* Granule Descriptor (16 bits): */

        bit 15            bits 14..10              bits 9..0
     +------------+-----------------------+---------------------------+
     |  bit_lock  |         state         |         refcount          |
     +------------+-----------------------+---------------------------+
         1 bit              5 bits                  10 bits
```

The descriptor contains 3 fields:
- `bit_lock` locks the granule,
- `state` identifies the type (hypervisor-shared, realm data, internal object, etc...),
- and a `refcount` to determine when to un-delegate a memory back to hypervisor.


With 10 bits, `refcount` can store up to `2**10 - 1 = 1023` references.

For example,
a translation-table granule (`type` translation table) usually requires many refcounts. A table can contain 512 entries (`512 entries * 8 byte pointer = 4 KB granule`). The RMM may hold one reference for each entry. Nine bits only represent values `0-511`, so a count of 512 requires at least 10 bits, which is currently sufficient for the RMM and provides enough space.

[See header file here.](https://github.com/opencca/tf-rmm/blob/c362b43e2652dfeb885dd00a00f6c4face6d4da3/lib/granule/include/granule_types.h#L212)

{{< /details >}}

### New Memory Carveout

To keep track of more memory, we change the RK3588 platform layout to:

- We reserve 128 MB for BL31,
- 256 MB for RMM (text, heap, data, etc.),
- leave additional space for changes,
- and relocate U-Boot Proper to 512 MB offset (`NS DRAM start`).

The new layout looks like this:

```
/*
 * New RK3588 memory layout in TF-A:
 *
 *              RK3588 DRAM Bank 0 layout:
 *  0x00000000  +----------------------------+ ARM_DRAM_RME_RESERVE_BASE
 *              | BL31 / TF-A                | ARM_DRAM_BL31_RESERVE_BASE
 *              | 128 MB                     |
 *  0x08000000  +----------------------------+ ARM_EL3_RMM_SHARED_BASE
 *              | TF-A <-> RMM shared        |
 *              | 4 KB                       |
 *  0x08001000  +----------------------------+ ARM_REALM_BASE
 *              | RMM / Realm DRAM           |
 *              | 256 MB - 4 KiB             |
 *              +----------------------------+ ARM_L0_GPT_BASE
 *              | L0 GPT                     |
 *              +----------------------------+ ARM_L1_GPT_BASE
 *              | L1 GPT                     |
 *              +----------------------------+
 *              | reserve until 512 MB       |
 *  0x20000000  +----------------------------+  RMM_NS_RAM1_BASE
 *  (at 512 MB) | NS DRAM start              |
 *              | BL33 / U-Boot/ Linux       |
 *  0xf0000000  +----------------------------+  ARM_DEVICES0_BASE
 *              | MMIO / devices             |
 */
```

The main change is that non-secure DRAM now starts at `0x20000000 (512 MB)`. In the old layout, this was much smaller (~ 160 MB).

Everything below it is available for TF-A, RMM, GPTs, and related firmware data structures.

## How do I use it?

At some point, (not until now), I will merge the PR into `opencca/main`.
Until then, cherry pick these changes into TF-A, U-Boot, and the RMM.

[https://github.com/opencca/arm-trusted-firmware/issues/1](https://github.com/opencca/arm-trusted-firmware/issues/1).

#### Example: Debian CVM with 12 GB RAM

With more platform memory, CVMs can be created with substantially more RAM.

For instance, this snippet spawns a CVM with 12 GB RAM and 3 vCPUs,
along with a Debian rootfs.

```sh
Debian GNU/Linux 12 vm ttyS0

opencca
user: root, password: root

vm login: root
Password:

root@vm:~#

```

{{< details "**Platform Boot:**" >}}


Boot platform with 4 cores, use 3 cores for CVM.


```sh
root=UUID=94541ef3-02b7-4786-a0ed-70360c0d3cb1 rootwait \
  isolcpus=1,2,3 nohlt cpuidle.off=1 maxcpus=4

```


{{< /details >}}



{{< details "**CVM Boot:**" >}}

- `WAN` is set to correct ethernet interface on RK3588
- `BIN` is set to kvmtool
- `IMAGE` is set to guest kernel
- `DISK` is set to debian rootfs ([download from here](https://drive.google.com/file/d/1YSuf4WVw8OaGos2OA8z6KiaYvB9v9bbs/view?usp=drive_link))

```sh
#!/bin/bash

# Sample script for multi GB ram guest with
# - networking (along with some default ports forwarded)
# - 9p diretory sharing with host
# - debian rootfs

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Set these:
BIN=/mnt/snapshot/lkvm
IMAGE=/mnt/snapshot/Image
DISK=/mnt/snapshot/debian-guest.img
WAN=enP4p65s0

# rk3588 config
SHARED_DIR_9P=/
LAN=tap0

function prepare_net {
  sudo ip link set $LAN down 2>/dev/null || true
  sudo ip tuntap del dev $LAN mode tap 2>/dev/null || true

  sudo ip tuntap add dev $LAN mode tap user "$USER"
  sudo ip addr add 192.168.33.1/24 dev $LAN 2>/dev/null || true
  sudo ip link set $LAN up promisc on

  sudo sysctl -w net.ipv4.ip_forward=1
  sudo iptables-legacy -F FORWARD
  sudo iptables-legacy -t nat -F PREROUTING
  sudo iptables-legacy -t nat -F POSTROUTING

  sudo iptables-legacy -I FORWARD -i $LAN -o $WAN -j ACCEPT
  sudo iptables-legacy -t nat -A POSTROUTING -o "$WAN" -j MASQUERADE

  local GUEST_IP="192.168.33.2"
  sudo iptables-legacy -I FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

  # ssh
  sudo iptables-legacy -t nat -I PREROUTING -i "$WAN" -p tcp --dport 2020 -j DNAT --to-destination $GUEST_IP:22
  sudo iptables-legacy -I FORWARD -p tcp -d $GUEST_IP --dport 22 -j ACCEPT

  # https
  sudo iptables-legacy -t nat -I PREROUTING -i "$WAN" -p tcp --dport 2443 -j DNAT --to-destination $GUEST_IP:443
  sudo iptables-legacy -I FORWARD -p tcp -d $GUEST_IP --dport 443 -j ACCEPT

  # http
  sudo iptables-legacy -t nat -I PREROUTING -i "$WAN" -p tcp --dport 2080 -j DNAT --to-destination $GUEST_IP:80
  sudo iptables-legacy -I FORWARD -p tcp -d $GUEST_IP --dport 80 -j ACCEPT

  # a bunch of aux ports: 2099/98/97 -> 2099/98/97
  sudo iptables-legacy -t nat -I PREROUTING -i "$WAN" -p tcp --dport 2099 -j DNAT --to-destination $GUEST_IP:2099
  sudo iptables-legacy -I FORWARD -p tcp -d $GUEST_IP --dport 2099 -j ACCEPT
  sudo iptables-legacy -t nat -I PREROUTING -i "$WAN" -p tcp --dport 2098 -j DNAT --to-destination $GUEST_IP:2098
  sudo iptables-legacy -I FORWARD -p tcp -d $GUEST_IP --dport 2098 -j ACCEPT
  sudo iptables-legacy -t nat -I PREROUTING -i "$WAN" -p tcp --dport 2097 -j DNAT --to-destination $GUEST_IP:2097
  sudo iptables-legacy -I FORWARD -p tcp -d $GUEST_IP --dport 2097 -j ACCEPT


  # show all routing rules:
  sudo iptables-legacy -t nat -nvL PREROUTING
}

function pin {
  # needed to assign kvm-vcpus to isolcpus after they have spawned

  sleep 6
  local pid=$(pgrep -n lkvm)

  sudo taskset -pc 1 $(ps -T -p "$pid" -o tid=,comm= | awk '$2=="kvm-vcpu-0"{print $1}')
  sudo taskset -pc 2 $(ps -T -p "$pid" -o tid=,comm= | awk '$2=="kvm-vcpu-1"{print $1}')
  sudo taskset -pc 3 $(ps -T -p "$pid" -o tid=,comm= | awk '$2=="kvm-vcpu-2"{print $1}')
}


function check_cmdline() {
  # we configure the platform as following:
  # set these in  /boot/extlinux/extlinux.conf
  # "isolcpus=1,2,3 nohlt cpuidle.off=1"
  local params=("nohlt" "cpuidle.off=1")
  local cmd=$(cat /proc/cmdline)

  for p in "${params[@]}"; do
    if [[ ! "$cmd" =~ $p ]]; then
      echo "\n\n======= MISSING: $p \n"
    fi
  done
}


check_cmdline
prepare_net
pin &

set -x
sudo nice -n -20 $BIN run  \
     --realm \
     --restricted_mem  \
     -c 3 \
     -d $DISK \
     -k $IMAGE \
     --vcpu-affinity 1,2,3 \
     --disable-sve -m 12G \
    --9p "$SHARED_DIR_9P,host_share" \
    -p "root=/dev/vda1 rootwait console=hvc0 loglevel=8 ds=nocloud" \
    -n mode=tap,tapif=tap0,guest_mac=02:aa:bb:cc:dd:01

```



{{< /details >}}






<br />
<br />
<br />


