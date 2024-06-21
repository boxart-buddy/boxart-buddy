# Configuration Reference

<!-- TABLE OF CONTENTS -->
<details>
  <ol>
    <li>
      <a href="#general">General Configuration (config.yml)</a>
    </li>
     <li>
      <a href="#platform">Folder Structure (config_platform.yml)</a>
    </li>
    <li>
      <a href="#portmaster">Portmaster Config (config_portmaster.yml)</a>
    </li>
    <li>
      <a href="#folderroms">Folder Roms (folder_roms.yml)</a>
    </li>
    <li>
      <a href="#nameextra">Name Extra (name_extra.json)</a>
    </li>
  </ol>
</details>

## <a name="general"></a> General Configuration (config.yml)

After running 'make bootstrap' there will be a folder in the root of the project called 'user_config' that contains
various files that can be used to affect the way boxart-buddy works. The files themselves contain comments that should
make it straightforward to set things up, however here are some additional notes.

```yaml
rom_folder: '~/roms'
```

This needs to be set to the absolute path that all of your rom 'subfolders' sit within (
see [Folder Structure](#platform) for more details)

```yaml
screenscraper_user: 'user'
screenscraper_pass: 'pass'
```

Your login details for your [https://www.screenscraper.fr/](https://www.screenscraper.fr/). These are required.

```yaml
skyscraper_config_folder_path: '~/.skyscraper'
```

This is the location of the main skyscraper configuration folder. Most of the time you **don't** need to set this. If in
any doubt **don't** set it.

```yaml
romset_name: custom
```

The romset name is appended to the packaged folder. It is useful if you have different named romsets that you want to
generate artwork for but don't want the output of one run to overwrite the last one. You can change this value to run
the same 'build' command but have the artwork output into a different folder within './package/'

```yaml
optimize:
  enabled: true
  convert_to_jpg: false
  jpg_quality: 85
```

By default, boxart-buddy will _not_ optimize images, meaning the filesizes of generated files is larger than is ideal.
Adding this configuration will add a pass at the end of the process to losslessly reduce the filesize of generated
files, however this process is **very slow**. You can also use something like https://trimage.org/ (Linux)
or https://imageoptim.com/ (macOS), or if you don't care about file size (maybe you have a large SD card), don't do
anything at all.

muOS doesn't support .jpg for artwork at the moment so don't bother convert using the 'convert_to_jpg' or 'jpg_quality'
options for the time being.

```yaml
sftp:
  ip: 192.168.1.135
  user: muos
  pass: muos
  port: 2022
```

By adding this configuration you can opt to transfer generated artwork directly to your device, assuming that on device
SFTP is enabled and the device is connected to Wi-fi. This function is SLOW and offers little feedback, I find for large
sets of artwork it fails most of the time. I find it much quicker to manually move the files to the SD card, so I don't
use it.

```yaml
preview:
  type: 'both' # static/animated or both
  animation_frames: 100 # number of frames of folder art in preview gif
  grid_size: 3 # size of the preview grid
```

This doesn't need to be configured either but if you want to change it for whatever reason you can go ahead.

## <a name="platform"></a> Folder Structure (config_platform.yml)

This tool assumes a basic folder structure as follows. You can name your rom folders by anything you like but this tool
makes a few assumptions:

1) Folders of roms only contain roms of the same 'platform'.
2) Each platform has all of its roms in a single folder.
3) Roms sit at the root of the folder (no subfolders)
4) Folders should only contain roms. The code filters our some file types (e.g .txt, .md) but it isn't comprehensive. It
   assumes everything in the folder is something that can be scraped and have artwork generated for it.

Meaning that this tool assumes a simple 1:1 mapping of system and rom type. For example

