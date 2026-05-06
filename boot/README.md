# Rooting the Vhedia head unit

## Summary of files

 - `01-extract-boot-img.sh`
    - _My first attempt to extract boot.img from firmware; pure bash._
 - `alt-firmware-analysis.sh`
    - _Second attempt to extract boot.img from firmware; python (output img md5sum values match up)._
 - `02-pad-patched-boot.sh` & `03-inject-boot-img.sh`
    - _Incomplete efforts to build a rooted firmware update, with a Magisk updated boot image - see Roadblock section below._
 - `boot.img`
    - _Not rooted boot image extracted from [M-series-firmware](https://github.com/phil-gg/vhedia-head-unit/releases/M-series-firmware) (md5sum `b8af97f457eaed51cce8bf2fb2181ab8`)_
 - `bootanimation.zip`
    - _Hal9000 bootanimation to match the Mediatek updated boot logo custom image_

## Roadblocks

 - `adb root` is blocked with the message `cxj said not suport, 88`
 - No su or fastboot on the device
 - Injecting Magisk updated boot image into firmware, and upgrading, gets unit stuck in a boot loop (`=> FASTBOOT mode`)
    - _Press reset (`RST`) button with pin, then immediately repeatedly tap on the screen with five fingers apart, to enter into a recovery mode that will look for replacement `8667.bin` from USB_

## Next steps

 - Could try a custom `8667.bin` with `\system\media\bootanimation.zip` replaced in `system.img`
