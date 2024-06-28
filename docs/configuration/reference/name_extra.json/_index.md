---
linkTitle: name_extra.yml
title: name_extra.yml
weight: 5
---

<br>

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

muOS uses a `name.json` file to convert these into human-readable names and adjust the sort order. The default name.json file contains most roms, but some are missing.
If any of your roms are missing from this file then the title won't be displayed properly and for certain artwork styles
the artwork will be 'out of order' which will look broken in the end result. This file allows you to add additional roms
to the list to fix these issues.

The roms you add to this file are combined/added to the defaults and a new "name.json" file is created
during generation which can be copied onto the device along with generated artwork.

```json {filename="name_extra.json"}
{
  "puyopuya": "Puyo Puyo",
  "punksht2": "Punk Shot",
  "commandu": "Commando"
}
```