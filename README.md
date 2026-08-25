# Vhedia (& Junsun) head unit(s)

## Background / rationale

  - I bought a MT-1912 head unit from [Vhedia](https://vhedia.com.au/product/mitsubishi-triton-mq-mr-head-unit-2016-2021-dail-aircon/) _(order date 23-March-2025, total cost AUD 1,032.65 including shipping and GST)_ to use in a model year 2023 Mitsubishi Triton MR
  - I also bought a Junsun V1 head unit from [Alibaba](https://www.alibaba.com/product-detail/Junsun-V1-RU-Stock-Wireless-CarPlay_1600994428446.html) _(order date 28-Nov-2025, total cost USD 243.91 / AUD 374.73 including shipping all taxes and Alibaba transaction fee)_ to use in a 2008 Toyota Camry ACV40R
  - Despite the 2.75 times price difference, these two are the same `FF_866X` hardware model, with Mediatek 8667 CPU, 8GB RAM, and 256GB onboard storage, same 1280 x 720 IPS screen, and they both run the exact same firmware, based on Android 10.  Each came with the fascia and all cables needed for their respective vehicles, and trim removal tools
  - This repository is a backup of various firmwares I use on my purchased units, in case the original sources (linked below) are taken offline

## FAQ

  - __Question:__  Would I recommend Vhedia?
      - __Answer:__  Absolutely NOT!!  I personally consider Vhedia to be solely a resale and marketing company who LIE about their products in the following ways:
          - __Claim:__  Vhedia states - [Latest stable Android operating system](https://vhedia.com.au/product/mitsubishi-triton-mq-mr-head-unit-2016-2021-dail-aircon/#:~:text=apps%20and%20media-,latest%20stable%20android%20operating%20system,-Its%20own%20built) - however, it is Android 10.  When I purchased in March 2025, this claim had been untrue for circa 4.5 years (Android 11 released 8-Sep-2020).  The latest stable Android was Android 15 at time of purchase, with Android 16 and Android 17 becoming the new latest stable versions in June 2025 and 2026 respectively.  Nothing later than Android 10 based firmware is available for this head unit
          - __Claim:__  Vhedia states - [Your factory controls still working](https://vhedia.com.au/product/mitsubishi-triton-mq-mr-head-unit-2016-2021-dail-aircon/#:~:text=your%20factory%20controls%20and%20cameras%2C%20still%20working) - however, my steering wheel controls are recognised by the software, but NOT correctly mapped to appropriate functions in the head unit.  See [this PDF](https://github.com/phil-gg/vhedia-head-unit/blob/main/2023-Triton-MR-steering-wheel-button-issues.pdf) for more details
          - __Claim:__  Vhedia states - [regular updates](https://vhedia.com.au/#:~:text=customization%2C%20epic%20support%2C-,regular%20updates,-%2C%20and%20a%203) - however, the [latest Vhedia firmware](https://vhedia.com.au/download-m-series-update/) is from September 2025 (corresponding with Junsun UI03 v19), while Junsun have an extra update available from February 2026 (UI03 v20)
          - __Claim:__  Vhedia states - [epic support and a 3-year warranty](https://vhedia.com.au/#:~:text=epic%20support%2C%20regular%20updates%2C%20and%20a%203-year%20warranty) - however, this is no use when Vhedia are technically clueless about any of their products, and Vhedia have to go back to (I think) Junsun or sibling manufacturer company, for all technical queries, for example, regarding the broken steering wheel button mapping, which Vhedia have failed to solve for me
          - __Doubling down on these false claims:__  After explicitly pointing out the above issues with the copy on the Vhedia website, by email to Vhedia support, Vhedia have since doubled down on all of these false claims in a misleading [new YouTube video here](https://www.youtube.com/watch?v=MtvloVq6mhY)
  - __Question:__  Would I recommend a Junsun head unit with Mediatek 8667 CPU, 8GB RAM, and 256GB onboard storage?
     - __Answer:__  Probably yes, but only because:
         - No aftermarket car head unit appears to exist, with any recent enough Android version to still get Google security updates _(and then rooting, customising & repacking these firmwares to apply these updates is a whole other rabbit hole)_
         - Google made changes for Android 14 onwards which makes it deeply unpalatable for aftermarket head unit manufacturers to use.  You only seem to be able to get Android 10 to 13 aftermarket head units and anything later is a faked version, with the version faking being visible through a mismatched, lower API version number in the settings
         - With the `Release 4` firmware, below, I do think this is probably about as good as is available on the market _(in late 2025 / early 2026)_ for aftermarket Android head units
         - But why pay many multiples of the price for Vhedia when they add absolutely no hardware or software value versus Junsun / manufacturer direct?  The _(admittedly helpful)_ installation videos on youtube are freely available to all, and given the important bits are about how to disassemble and rebuild your car dashboard (not head unit specifics), the [Camry/Aurion video](https://www.youtube.com/watch?v=-fwhdQVwbA0) worked just great for the Junsun head unit

## Release 1

  - This is the last Vhedia firmware release with a home screen UI showing a speedo and not a map
  - The overall download page for Vhedia M-series firmware is [vhedia.com.au/download-m-series-update](https://vhedia.com.au/download-m-series-update/)
  - The original download link for this specific firmware version is [vhedia.com.au/wp-content/uploads/2024/10/M-Series-20240924.zip](https://vhedia.com.au/wp-content/uploads/2024/10/M-Series-20240924.zip)
  - Link to firmware in this github repository:  [M-series-firmware-build-20240924](https://github.com/phil-gg/vhedia-head-unit/releases/tag/M-series-firmware)

| **File name**            | **Type**   | **File size**       | **md5sum**                       |
|:-------------------------|:-----------|:--------------------|:---------------------------------|
| M-series-20240924.tar.xz | Compressed | 1,868,956,696 bytes | 93e34a816f5ba40b8b937cc4e507ffa3 |
| 8667.bin                 | Unpacked   | 4,088,706,520 bytes | 17d69a4b5498bf3f6730a26b810d90f5 |

## Release 2

  - This was the latest Junsun firmware available _(requested via Alibaba seller support messages)_ at the time of purchase of the V1 unit for the Camry
  - Junsun's Google Drive link _(yes really)_ is:  [drive.google.com/file/d/1UZgRgoTQ0l7pdaYKqIWbWBcxlVreVCM-](https://drive.google.com/file/d/1UZgRgoTQ0l7pdaYKqIWbWBcxlVreVCM-)
  - Link to firmware in this github repository:  [Junsun-firmware-v19-unmodified](https://github.com/phil-gg/vhedia-head-unit/releases/tag/Junsun-firmware-v19-unmodified)

| **File name**                                            | **Type**   | **File size**       | **md5sum**                       |
|:---------------------------------------------------------|:-----------|:--------------------|:---------------------------------|
| v19_20250414_8667Q-Junsun-UI03-car-model-1280x720.tar.xz | Compressed | 1,802,212,760 bytes | 5e52f4f572c358804a60f150edead337 |
| 8667.bin                                                 | Unpacked   | 4,001,703,252 bytes | 38b16b41c2cca07f9be503991f61882f |

## Release 3

  - One more firmware update is now available from Junsun _(this one)_
  - Junsun's original Google Drive link is:  [drive.google.com/file/d/1SDy6NghyjUhYZwmwQKP4AoifnhxCOjUt](https://drive.google.com/file/d/1SDy6NghyjUhYZwmwQKP4AoifnhxCOjUt)
  - Link to firmware in this github repository:  [Junsun-firmware-v20-unmodified](https://github.com/phil-gg/vhedia-head-unit/releases/tag/Junsun-firmware-v20-unmodified)

| **File name**                                            | **Type**   | **File size**       | **md5sum**                       |
|:---------------------------------------------------------|:-----------|:--------------------|:---------------------------------|
| v20_20260120_8667Q-Junsun-UI03-car-model-1280x720.tar.xz | Compressed | 1,733,960,048 bytes | e7d3085e9a4530033748cefef068e3c2 |
| 8667.bin                                                 | Unpacked   | 3,918,661,116 bytes | 08c6ed4b58af47af6c639f0010b76a35 |

## Release 4

  - A third-party _(not me, nor Vhedia, nor Junsun)_ has made UI and Radio app fixes and repackaged the firmware for installation on the head unit
  - More details about the modifications are in the `README.txt` file included with the release
  - This is much better than any firmware available from Vhedia, because, the radio now shows RDS text, many UI bugs and issues in Vhedia & Junsun firmwares have been fixed, and all the different main UI themes from many different firmware releases, are all included in this one firmware package.
  - __WARNING:__  While I run this firmware successfully on both the Vhedia MT-1912 head unit in my Triton and the Junsun V1 head unit head unit in my Camry, your mileage may vary!
  - The original download link for this customised v20 firmware is (Telegram):  [t.me/Randroides/203339](https://t.me/Randroides/203339)
  - Link to firmware in this github repository:  [customised-v20-Junsun-firmware](https://github.com/phil-gg/vhedia-head-unit/releases/tag/customised-v20-Junsun-firmware)

| **File name**                                                 | **Type**   | **File size**       | **md5sum**                       |
|:--------------------------------------------------------------|:-----------|:--------------------|:---------------------------------|
| v20_20260122_GMOD_8667Q-Junsun-UI03-car-model-1280x720.tar.xz | Compressed | 1,890,626,284 bytes | a03d85303ee04f50ff878955ea43173f |
| 8667.bin                                                      | Unpacked   | 4,107,700,820 bytes | 5fab73ee0f1282ce2e66ce92f168c049 |

## Creation process for all the firmware releases

  - Files downloaded from the locations listed in the readme sections above

  - The firmware here has all been compressed as follows (example command for release 1):
    ```
    tar -cJf M-series-20240924.tar.xz 8667.bin 8667.upd
    ```

  - The firmware here was uploaded as follows (example command for release 2):
    ```
    GH_DEBUG=api gh release upload \
    Junsun-firmware-v19-unmodified \
    v19_20250414_8667Q-Junsun-UI03-car-model-1280x720.tar.xz \
    -R "phil-gg/vhedia-head-unit" --clobber
    ```

  - Unpack with (example command for release 1):
    ```
    tar -xf M-series-20240924.tar.xz
    ```

  - As is typical for (older) Android firmware packages, `8667.upd` is a text file containing only the md5sum of `8667.bin` (the firmware itself)

  - Load both the upd file and the bin file onto the root of a FAT32 formatted USB drive, and plug into a port on your head unit
      - If the firmware upgrade process does not start automatically, try: -
          - a different USB port on the unit
          - repeatedly tapping on the touch screen with 5 fingers spread out, during a reboot

