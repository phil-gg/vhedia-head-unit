# Vhedia head unit

## Background / rationale

 - I use a Vhedia M-series head unit in a model year 2023 Mitsubishi Triton MR
 - This repository is a backup of the firmware files and patches from Vhedia, in case the originals are taken offline
 - This repository also holds instructions for setup and fixes I have applied to the unit
 - The original source of these of these files is [vhedia.com.au/download-m-series-update](https://vhedia.com.au/download-m-series-update/)

## Vhedia M-series hardware & firmware info

 - I like the Android home screen, which shows just a speedo, not a map, as I want to do 100% of my map use from within Carplay and iOS.  The final firmware with this home screen, is the build from Sep-2024, a copy of which is held in this repository.
 - Note that "latest stable Android _(sic)_", that the [sales pitch suggests is available](https://vhedia.com.au/product/mitsubishi-triton-mq-mr-head-unit-2016-2021-dail-aircon/) is **NOT** available for Vhedia M-series head unit (material mis-selling that I was misled by), only Android 10 (at least from Vhedia, my vendor in Australia), and given this Sep-2024 firmware version has all the final Android 10 security patches included, there is not a lot to be gained by keeping pace with Vhedia's later firmware updates.
 - However the Vhedia M-series head unit is simply the Junsun 8667Q (8GB RAM, 128GB internal storage), with a custom Vhedia firmware - you could try other Junsun firmware, but your mileage may vary (and the maintainer of this backup repository has no interest in any further exploration of these other possibilities).
 - The firmware here has been compressed with:
    ```
    tar -cJf M-series-20240924.tar.xz 8667.bin 8667.upd
    ```
 - Unpack with:
    ```
    tar -xf M-series-20240924.tar.xz
    ```
 - As is typical for Android firmware packages, `8667.upd` is a text file containing only the md5sum of `8667.bin`.
 - The Android firmware package is a large binary that cannot be committed into the repo itself, rather the firmware package is available as [a release here](https://github.com/phil-gg/vhedia-head-unit/releases/download/M-series-firmware/M-series-20240924.tar.xz).

## Files in this repo

| **File name**            | **Type**   | **File size**       | **md5sum**                       |
|:-------------------------|:-----------|:--------------------|:---------------------------------|
| M-series-20240924.tar.xz | Compressed | 1,868,956,696 bytes | 93e34a816f5ba40b8b937cc4e507ffa3 |
| 8667.bin                 | Unpacked   | 4,088,706,520 bytes | 17d69a4b5498bf3f6730a26b810d90f5 |
