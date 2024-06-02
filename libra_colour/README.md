# Kobo Libra Colour information

## Kernel

```bash
[root@kobo ~]# uname -a
Linux kobo 4.9.77 #1 SMP PREEMPT 69bc51802-20240419T134452-B0419142243 armv7l GNU/Linux
```

## Battery

```bash
[root@kobo ~]# ls -l /sys/class/power_supply/
total 0
lrwxrwxrwx    1 root     root             0 Jun  2 17:51 bd71827_ac -> ../../devices/platform/10019000.i2c/i2c-1/1-004b/bd71827-power.4.auto/power_supply/bd71827_ac
lrwxrwxrwx    1 root     root             0 Jun  2 17:51 bd71827_bat -> ../../devices/platform/10019000.i2c/i2c-1/1-004b/bd71827-power.4.auto/power_supply/bd71827_bat

[root@kobo ~]# ls -l /sys/class/power_supply/bd71827_bat/
total 0
-r--r--r--    1 root     root          4096 Jun  2 17:51 batt_params
-r--r--r--    1 root     root          4096 Jun  2 17:51 capacity
-r--r--r--    1 root     root          4096 Jun  2 17:51 charge_full
-r--r--r--    1 root     root          4096 Jun  2 17:51 charge_full_design
-r--r--r--    1 root     root          4096 Jun  2 17:51 charge_now
-r--r--r--    1 root     root          4096 Jun  2 17:51 charge_type
-rw-r--r--    1 root     root          4096 Jun  2 17:51 charger_type
-rw-r--r--    1 root     root          4096 Jun  2 17:51 charging
-r--r--r--    1 root     root          4096 Jun  2 17:51 current_avg
-r--r--r--    1 root     root          4096 Jun  2 17:51 current_max
-r--r--r--    1 root     root          4096 Jun  2 17:51 current_now
lrwxrwxrwx    1 root     root             0 Jun  2 17:51 device -> ../../../bd71827-power.4.auto
-rw-r--r--    1 root     root          4096 Jun  2 17:51 gauge
-r--r--r--    1 root     root          4096 Jun  2 17:51 health
-rw-r--r--    1 root     root          4096 Jun  2 17:51 moist
-rw-r--r--    1 root     root          4096 Jun  2 17:51 moist_force_powerctrl
-r--r--r--    1 root     root          4096 Jun  2 17:51 online
drwxr-xr-x    2 root     root             0 Jun  2 17:51 power
-r--r--r--    1 root     root          4096 Jun  2 17:51 present
-rw-r--r--    1 root     root          4096 Jun  2 17:51 register
-r--r--r--    1 root     root          4096 Jun  2 17:51 status
lrwxrwxrwx    1 root     root             0 Jun  2 17:51 subsystem -> ../../../../../../../../class/power_supply
-r--r--r--    1 root     root          4096 Jun  2 17:51 technology
-r--r--r--    1 root     root          4096 Jun  2 17:51 temp
-r--r--r--    1 root     root          4096 Jun  2 17:51 type
-rw-r--r--    1 root     root          4096 Jun  2 17:51 uevent
-r--r--r--    1 root     root          4096 Jun  2 17:51 voltage_max
-r--r--r--    1 root     root          4096 Jun  2 17:51 voltage_min
-r--r--r--    1 root     root          4096 Jun  2 17:51 voltage_now
```

## CPU

```bash
[root@kobo ~]# cat /proc/cpuinfo
processor       : 0
Processor       : ARMv7 Processor rev 4 (v7l)
model name      : ARMv7 Processor rev 4 (v7l)
BogoMIPS        : 15.60
Features        : half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt vfpd32 lpae evtstrm aes pmull sha1 sha2 crc32
CPU implementer : 0x41
CPU architecture: 7
CPU variant     : 0x0
CPU part        : 0xd03
CPU revision    : 4

Hardware        : MediaTek MT8110 board
Revision        : 0000
Serial          : 1234567890ABCDEF
```

## Memory

```bash
[root@kobo ~]# cat /proc/meminfo
MemTotal:         965488 kB
MemFree:          662108 kB
MemAvailable:     785016 kB
Buffers:           12552 kB
Cached:           140504 kB
SwapCached:            0 kB
Active:            89028 kB
Inactive:         126808 kB
Active(anon):      62764 kB
Inactive(anon):      664 kB
Active(file):      26264 kB
Inactive(file):   126144 kB
Unevictable:          12 kB
Mlocked:              12 kB
HighTotal:        248832 kB
HighFree:          12820 kB
LowTotal:         716656 kB
LowFree:          649288 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:                 4 kB
Writeback:             0 kB
AnonPages:         62824 kB
Mapped:            91200 kB
Shmem:               652 kB
Slab:              23312 kB
SReclaimable:       7072 kB
SUnreclaim:        16240 kB
KernelStack:        1360 kB
PageTables:         1232 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:      482744 kB
Committed_AS:     299704 kB
VmallocTotal:     245760 kB
VmallocUsed:           0 kB
VmallocChunk:          0 kB
CmaTotal:              0 kB
CmaFree:               0 kB
```

## Storage

```bash
[root@kobo ~]# df -h
Filesystem                Size      Used Available Use% Mounted on
/dev/root               975.9M    297.0M    662.9M  31% /
devtmpfs                471.4M    120.0K    471.3M   0% /dev
none                    471.4M         0    471.4M   0% /tmp
none                    471.4M    120.0K    471.3M   0% /dev
none                     16.0K      4.0K     12.0K  25% /var/lib
none                     16.0K         0     16.0K   0% /var/log
none                    128.0K     24.0K    104.0K  19% /var/run
/dev/mmcblk0p8            6.7M    215.0K      6.0M   3% /data/init_bin
/dev/mmcblk0p12          26.8G      1.0G     25.8G   4% /mnt/onboard
```
