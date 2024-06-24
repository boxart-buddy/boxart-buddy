---
linkTitle: config.yml
title: config.yml
weight: 1
---

## Minimal Version

```yaml {filename="config.yml"}
rom_folder: '~/roms'
screenscraper_user: 'user'
screenscraper_pass: 'pass'
```

## Full Version

(with all configuration options)

```yaml {filename="config.yml"}
rom_folder: '~/roms'
screenscraper_user: 'user'
screenscraper_pass: 'pass'
skyscraper_config_folder_path: '~/.skyscraper'
romset_name: custom
optimize:
  enabled: true
  convert_to_jpg: false
  jpg_quality: 85
sftp:
  ip: 192.168.1.135
  user: muos
  pass: muos
  port: 2022
preview:
  type: 'both'
  animation_frames: 100
  animation_format: webp
  grid_size: 3
  theme:
    - "GamePal - SnesLight"
    - "GamePal - LCDNight"
    - "GamePal - Sober"
  copy_back: false
```

## Configuration Reference

### General

#### rom_folder

**type:**```string```   **required:** yes

This needs to be set to the absolute path that all of your rom 'subfolders' sit within (
see [Folder Structure](#platform) for more details)

#### screenscraper_user

**type:**```string```   **required:** yes

Your [https://www.screenscraper.fr/](https://www.screenscraper.fr/) username

#### screenscraper_pass

**type:**```string```   **required:** yes

Your [https://www.screenscraper.fr/](https://www.screenscraper.fr/) password

#### skyscraper_config_folder_path

**type:**```string```   **required:** no    **default:** ```'~/.skyscraper'```

This is the location of the main skyscraper configuration folder. Most of the time you **don't** need to set this.

#### romset_name

**type:**```string``` **required:** no **default:** ```'custom'```

The romset name is appended to the packaged folder. It is useful if you have different named romsets that you want to
generate artwork for but don't want the output of one run to overwrite the last one.

### optimize

By default, boxart-buddy will _not_ optimize images, meaning the filesizes of generated files is larger than is ideal.
Adding this configuration will add a pass at the end of the process to losslessly reduce the filesize of generated
files, however this process is **very slow**. You can also use something like https://trimage.org/ (Linux)
or https://imageoptim.com/ (macOS), or if you don't care about file size (maybe you have a large SD card), don't do
anything at all.

#### enabled

**type:**```boolean``` **required:** no **default:** ```false```

Enables the image optimization pass

#### convert_to_jpg

**type:**```boolean``` **required:** no **default:** ```false```

If set to true will optimize to .jpg instead of .png

#### jpg_quality

**type:**```boolean``` **required:** no **default:** ```85```

Only applies if ```convert to jpg``` is true. Sets the quality of jpg images.

### sftp

By adding this configuration you can opt to transfer generated artwork directly to your device, assuming that on device
SFTP is enabled and the device is connected to Wi-fi. This function is SLOW and offers little feedback, I find for large
sets of artwork it fails most of the time. I find it much quicker to manually move the files to the SD card, so I don't
use it.

#### ip

**type:**```string``` **required:** no

The IP address of your device. You can find this on the 'wi-fi' configuration screen.

#### user

**type:**```string``` **required:** no **default:** ```muos```

The SFTP username. Currently only 'muos' will work and that is the default, so no need to set this.

#### pass

**type:**```string``` **required:** no **default:** ```muos```

The SFTP password. Currently only 'muos' will work and that is the default, so no need to set this.

#### pass

**type:**```string``` **required:** no **default:** ```2022```

The SFTP Port. The default of 2022 should be correct.

### preview

This section only applies to artwork creators rather than end users. By default 'preview' genration is turned off. If
turned on then static images or animations will be prduces showing a summary of the output. This is used to populate
previews in the template gallery

#### type

**type:**```string``` **required:** no **default:** ```both```

Can be set to 'animated', 'static', 'both' or 'none'

#### animation_frames

**type:**```string``` **required:** no **default:** ```both```

Can be set to 'animated', 'static', 'both' or 'none'

#### animation_format

**type:**```string``` **required:** no **default:** ```webp```

Changes the output format of generated animation. Can be 'webp', 'apng' or 'webm'. Only applies if generating animation.

#### grid_size

**type:**```integer``` **required:** no **default:** ```100```

The number of frames to include in the animation. Only applies if generating animation.

#### theme

**type:**```string``` **required:** no **multiple:** true

Can set one or more 'Themes' to be used when generating static or animated previes. Each option needs to reference a '
Theme' in the '/themes', either stored a zip file or unzipped into folder. For option a seperate preview will be
generated showing the boxart with the 'default.png' (background) and 'overlay.png' composed into the output (giving an
idea of what the artwork looks like using different themes)

#### copy_back

**type:**```boolean``` **required:** no **default:** ```false```

If this is set then previews that are generated are copied from the 'package' folder back into the 'template/xxx'
directory.