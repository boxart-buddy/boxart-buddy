---
linkTitle: Skipped
title: Skipped Roms
weight: 5
---

During the scraping process some roms may not be able to be matched. Typically these will be fan made translations or
rom hacks but may be because some combination of the filename and crc of the rom cannot be matched by the scraper.
Skyscraper already generates log files for these missing files. Boxart-Buddy adds to this in the following ways.

After the scraping process, and missing roms will be combined into a single file inside './skipped' with the following
format:

```json
{
  "romname.zip": {
    "platform": "megadrive",
    "query": "crc="
  },
  "romname2.zip": {
    "platform": "gamegear",
    "query": "crc="
  }
}
```

You can fill this in to provide a 'crc' to 'spoof' for this rom, or change the 'query' string as follows to try and
match on 'name' instead e.g

```json
{
  "Rhythm Heaven Silver (Japan) (Translated).zip": {
    "platform": "gba",
    "query": "crc=349D7025"
  },
  "Go for it! Goemon 3 - The Mecha Leg Hold of Jurokube Shishi (Japan) (Translated).zip": {
    "platform": "snes",
    "query": "romnom=Ganbare Goemon 3"
  },
  "Mystery Dungeon 2 - Shiren the Wanderer (Japan) (Translated).zip": {
    "platform": "snes",
    "query": "romnom=Fushigi No Dungeon 2"
  }
}
```

Once complete you can run a command to parse this file and rescrape these roms, hopefully filling the cache for all your
roms.
To import the file run:

TBC