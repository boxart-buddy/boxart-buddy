---
linkTitle: config_platform.yml
title: config_platform.yml
weight: 2
---

### Folder Structure

This tool assumes a basic folder structure as follows. You can name your rom folders by anything you like but this tool
makes a few assumptions:

1) Folders of roms only contain roms of the same 'platform'.
2) Each platform has all of its roms in a single folder.
3) Roms sit at the root of the folder (no subfolders)

Meaning that this tool assumes a simple 1:1 mapping of system and rom type. For example

{{< filetree/container >}}
{{< filetree/folder name="my_romset" >}}
{{< filetree/folder name="ARCADE" >}}
{{< filetree/file name="1941.zip" >}}
{{< filetree/file name="1942.zip" >}}
{{< filetree/file name="1943.zip" >}}
{{< /filetree/folder >}}

{{< filetree/folder name="ATARI" >}}
{{< filetree/file name="Adventure (USA).zip" >}}
{{< filetree/file name="Asteroids (Japan, USA).zip" >}}
{{< filetree/file name="Atlantis (USA).zip" >}}

{{< /filetree/folder >}}
{{< filetree/folder name="GB" >}}
{{< filetree/file name="Adventures of Star Saver, The (USA, Europe).zip" >}}
{{< filetree/file name="Aerostar (USA, Europe).zip" >}}
{{< filetree/file name="Amazing Penguin (USA, Europe).zip" >}}

{{< /filetree/folder >}}
{{< filetree/folder name="GBA" >}}
{{< filetree/file name="Advance Wars (USA) (Rev 1).zip" >}}

{{< /filetree/folder >}}
{{< filetree/folder name="GBC" >}}
{{< filetree/file name="Aliens - Thanatos Encounter (USA, Europe).zip" >}}

{{< /filetree/folder >}}
{{< filetree/folder name="GG" >}}
{{< filetree/file name="Arena (USA, Europe).zip" >}}

{{< /filetree/folder >}}
{{< filetree/folder name="MD" >}}
{{< filetree/file name="Advanced Busterhawk Gleylancer (Japan) (Translated).zip" >}}

{{< /filetree/folder >}}
{{< filetree/folder name="MS" >}}
{{< filetree/file name="Action Fighter (USA, Europe, Brazil) (Rev 1).zip" >}}

{{< /filetree/folder >}}
{{< filetree/folder name="NEOGEO" >}}
{{< filetree/file name="2020bb.zip" >}}

{{< /filetree/folder >}}
{{< filetree/folder name="PCE" >}}
{{< filetree/file name="1943 Kai (Japan).zip" >}}

{{< /filetree/folder >}}
{{< filetree/folder name="PCECD" >}}
{{< filetree/file name="Ai Chou Aniki (Japan) (SADS).chd" >}}

{{< /filetree/folder >}}
{{< /filetree/folder >}}
{{< /filetree/container >}}

This folder structure needs to be represented in the file './user_config/config_platform.yml'

e.g. the above folder structure would be configured like this:

```yaml {filename="config_platform.yml"}
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
```

{{< callout type="warning" >}}
'Portmaster' folder does NOT need to be set here. Leave it out and do not include a 'ports' entry in this
file.
{{< /callout >}}