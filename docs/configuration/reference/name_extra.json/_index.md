---
linkTitle: name_extra.yml
title: name_extra.yml
weight: 5
---

Certain rom types are typically named in shorthand style (e.g. Arcade/Mame and NeoGeo).

{{< filetree/container >}}
{{< filetree/folder name="my_romset" >}}
{{< filetree/folder name="ARCADE" >}}
{{< filetree/file name="nbajam.zip" >}}
{{< filetree/file name="sfa3.zip" >}}
{{< filetree/file name="wb3.zip" >}}
{{< /filetree/folder >}}
{{< /filetree/folder >}}
{{< /filetree/container >}}

muOS uses a `names.ini` file to convert these into human-readable names and adjust the sort order. By default, most roms
are covered by default, however some roms are not present in the default names.ini.
If any of your roms are missing from this file then the title won't be displayed properly and for certain artwork styles
the artwork will be 'out of order' which will look broken in the end result. This file allows you to add additional roms
to the list to fix these issues. The roms you add are added to the exisiting roms and a new "name.ini" file is created
during generation which needs to be copied onto the device along with generated artwork.

```json {filename="name_extra.json"}
{
  "puyopuya": "Puyo Puyo",
  "punksht2": "Punk Shot",
  "commandu": "Commando"
}
```