```console
~/Roms/my_romset
├── ARCADE
│   ├── 1941.zip
│   ├── 1942.zip
│   ├── 1943.zip
├── ATARI
│   ├── Adventure (USA).zip
│   ├── Asteroids (Japan, USA).zip
│   ├── Atlantis (USA).zip
├── GB
│   ├── Adventures of Star Saver, The (USA, Europe).zip
│   ├── Aerostar (USA, Europe).zip
│   ├── Amazing Penguin (USA, Europe).zip
├── GBA
│   ├── Advance Wars (USA) (Rev 1).zip
├── GBC
│   ├── Aliens - Thanatos Encounter (USA, Europe).zip
├── GG
│   ├── Arena (USA, Europe).zip
├── MD
│   ├── Advanced Busterhawk Gleylancer (Japan) (Translated).zip
├── MS
│   ├── Action Fighter (USA, Europe, Brazil) (Rev 1).zip
├── NEOGEO
│   ├── 2020bb.zip
├── PCE
│   ├── 1943 Kai (Japan).zip
├── PCECD
│   ├── Ai Chou Aniki (Japan) (SADS).chd
├── PS
│   ├── Ace Combat 2 (USA).chd
├── SEGACD
│   ├── AH3 - Thunderstrike (USA).chd
└── SFC
    ├── ActRaiser (USA).zip
```

This folder structure needs to be represented in the file './user_config/config_platform.yml'

e.g. the above folder structure would be configured like this:

```yaml
# ./user_config/config_platform.yml

'mame': 'ARCADE'
'atari2600': 'ATARI'
'nes': 'FC'
'gb': 'GB'
'gba': 'GBA'
'gbc': 'GBC'
'gamegear': 'GG'
'megadrive': 'MD'
'mastersystem': 'MS'
'neogeo': 'NEOGEO'
'pcengine': 'PCE'
'pcenginecd': 'PCECD'
'segacd': 'SEGACD'
'snes': 'SFC'
'psx': 'PS'
```

NOTE: 'Portmaster' folder does NOT need to be set here. Leave it out and do not include a 'ports' entry in this file.

## <a name="portmaster"></a> Portmaster

This configuration file is optional, even if you are generating portmaster art it doesn't need to be explicitly
configued.

The default behaviour _without_ setting anything in this file is that portmaster artwork will be generated for _every_
portmaster title which is compatible with RG35XX devices. Most people using portmaster will only have a few titles
installed. You can set an array of port titles in this file which wil restrict art generation to only those titles. e.g.

```yaml
# ./user_config/config_portmaster.yml
[ balatro, stardewvalley, 'duke.nukem.3d', gta3, sonic.mania, 'cave.story' ]
```

## <a name="folderroms"></a> Folder Roms

Some artwork templates will generate 'Folder' art by using as screenshot from one of the roms in your collection. If
this is not configured it will just pick the first rom it finds in the directory. By setting a configuration in this
file you can force such artwork to use a specific rom in your collection instead.

```yaml
# ./user_config/folder_roms.yml

'nes': 'Super Mario Bros. 2 (Japan) (En)'
'mastersystem': 'OutRun (World)'
'atari2600': 'Space Invaders (USA)'
'segacd': 'Snatcher (USA)'
'snes': 'Super Punch-Out!! (USA)'
'psx': 'PaRappa the Rapper (USA) (En,Fr,De,Es,It)'
```

## <a name="nameextra"></a> Name Extra

Certain rom types are typically named in shorthand style (e.g. Arcade/Mame and NeoGeo). muOS uses a '
names.ini/names.json' file to convert these into human-readable names and adjust the sort order. If any of your roms is
missing from this file then the title won't be displayed properly and for certain artwork styles the artwork will be '
out of order' which will look broken in the end result. This file allows you to add additional roms to the list to fix
these issues. The roms you add are added to the exisiting roms and a new "name.ini" file is created which needs to be
copied onto the device along with generated artwork.

/user_config/name_extra.json

```json
{
  "puyopuya": "Puyo Puyo",
  "punksht2": "Punk Shot",
  "commandu": "Commando"
}
```