-- DO NOT EDIT THIS CODE IT IS GENERATED AUTOMATICALLY
local M = {
    byMuos = {
      ["snk neo geo cd"] = {
        dat = {
          {
            "libretro/metadat/redump",
            "SNK - Neo Geo CD"
          }
        },
        tgdbId = 4956,
        ssId = 70,
        libretroThumbFolder = "SNK - Neo Geo CD",
        extensions = {
          "chd",
          "cue",
          "fba",
          "iso"
        },
        key = "neocd",
        name = "SNK Neo Geo CD",
        muos = "SNK Neo Geo CD"
      },
      amstrad = {
        dat = {
          {
            "libretro/metadat/tosec",
            "Amstrad - GX4000"
          }
        },
        tgdbId = 4999,
        ssParentId = 65,
        extensions = {
          "cpr",
          "bin"
        },
        libretroThumbFolder = "Amstrad - GX4000",
        ssId = 87,
        key = "gx4000",
        name = "Amstrad GX4000",
        muos = "Amstrad"
      },
      ["mattel - intellivision"] = {
        dat = {
          {
            "libretro/metadat/homebrew",
            "Mattel - Intellivision"
          },
          {
            "libretro/metadat/no-intro",
            "Mattel - Intellivision"
          },
          {
            "libretro/metadat/tosec",
            "Mattel - Intellivision"
          }
        },
        tgdbId = 32,
        extensions = {
          "bin",
          "int",
          "itv",
          "rom"
        },
        prefer = {
          "no-intro"
        },
        key = "intv",
        ssId = 115,
        libretroThumbFolder = "Mattel - Intellivision",
        name = "Mattel Intellivision",
        muos = "Mattel - Intellivision"
      },
      ["sega sg-1000"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Sega - SG-1000"
          },
          {
            "libretro/metadat/tosec",
            "Sega - SG-1000"
          }
        },
        tgdbId = 4949,
        ssParentId = 2,
        extensions = {
          "bin",
          "sg"
        },
        libretroThumbFolder = "Sega - SG-1000",
        ssId = 109,
        key = "sg1000",
        name = "SEGA SG-1000",
        muos = "Sega SG-1000"
      },
      ["atari 5200"] = {
        dat = {
          {
            "libretro/metadat/no-intro/",
            "Atari - 5200"
          },
          {
            "libretro/metadat/tosec/",
            "Atari - 5200"
          }
        },
        tgdbId = 26,
        extensions = {
          "a52",
          "atr",
          "atr.gz",
          "bas",
          "bin",
          "car",
          "dcm",
          "xex",
          "xfd",
          "xfd.gz"
        },
        prefer = {
          "no-intro"
        },
        key = "atari5200",
        ssId = 40,
        libretroThumbFolder = "Atari - 5200",
        name = "Atari 5200",
        muos = "Atari 5200"
      },
      ["nintendo ds"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "/Nintendo - Nintendo DSi.dat"
          }
        },
        alternate = {
          "nds"
        },
        extensions = {
          "nds"
        },
        tgdbId = 8,
        libretroThumbFolder = "Nintendo - Nintendo DSi",
        ssId = 15,
        key = "ndsi",
        name = "Nintendo - DSi",
        muos = "Nintendo DS"
      },
      ["snk neo geo"] = {
        dat = {
          {
            "libretro/dat",
            "SNK - Neo Geo.dat"
          }
        },
        tgdbId = 24,
        ssParentId = 75,
        extensions = {
          "chd",
          "cue",
          "fba",
          "iso",
          "zip"
        },
        libretroThumbFolder = "SNK - Neo Geo",
        ssId = 142,
        key = "neogeo",
        name = "SNK Neo Geo",
        muos = "SNK Neo Geo"
      },
      ["sega dreamcast"] = {
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Dreamcast"
          },
          {
            "libretro/metadat/homebrew",
            "Sega - Dreamcast"
          }
        },
        tgdbId = 16,
        extensions = {
          "cdi",
          "chd",
          "cue",
          "gdi",
          "iso",
          "m3u"
        },
        prefer = {
          "redump"
        },
        key = "dreamcast",
        ssId = 23,
        libretroThumbFolder = "Sega - Dreamcast",
        name = "SEGA Dreamcast",
        muos = "Sega Dreamcast"
      },
      ["philips cdi"] = {
        dat = {
          {
            "libretro/metadat/redump",
            "Philips - CD-i"
          }
        },
        tgdbId = 4917,
        ssId = 133,
        libretroThumbFolder = "Philips - CD-i",
        extensions = {
          "chd"
        },
        key = "cdi",
        name = "Philips CD-i",
        muos = "Philips CDi"
      },
      ["nec pc engine supergrafx"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "NEC - PC Engine SuperGrafx"
          }
        },
        ssParentId = 31,
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        libretroThumbFolder = "NEC - PC Engine SuperGrafx",
        ssId = 105,
        key = "pces",
        name = "PC Engine SuperGrafx",
        muos = "NEC PC Engine SuperGrafx"
      },
      ["sony playstation portable"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Sony - PlayStation Portable (PSN)"
          },
          {
            "libretro/metadat/no-intro",
            "Sony - PlayStation Portable (PSX2PSP)"
          },
          {
            "libretro/metadat/no-intro",
            "Sony - PlayStation Portable (UMD Music)"
          },
          {
            "libretro/metadat/no-intro",
            "Sony - PlayStation Portable (UMD Video)"
          }
        },
        tgdbId = 13,
        ssId = 61,
        libretroThumbFolder = "Sony - PlayStation Portable",
        extensions = {
          "chd",
          "cso",
          "iso",
          "pbp"
        },
        key = "psp",
        name = "Sony PlayStation Portable",
        muos = "Sony Playstation Portable"
      },
      ["atari jaguar"] = {
        dat = {
          {
            "libretro/metadat/magazine/edge/",
            "Atari - Jaguar"
          },
          {
            "libretro/metadat/no-intro",
            "Atari - Jaguar"
          },
          {
            "libretro/metadat/tosec",
            "Atari - Jaguar"
          }
        },
        tgdbId = 28,
        extensions = {
          "chd",
          "cue",
          "j64",
          "jag"
        },
        prefer = {
          "no-intro"
        },
        key = "jaguar",
        ssId = 27,
        libretroThumbFolder = "Atari - Jaguar",
        name = "Atari Jaguar",
        muos = "Atari Jaguar"
      },
      ["sinclair zx 81"] = {
        dat = {
          {
            "libretro/dat",
            "Sinclair - ZX 81"
          }
        },
        tgdbId = 5010,
        ssId = 77,
        libretroThumbFolder = "Sinclair - ZX 81",
        extensions = {
          "p",
          "t81",
          "tzx"
        },
        key = "zx81",
        name = "Sinclair ZX81",
        muos = "Sinclair ZX 81"
      },
      ["commodore amiga"] = {
        dat = {
          {
            "libretro/metadat/no-intro/",
            "Commodore - Amiga"
          },
          {
            "libretro/metadat/tosec/",
            "Commodore - Amiga"
          },
          {
            "libretro/dat/",
            "Commodore - Amiga"
          },
          {
            "whdload/",
            "Commodore - Amiga"
          }
        },
        tgdbId = 4911,
        extensions = {
          "adf",
          "adz",
          "chd",
          "cue",
          "dms",
          "hdf",
          "img",
          "ipf",
          "iso",
          "lha",
          "m3u",
          "rp9",
          "uae"
        },
        prefer = {
          "whdload",
          "libretro-dats",
          "no-intro"
        },
        key = "amiga",
        ssId = 64,
        libretroThumbFolder = "Commodore - Amiga",
        name = "Commodore Amiga",
        muos = "Commodore Amiga"
      },
      ["tic-80"] = {
        dat = {
          {
            "libretro/dat",
            "TIC-80"
          }
        },
        ssId = 222,
        libretroThumbFolder = "TIC-80",
        extensions = {
          "tic"
        },
        key = "tic80",
        name = "TIC-80 Tiny Computer",
        muos = "TIC-80"
      },
      arcade = {
        dat = {
          {
            "libretro/metadat/fbneo-split/",
            "FBNeo - Arcade Games"
          },
          {
            "no-intro/Non-Redump/fbneo-split/",
            "Non-Redump - Capcom - Play System"
          }
        },
        alternate = {
          "arcade"
        },
        extensions = {
          "bin",
          "cue",
          "dat",
          "fba",
          "iso",
          "zip"
        },
        tgdbId = 23,
        libretroThumbFolder = "FBNeo - Arcade Games",
        ssId = 75,
        key = "fbneo",
        name = "Arcade (FB NEO)",
        muos = "Arcade"
      },
      ["commodore c64"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Commodore - 64"
          }
        },
        tgdbId = 40,
        ssId = 66,
        libretroThumbFolder = "Commodore - 64",
        extensions = {
          "cmd",
          "crt",
          "d64",
          "d71",
          "d80",
          "d81",
          "g64",
          "m3u",
          "prg",
          "t64",
          "tap",
          "vsf",
          "x64"
        },
        key = "c64",
        name = "Commodore 64",
        muos = "Commodore C64"
      },
      ["sinclair zx spectrum"] = {
        dat = {
          {
            "libretro/dat",
            "Sinclair - ZX Spectrum"
          },
          {
            "libretro/metadat/tosec",
            "Sinclair - ZX Spectrum.dat"
          },
          {
            "libretro/metadat/no-intro",
            "Sinclair - ZX Spectrum +3"
          }
        },
        tgdbId = 4913,
        ssId = 76,
        libretroThumbFolder = "Sinclair - ZX Spectrum",
        extensions = {
          "dsk",
          "gz",
          "img",
          "mgt",
          "rzx",
          "scl",
          "sna",
          "szx",
          "tap",
          "trd",
          "tzx",
          "udi",
          "z80"
        },
        key = "spectrum",
        name = "ZX Spectrum",
        muos = "Sinclair ZX Spectrum"
      },
      openbor = {
        ssId = 214,
        key = "openbor",
        muos = "OpenBOR",
        name = "OpenBOR",
        extensions = {
          "bor",
          "pak"
        }
      },
      ["java j2me"] = {
        muos = "Java J2ME",
        tgdbId = 5018,
        name = "Java J2ME-Platform",
        key = "j2me"
      },
      naomi = {
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi.dat"
          }
        },
        alternate = {
          "naomi2"
        },
        ssParentId = 75,
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        libretroThumbFolder = "Sega - Naomi",
        ssId = 56,
        key = "naomi",
        name = "SEGA Naomi",
        muos = "Naomi"
      },
      ["sharp x1"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Sharp - X1"
          },
          {
            "libretro/metadat/tosec",
            "Sharp - X1"
          }
        },
        tgdbId = 4977,
        extensions = {
          "2d",
          "2hd",
          "88d",
          "cmd",
          "d88",
          "dup",
          "dx1",
          "hdm",
          "tfd",
          "xdf"
        },
        prefer = {
          "no-intro"
        },
        key = "x1",
        ssId = 220,
        libretroThumbFolder = "Sharp - X1",
        name = "Sharp X1",
        muos = "Sharp X1"
      },
      ["naomi 2"] = {
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi 2.dat"
          }
        },
        alternate = {
          "naomi"
        },
        ssParentId = 75,
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        libretroThumbFolder = "Sega - Naomi 2",
        ssId = 230,
        key = "naomi2",
        name = "SEGA Naomi 2",
        muos = "Naomi 2"
      },
      ["snk neo geo pocket - color"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "SNK - Neo Geo Pocket Color.dat"
          }
        },
        alternate = {
          "ngpc"
        },
        extensions = {
          "ngc"
        },
        tgdbId = 4923,
        libretroThumbFolder = "SNK - Neo Geo Pocket Color",
        ssId = 82,
        key = "ngpc",
        name = "Neo Geo Pocket Color",
        muos = "SNK Neo Geo Pocket - Color"
      },
      ["bandai wonderswan"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Bandai - WonderSwan Color"
          },
          {
            "libretro/metadat/hacks",
            "Bandai - WonderSwan Color"
          }
        },
        tgdbId = 4926,
        ssParentId = 45,
        extensions = {
          "wsc"
        },
        libretroThumbFolder = "Bandai - WonderSwan Color",
        ssId = 46,
        key = "wsc",
        name = "WonderSwan Color",
        muos = "Bandai WonderSwan"
      },
      ["nintendo n64"] = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Nintendo - Nintendo 64"
          },
          {
            "libretro/metadat/magazine/edge",
            "Nintendo - Nintendo 64"
          },
          {
            "libretro/metadat/magazine/famitsu",
            "Nintendo - Nintendo 64"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Nintendo 64"
          }
        },
        tgdbId = 3,
        extensions = {
          "n64",
          "v64",
          "z64"
        },
        prefer = {
          "no-intro"
        },
        key = "n64",
        ssId = 14,
        libretroThumbFolder = "Nintendo - Nintendo 64",
        name = "Nintendo - 64",
        muos = "Nintendo N64"
      },
      ["nintendo virtual boy"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Nintendo - Virtual Boy"
          }
        },
        tgdbId = 4918,
        ssId = 11,
        libretroThumbFolder = "Nintendo - Virtual Boy",
        extensions = {
          "vb"
        },
        key = "vb",
        name = "Nintendo - Virtual Boy",
        muos = "Nintendo Virtual Boy"
      },
      ["atari 7800"] = {
        dat = {
          {
            "libretro/metadat/no-intro/",
            "Atari - 7800"
          },
          {
            "libretro/metadat/tosec/",
            "Atari - 7800"
          },
          {
            "libretro/metadat/headered/",
            "Atari - 7800"
          }
        },
        tgdbId = 27,
        extensions = {
          "a78",
          "bin"
        },
        prefer = {
          "no-intro",
          "headered"
        },
        key = "atari7800",
        ssId = 41,
        libretroThumbFolder = "Atari - 7800",
        name = "Atari 7800",
        muos = "Atari 7800"
      },
      scummvm = {
        dat = {
          {
            "libretro/dat",
            "ScummVM"
          },
          {
            "libretro/metadat/magazine/edge",
            "ScummVM"
          }
        },
        ssParentId = 135,
        extensions = {
          "scummvm",
          "svm"
        },
        libretroThumbFolder = "ScummVM",
        ssId = 123,
        key = "scummvm",
        name = "ScummVM",
        muos = "ScummVM"
      },
      ["nintendo snes - sfc"] = {
        dat = {
          {
            "libretro/dat",
            "Nintendo - Super Nintendo Entertainment System"
          },
          {
            "libretro/metadat/hacks",
            "Nintendo - Super Nintendo Entertainment System"
          },
          {
            "libretro/metadat/homebrew",
            "Nintendo - Super Nintendo Entertainment System"
          },
          {
            "libretro/metadat/libretro-dats",
            "Nintendo - Super Nintendo Entertainment System"
          },
          {
            "libretro/metadat/magazine/edge",
            "Nintendo - Super Nintendo Entertainment System"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Super Nintendo Entertainment System"
          },
          {
            "libretro/metadat/tosec",
            "Nintendo - Super Nintendo Entertainment System"
          }
        },
        tgdbId = 6,
        ssId = 4,
        libretroThumbFolder = "Nintendo - Super Nintendo Entertainment System",
        extensions = {
          "bin",
          "bs",
          "fig",
          "mgd",
          "sfc",
          "smc",
          "swc"
        },
        key = "snes",
        name = "Nintendo - SNES",
        muos = "Nintendo SNES - SFC"
      },
      ["sega master system"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Sega - Master System - Mark III"
          }
        },
        tgdbId = 35,
        ssId = 2,
        libretroThumbFolder = "Sega - Master System - Mark III",
        extensions = {
          "bin",
          "sms"
        },
        key = "sms",
        name = "SEGA Master System",
        muos = "Sega Master System"
      },
      ["nec pc engine"] = {
        dat = {
          {
            "libretro/metadat/hacks",
            "NEC - PC Engine - TurboGrafx 16"
          },
          {
            "libretro/metadat/no-intro",
            "NEC - PC Engine - TurboGrafx 16"
          }
        },
        tgdbId = 34,
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        prefer = {
          "no-intro"
        },
        key = "pce",
        ssId = 31,
        libretroThumbFolder = "NEC - PC Engine - TurboGrafx 16",
        name = "PC Engine",
        muos = "NEC PC Engine"
      },
      ["odyssey2 - videopac"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Magnavox - Odyssey2.dat"
          }
        },
        tgdbId = {
          4961,
          4927
        },
        ssId = 104,
        libretroThumbFolder = "Magnavox - Odyssey2",
        extensions = {
          "bin"
        },
        key = "odyssey2",
        name = "Magnavox Odyssey - Videopac",
        muos = "Odyssey2 - VideoPac"
      },
      ["sega mega cd - sega cd"] = {
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Mega-CD - Sega CD"
          }
        },
        tgdbId = 21,
        ssId = 20,
        libretroThumbFolder = "Sega - Mega-CD - Sega CD",
        extensions = {
          "chd",
          "cue",
          "iso",
          "m3u"
        },
        key = "mdcd",
        name = "SEGA Mega-CD",
        muos = "Sega Mega CD - Sega CD"
      },
      ["sony playstation"] = {
        dat = {
          {
            "libretro/metadat/redump",
            "Sony - PlayStation.dat"
          },
          {
            "libretro/metadat/hacks",
            "Sony - PlayStation.dat"
          },
          {
            "libretro/metadat/magazine/edge",
            "Sony - PlayStation.dat"
          }
        },
        tgdbId = 10,
        extensions = {
          "cbn",
          "chd",
          "cue",
          "img",
          "iso",
          "m3u",
          "mdf",
          "pbp",
          "toc",
          "z",
          "znx"
        },
        prefer = {
          "redump"
        },
        key = "psx",
        ssId = 57,
        libretroThumbFolder = "Sony - PlayStation",
        name = "Sony PlayStation",
        muos = "Sony PlayStation"
      },
      ["nintendo pokemon mini"] = {
        dat = {
          {
            "libretro/metadat/homebrew",
            "Nintendo - Pokemon Mini.dat"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Pokemon Mini.dat"
          }
        },
        tgdbId = 4957,
        ssId = 211,
        libretroThumbFolder = "Nintendo - Pokemon Mini",
        extensions = {
          "min"
        },
        key = "pokemini",
        name = "Nintendo - Pokemon Mini",
        muos = "Nintendo Pokemon Mini"
      },
      arduboy = {
        dat = {
          {
            "libretro/metadat/no-intro/",
            "Arduboy Inc - Arduboy"
          },
          {
            "libretro/dat/",
            "Arduboy Inc - Arduboy"
          }
        },
        extensions = {
          "hex",
          "arduboy"
        },
        prefer = {
          "libretro-dats"
        },
        key = "arduboy",
        ssId = 263,
        libretroThumbFolder = "Arduboy Inc - Arduboy",
        name = "Arduboy",
        muos = "Arduboy"
      },
      ["nintendo game boy"] = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Nintendo - Game Boy.dat"
          },
          {
            "libretro/metadat/homebrew",
            "Nintendo - Game Boy.dat"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Game Boy.dat"
          },
          {
            "libretro/metadat/tosec",
            "Nintendo - Game Boy.dat"
          }
        },
        tgdbId = 4,
        extensions = {
          "gb"
        },
        prefer = {
          "no-intro"
        },
        key = "gb",
        ssId = 9,
        libretroThumbFolder = "Nintendo - Game Boy",
        name = "Nintendo - Gameboy",
        muos = "Nintendo Game Boy"
      },
      ["nintendo game boy advance"] = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Nintendo - Game Boy Advance"
          },
          {
            "libretro/metadat/homebrew",
            "Nintendo - Game Boy Advance"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Game Boy Advance"
          },
          {
            "libretro/metadat/tosec",
            "Nintendo - Game Boy Advance"
          }
        },
        tgdbId = 5,
        extensions = {
          "gba"
        },
        prefer = {
          "no-intro"
        },
        key = "gba",
        ssId = 12,
        libretroThumbFolder = "Nintendo - Game Boy Advance",
        name = "Nintendo - Game Boy Advance",
        muos = "Nintendo Game Boy Advance"
      },
      ["sega game gear"] = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Sega - Game Gear"
          },
          {
            "libretro/metadat/no-intro",
            "Sega - Game Gear"
          },
          {
            "libretro/metadat/tosec",
            "Sega - Game Gear"
          }
        },
        tgdbId = 20,
        extensions = {
          "bin",
          "gg",
          "sms"
        },
        prefer = {
          "no-intro"
        },
        key = "gg",
        ssId = 21,
        libretroThumbFolder = "Sega - Game Gear",
        name = "SEGA Game Gear",
        muos = "Sega Game Gear"
      },
      ["nec pc engine cd"] = {
        dat = {
          {
            "libretro/metadat/redump",
            "NEC - PC Engine CD - TurboGrafx-CD"
          }
        },
        tgdbId = 4955,
        ssParentId = 31,
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        libretroThumbFolder = "NEC - PC Engine CD - TurboGrafx-CD",
        ssId = 114,
        key = "pcecd",
        name = "PC Engine CD-ROM²",
        muos = "NEC PC Engine CD"
      },
      ["nintendo game boy color"] = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Nintendo - Game Boy Color"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Game Boy Color"
          },
          {
            "libretro/metadat/tosec",
            "Nintendo - Game Boy Color"
          }
        },
        tgdbId = 41,
        ssParentId = 9,
        extensions = {
          "gbc",
          "gb"
        },
        prefer = {
          "no-intro"
        },
        key = "gbc",
        ssId = 10,
        libretroThumbFolder = "Nintendo - Game Boy Color",
        name = "Nintendo - Game Boy Color",
        muos = "Nintendo Game Boy Color"
      },
      ["atari 2600"] = {
        dat = {
          {
            "libretro/metadat/no-intro/",
            "Atari - 2600"
          },
          {
            "libretro/metadat/tosec/",
            "Atari - 2600"
          }
        },
        tgdbId = 22,
        extensions = {
          "a26",
          "bin",
          "gz",
          "rom"
        },
        prefer = {
          "no-intro"
        },
        key = "atari2600",
        ssId = 26,
        libretroThumbFolder = "Atari - 2600",
        name = "Atari 2600",
        muos = "Atari 2600"
      },
      ["mega duck - cougar boy"] = {
        ssId = 90,
        tgdbId = 4948,
        key = "megaduck",
        muos = "Mega Duck - Cougar Boy",
        name = "Mega Duck",
        extensions = {
          "bin"
        }
      },
      ["microsoft - msx"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX2.dat"
          }
        },
        alternate = {
          "msx"
        },
        ssParentId = 113,
        extensions = {
          "col",
          "dsk",
          "mx1",
          "mx2",
          "rom"
        },
        tgdbId = 4929,
        libretroThumbFolder = "Microsoft - MSX2",
        ssId = 116,
        key = "msx2",
        name = "MSX2 Computer",
        muos = "Microsoft - MSX"
      },
      ["sega mega drive - genesis"] = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Sega - Mega Drive - Genesis"
          },
          {
            "libretro/metadat/homebrew",
            "Sega - Mega Drive - Genesis"
          },
          {
            "libretro/metadat/no-intro",
            "Sega - Mega Drive - Genesis"
          },
          {
            "libretro/metadat/tosec",
            "Sega - Mega Drive - Genesis"
          }
        },
        tgdbId = {
          36,
          18
        },
        extensions = {
          "bin",
          "gen",
          "md",
          "sg",
          "smd"
        },
        prefer = {
          "no-intro"
        },
        key = "md",
        ssId = 1,
        libretroThumbFolder = "Sega - Mega Drive - Genesis",
        name = "SEGA Megadrive",
        muos = "Sega Mega Drive - Genesis"
      },
      ["sega 32x"] = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Sega - 32X"
          },
          {
            "libretro/metadat/no-intro",
            "Sega - 32X"
          },
          {
            "libretro/metadat/tosec",
            "Sega - 32X"
          }
        },
        tgdbId = 33,
        ssParentId = 1,
        extensions = {
          "32x",
          "bin",
          "md",
          "smd"
        },
        prefer = {
          "no-intro"
        },
        key = "sega32x",
        ssId = 19,
        libretroThumbFolder = "Sega - 32X",
        name = "SEGA 32X",
        muos = "Sega 32X"
      },
      ["sega saturn"] = {
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Saturn"
          }
        },
        tgdbId = 17,
        ssId = 22,
        libretroThumbFolder = "Sega - Saturn",
        extensions = {
          "chd",
          "cue",
          "iso",
          "m3u",
          "mdf"
        },
        key = "saturn",
        name = "SEGA Saturn",
        muos = "Sega Saturn"
      },
      ["nintendo nes - famicom"] = {
        dat = {
          {
            "libretro/dat",
            "Nintendo - Nintendo Entertainment System"
          },
          {
            "libretro/metadat/hacks",
            "Nintendo - Nintendo Entertainment System"
          },
          {
            "libretro/metadat/headered",
            "Nintendo - Nintendo Entertainment System"
          },
          {
            "libretro/metadat/homebrew",
            "Nintendo - Nintendo Entertainment System"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Nintendo Entertainment System"
          },
          {
            "libretro/metadat/tosec",
            "Nintendo - Nintendo Entertainment System"
          }
        },
        tgdbId = 7,
        extensions = {
          "fig",
          "mgd",
          "nes",
          "sfc",
          "smc",
          "swc"
        },
        prefer = {
          "no-intro",
          "libretro-dats"
        },
        key = "nes",
        ssId = 3,
        libretroThumbFolder = "Nintendo - Nintendo Entertainment System",
        name = "Nintendo - Entertainment System",
        muos = "Nintendo NES - Famicom"
      },
      ["sega atomiswave naomi"] = {
        dat = {
          {
            "libretro/dat",
            "Atomiswave"
          }
        },
        alternate = {
          "arcade",
          "fbneo",
          "naomi"
        },
        ssParentId = 75,
        extensions = {
          "bin",
          "chd",
          "dat",
          "zip"
        },
        libretroThumbFolder = "Atomiswave",
        ssId = 53,
        key = "atomiswave",
        name = "Atomiswave",
        muos = "Sega Atomiswave Naomi"
      },
      ["sharp x68000"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Sharp - X68000"
          },
          {
            "libretro/metadat/tosec",
            "Sharp - X68000"
          }
        },
        tgdbId = 4931,
        extensions = {
          "2hd",
          "d88",
          "dim",
          "hdf",
          "hdm",
          "m3u",
          "xdf"
        },
        prefer = {
          "no-intro"
        },
        key = "x68000",
        ssId = 79,
        libretroThumbFolder = "Sharp - X68000",
        name = "Sharp X68000",
        muos = "Sharp X68000"
      },
      ["gce-vectrex"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "GCE - Vectrex"
          }
        },
        tgdbId = 4939,
        ssId = 102,
        libretroThumbFolder = "GCE - Vectrex",
        extensions = {
          "bin",
          "gam",
          "vec"
        },
        key = "vectrex",
        name = "GCE Vectrex",
        muos = "GCE-Vectrex"
      },
      ["fairchild channelf"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Fairchild - Channel F"
          }
        },
        tgdbId = 4928,
        ssId = 80,
        libretroThumbFolder = "Fairchild - Channel F",
        extensions = {
          "bin",
          "rom"
        },
        key = "channelf",
        name = "Fairchild ChannelF",
        muos = "Fairchild ChannelF"
      },
      ["watara supervision"] = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Watara - Supervision"
          }
        },
        tgdbId = 4959,
        ssId = 207,
        libretroThumbFolder = "Watara - Supervision",
        extensions = {
          "bin",
          "sv"
        },
        key = "supervision",
        name = "Watara Supervision",
        muos = "Watara Supervision"
      },
      ["nintendo fds"] = {
        dat = {
          {
            "libretro/metadat/libretro-dats",
            "Nintendo - Family Computer Disk System"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Family Computer Disk System"
          }
        },
        tgdbId = 4936,
        ssParentId = 3,
        extensions = {
          "fds",
          "nes"
        },
        libretroThumbFolder = "Nintendo - Family Computer Disk System",
        ssId = 106,
        key = "fds",
        name = "Nintendo - Famicom Disk System",
        muos = "Nintendo FDS"
      },
      ["atari lynx"] = {
        dat = {
          {
            "libretro/metadat/headered",
            "Atari - Lynx"
          },
          {
            "libretro/metadat/no-intro",
            "Atari - Lynx"
          },
          {
            "libretro/metadat/tosec",
            "Atari - Lynx"
          }
        },
        tgdbId = 4924,
        extensions = {
          "lnx"
        },
        prefer = {
          "no-intro"
        },
        key = "lynx",
        ssId = 28,
        libretroThumbFolder = "Atari - Lynx",
        name = "Atari Lynx",
        muos = "Atari Lynx"
      },
      ["the 3do company - 3do"] = {
        dat = {
          {
            "libretro/metadat/redump/",
            "The 3DO Company"
          }
        },
        tgdbId = 25,
        ssId = 29,
        libretroThumbFolder = "The 3DO Company - 3DO",
        extensions = {
          "chd",
          "cue",
          "iso"
        },
        key = "3do",
        name = "Panasonic 3DO",
        muos = "The 3DO Company - 3DO"
      },
      ["pico-8"] = {
        dat = {
          {
            "libretro/dat",
            "PICO-8"
          }
        },
        ssParentId = 234,
        key = "pico8",
        extensions = {
          "p8",
          "png"
        },
        name = "Pico-8",
        muos = "PICO-8"
      },
      ["handheld electronic - game and watch"] = {
        dat = {
          {
            "no-intro/No-Intro",
            "Nintendo - Game & Watch"
          }
        },
        tgdbId = 4950,
        key = "gw",
        ssId = 52,
        extensions = {
          "mgw"
        },
        name = "Nintendo - Game & Watch",
        muos = "Handheld Electronic - Game and Watch"
      }
    },
    byKey = {
      j2me = {
        muos = "Java J2ME",
        tgdbId = 5018,
        name = "Java J2ME-Platform",
        key = "j2me"
      },
      supervision = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Watara - Supervision"
          }
        },
        tgdbId = 4959,
        ssId = 207,
        libretroThumbFolder = "Watara - Supervision",
        extensions = {
          "bin",
          "sv"
        },
        key = "supervision",
        name = "Watara Supervision",
        muos = "Watara Supervision"
      },
      amiga = {
        dat = {
          {
            "libretro/metadat/no-intro/",
            "Commodore - Amiga"
          },
          {
            "libretro/metadat/tosec/",
            "Commodore - Amiga"
          },
          {
            "libretro/dat/",
            "Commodore - Amiga"
          },
          {
            "whdload/",
            "Commodore - Amiga"
          }
        },
        tgdbId = 4911,
        extensions = {
          "adf",
          "adz",
          "chd",
          "cue",
          "dms",
          "hdf",
          "img",
          "ipf",
          "iso",
          "lha",
          "m3u",
          "rp9",
          "uae"
        },
        prefer = {
          "whdload",
          "libretro-dats",
          "no-intro"
        },
        key = "amiga",
        ssId = 64,
        libretroThumbFolder = "Commodore - Amiga",
        name = "Commodore Amiga",
        muos = "Commodore Amiga"
      },
      lynx = {
        dat = {
          {
            "libretro/metadat/headered",
            "Atari - Lynx"
          },
          {
            "libretro/metadat/no-intro",
            "Atari - Lynx"
          },
          {
            "libretro/metadat/tosec",
            "Atari - Lynx"
          }
        },
        tgdbId = 4924,
        extensions = {
          "lnx"
        },
        prefer = {
          "no-intro"
        },
        key = "lynx",
        ssId = 28,
        libretroThumbFolder = "Atari - Lynx",
        name = "Atari Lynx",
        muos = "Atari Lynx"
      },
      tic80 = {
        dat = {
          {
            "libretro/dat",
            "TIC-80"
          }
        },
        ssId = 222,
        libretroThumbFolder = "TIC-80",
        extensions = {
          "tic"
        },
        key = "tic80",
        name = "TIC-80 Tiny Computer",
        muos = "TIC-80"
      },
      md = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Sega - Mega Drive - Genesis"
          },
          {
            "libretro/metadat/homebrew",
            "Sega - Mega Drive - Genesis"
          },
          {
            "libretro/metadat/no-intro",
            "Sega - Mega Drive - Genesis"
          },
          {
            "libretro/metadat/tosec",
            "Sega - Mega Drive - Genesis"
          }
        },
        tgdbId = {
          36,
          18
        },
        extensions = {
          "bin",
          "gen",
          "md",
          "sg",
          "smd"
        },
        prefer = {
          "no-intro"
        },
        key = "md",
        ssId = 1,
        libretroThumbFolder = "Sega - Mega Drive - Genesis",
        name = "SEGA Megadrive",
        muos = "Sega Mega Drive - Genesis"
      },
      vb = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Nintendo - Virtual Boy"
          }
        },
        tgdbId = 4918,
        ssId = 11,
        libretroThumbFolder = "Nintendo - Virtual Boy",
        extensions = {
          "vb"
        },
        key = "vb",
        name = "Nintendo - Virtual Boy",
        muos = "Nintendo Virtual Boy"
      },
      vectrex = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "GCE - Vectrex"
          }
        },
        tgdbId = 4939,
        ssId = 102,
        libretroThumbFolder = "GCE - Vectrex",
        extensions = {
          "bin",
          "gam",
          "vec"
        },
        key = "vectrex",
        name = "GCE Vectrex",
        muos = "GCE-Vectrex"
      },
      arcade = {
        dat = {
          {
            "libretro/metadat/mame/",
            "MAME 2000 BIOS"
          },
          {
            "libretro/metadat/mame/",
            "MAME BIOS"
          },
          {
            "libretro/metadat/mame/",
            "MAME.dat"
          },
          {
            "libretro/metadat/mame-member/",
            "MAME"
          },
          {
            "libretro/metadat/mame-nonmerged/",
            "MAME 2000"
          },
          {
            "libretro/metadat/mame-nonmerged/",
            "MAME 2003-Plus.dat"
          },
          {
            "libretro/metadat/mame-nonmerged/",
            "MAME 2003"
          },
          {
            "libretro/metadat/mame-nonmerged/",
            "MAME 2010"
          },
          {
            "libretro/metadat/mame-nonmerged/",
            "MAME 2015"
          },
          {
            "libretro/metadat/mame-nonmerged/",
            "MAME 2016"
          },
          {
            "libretro/metadat/mame-split/",
            "MAME 2000"
          },
          {
            "libretro/metadat/mame-split/",
            "MAME 2003"
          },
          {
            "libretro/metadat/mame-split/",
            "MAME 2010"
          },
          {
            "libretro/metadat/mame-split/",
            "MAME 2015"
          }
        },
        alternate = {
          "fbneo"
        },
        ssId = 75,
        libretroThumbFolder = "MAME",
        extensions = {
          "bin",
          "cue",
          "dat",
          "fba",
          "iso",
          "zip"
        },
        key = "arcade",
        name = "Arcade",
        muos = "Arcade"
      },
      mdcd = {
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Mega-CD - Sega CD"
          }
        },
        tgdbId = 21,
        ssId = 20,
        libretroThumbFolder = "Sega - Mega-CD - Sega CD",
        extensions = {
          "chd",
          "cue",
          "iso",
          "m3u"
        },
        key = "mdcd",
        name = "SEGA Mega-CD",
        muos = "Sega Mega CD - Sega CD"
      },
      ws = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Bandai - WonderSwan.dat"
          },
          {
            "libretro/metadat/hacks",
            "Bandai - WonderSwan.dat"
          }
        },
        tgdbId = 4925,
        ssId = 45,
        libretroThumbFolder = "Bandai - WonderSwan",
        extensions = {
          "ws"
        },
        key = "ws",
        name = "WonderSwan",
        muos = "Bandai WonderSwan"
      },
      megaduck = {
        ssId = 90,
        tgdbId = 4948,
        key = "megaduck",
        muos = "Mega Duck - Cougar Boy",
        name = "Mega Duck",
        extensions = {
          "bin"
        }
      },
      msx = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX.dat"
          }
        },
        alternate = {
          "msx2"
        },
        extensions = {
          "cas",
          "col",
          "dsk",
          "m3u",
          "mx1",
          "mx2",
          "rom"
        },
        tgdbId = 4929,
        libretroThumbFolder = "Microsoft - MSX",
        ssId = 113,
        key = "msx",
        name = "MSX Computer",
        muos = "Microsoft - MSX"
      },
      wsc = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Bandai - WonderSwan Color"
          },
          {
            "libretro/metadat/hacks",
            "Bandai - WonderSwan Color"
          }
        },
        tgdbId = 4926,
        ssParentId = 45,
        extensions = {
          "wsc"
        },
        libretroThumbFolder = "Bandai - WonderSwan Color",
        ssId = 46,
        key = "wsc",
        name = "WonderSwan Color",
        muos = "Bandai WonderSwan"
      },
      msx2 = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX2.dat"
          }
        },
        alternate = {
          "msx"
        },
        ssParentId = 113,
        extensions = {
          "col",
          "dsk",
          "mx1",
          "mx2",
          "rom"
        },
        tgdbId = 4929,
        libretroThumbFolder = "Microsoft - MSX2",
        ssId = 116,
        key = "msx2",
        name = "MSX2 Computer",
        muos = "Microsoft - MSX"
      },
      fbneo = {
        dat = {
          {
            "libretro/metadat/fbneo-split/",
            "FBNeo - Arcade Games"
          },
          {
            "no-intro/Non-Redump/fbneo-split/",
            "Non-Redump - Capcom - Play System"
          }
        },
        alternate = {
          "arcade"
        },
        extensions = {
          "bin",
          "cue",
          "dat",
          "fba",
          "iso",
          "zip"
        },
        tgdbId = 23,
        libretroThumbFolder = "FBNeo - Arcade Games",
        ssId = 75,
        key = "fbneo",
        name = "Arcade (FB NEO)",
        muos = "Arcade"
      },
      n64 = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Nintendo - Nintendo 64"
          },
          {
            "libretro/metadat/magazine/edge",
            "Nintendo - Nintendo 64"
          },
          {
            "libretro/metadat/magazine/famitsu",
            "Nintendo - Nintendo 64"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Nintendo 64"
          }
        },
        tgdbId = 3,
        extensions = {
          "n64",
          "v64",
          "z64"
        },
        prefer = {
          "no-intro"
        },
        key = "n64",
        ssId = 14,
        libretroThumbFolder = "Nintendo - Nintendo 64",
        name = "Nintendo - 64",
        muos = "Nintendo N64"
      },
      x68000 = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Sharp - X68000"
          },
          {
            "libretro/metadat/tosec",
            "Sharp - X68000"
          }
        },
        tgdbId = 4931,
        extensions = {
          "2hd",
          "d88",
          "dim",
          "hdf",
          "hdm",
          "m3u",
          "xdf"
        },
        prefer = {
          "no-intro"
        },
        key = "x68000",
        ssId = 79,
        libretroThumbFolder = "Sharp - X68000",
        name = "Sharp X68000",
        muos = "Sharp X68000"
      },
      arduboy = {
        dat = {
          {
            "libretro/metadat/no-intro/",
            "Arduboy Inc - Arduboy"
          },
          {
            "libretro/dat/",
            "Arduboy Inc - Arduboy"
          }
        },
        extensions = {
          "hex",
          "arduboy"
        },
        prefer = {
          "libretro-dats"
        },
        key = "arduboy",
        ssId = 263,
        libretroThumbFolder = "Arduboy Inc - Arduboy",
        name = "Arduboy",
        muos = "Arduboy"
      },
      zx81 = {
        dat = {
          {
            "libretro/dat",
            "Sinclair - ZX 81"
          }
        },
        tgdbId = 5010,
        ssId = 77,
        libretroThumbFolder = "Sinclair - ZX 81",
        extensions = {
          "p",
          "t81",
          "tzx"
        },
        key = "zx81",
        name = "Sinclair ZX81",
        muos = "Sinclair ZX 81"
      },
      atomiswave = {
        dat = {
          {
            "libretro/dat",
            "Atomiswave"
          }
        },
        alternate = {
          "arcade",
          "fbneo",
          "naomi"
        },
        ssParentId = 75,
        extensions = {
          "bin",
          "chd",
          "dat",
          "zip"
        },
        libretroThumbFolder = "Atomiswave",
        ssId = 53,
        key = "atomiswave",
        name = "Atomiswave",
        muos = "Sega Atomiswave Naomi"
      },
      naomi2 = {
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi 2.dat"
          }
        },
        alternate = {
          "naomi"
        },
        ssParentId = 75,
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        libretroThumbFolder = "Sega - Naomi 2",
        ssId = 230,
        key = "naomi2",
        name = "SEGA Naomi 2",
        muos = "Naomi 2"
      },
      c64 = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Commodore - 64"
          }
        },
        tgdbId = 40,
        ssId = 66,
        libretroThumbFolder = "Commodore - 64",
        extensions = {
          "cmd",
          "crt",
          "d64",
          "d71",
          "d80",
          "d81",
          "g64",
          "m3u",
          "prg",
          "t64",
          "tap",
          "vsf",
          "x64"
        },
        key = "c64",
        name = "Commodore 64",
        muos = "Commodore C64"
      },
      nds = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Nintendo - Nintendo DS.dat"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Nintendo DS.dat"
          }
        },
        alternate = {
          "ndsi"
        },
        extensions = {
          "nds"
        },
        tgdbId = 8,
        ssId = 15,
        key = "nds",
        prefer = {
          "no-intro"
        },
        libretroThumbFolder = "Nintendo - Nintendo DS",
        name = "Nintendo - DS",
        muos = "Nintendo DS"
      },
      ndsi = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "/Nintendo - Nintendo DSi.dat"
          }
        },
        alternate = {
          "nds"
        },
        extensions = {
          "nds"
        },
        tgdbId = 8,
        libretroThumbFolder = "Nintendo - Nintendo DSi",
        ssId = 15,
        key = "ndsi",
        name = "Nintendo - DSi",
        muos = "Nintendo DS"
      },
      neogeo = {
        dat = {
          {
            "libretro/dat",
            "SNK - Neo Geo.dat"
          }
        },
        tgdbId = 24,
        ssParentId = 75,
        extensions = {
          "chd",
          "cue",
          "fba",
          "iso",
          "zip"
        },
        libretroThumbFolder = "SNK - Neo Geo",
        ssId = 142,
        key = "neogeo",
        name = "SNK Neo Geo",
        muos = "SNK Neo Geo"
      },
      neocd = {
        dat = {
          {
            "libretro/metadat/redump",
            "SNK - Neo Geo CD"
          }
        },
        tgdbId = 4956,
        ssId = 70,
        libretroThumbFolder = "SNK - Neo Geo CD",
        extensions = {
          "chd",
          "cue",
          "fba",
          "iso"
        },
        key = "neocd",
        name = "SNK Neo Geo CD",
        muos = "SNK Neo Geo CD"
      },
      x1 = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Sharp - X1"
          },
          {
            "libretro/metadat/tosec",
            "Sharp - X1"
          }
        },
        tgdbId = 4977,
        extensions = {
          "2d",
          "2hd",
          "88d",
          "cmd",
          "d88",
          "dup",
          "dx1",
          "hdm",
          "tfd",
          "xdf"
        },
        prefer = {
          "no-intro"
        },
        key = "x1",
        ssId = 220,
        libretroThumbFolder = "Sharp - X1",
        name = "Sharp X1",
        muos = "Sharp X1"
      },
      cdi = {
        dat = {
          {
            "libretro/metadat/redump",
            "Philips - CD-i"
          }
        },
        tgdbId = 4917,
        ssId = 133,
        libretroThumbFolder = "Philips - CD-i",
        extensions = {
          "chd"
        },
        key = "cdi",
        name = "Philips CD-i",
        muos = "Philips CDi"
      },
      cpc = {
        dat = {
          {
            "libretro/dat",
            "Amstrad - CPC"
          },
          {
            "libretro/metadat/tosec",
            "Amstrad - CPC"
          }
        },
        tgdbId = 4914,
        extensions = {
          "cdt",
          "cpc",
          "cpr",
          "dsk",
          "m3u",
          "tap"
        },
        prefer = {
          "libretro-dats"
        },
        key = "cpc",
        ssId = 65,
        libretroThumbFolder = "Amstrad - CPC",
        name = "Amstrad CPC",
        muos = "Amstrad"
      },
      ngp = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "SNK - Neo Geo Pocket.dat"
          }
        },
        alternate = {
          "ngpc"
        },
        ssParentId = 82,
        extensions = {
          "ngp"
        },
        tgdbId = 4922,
        libretroThumbFolder = "SNK - Neo Geo Pocket",
        ssId = 25,
        key = "ngp",
        name = "Neo Geo Pocket",
        muos = "SNK Neo Geo Pocket - Color"
      },
      ngpc = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "SNK - Neo Geo Pocket Color.dat"
          }
        },
        alternate = {
          "ngpc"
        },
        extensions = {
          "ngc"
        },
        tgdbId = 4923,
        libretroThumbFolder = "SNK - Neo Geo Pocket Color",
        ssId = 82,
        key = "ngpc",
        name = "Neo Geo Pocket Color",
        muos = "SNK Neo Geo Pocket - Color"
      },
      dreamcast = {
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Dreamcast"
          },
          {
            "libretro/metadat/homebrew",
            "Sega - Dreamcast"
          }
        },
        tgdbId = 16,
        extensions = {
          "cdi",
          "chd",
          "cue",
          "gdi",
          "iso",
          "m3u"
        },
        prefer = {
          "redump"
        },
        key = "dreamcast",
        ssId = 23,
        libretroThumbFolder = "Sega - Dreamcast",
        name = "SEGA Dreamcast",
        muos = "Sega Dreamcast"
      },
      ["3do"] = {
        dat = {
          {
            "libretro/metadat/redump/",
            "The 3DO Company"
          }
        },
        tgdbId = 25,
        ssId = 29,
        libretroThumbFolder = "The 3DO Company - 3DO",
        extensions = {
          "chd",
          "cue",
          "iso"
        },
        key = "3do",
        name = "Panasonic 3DO",
        muos = "The 3DO Company - 3DO"
      },
      fds = {
        dat = {
          {
            "libretro/metadat/libretro-dats",
            "Nintendo - Family Computer Disk System"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Family Computer Disk System"
          }
        },
        tgdbId = 4936,
        ssParentId = 3,
        extensions = {
          "fds",
          "nes"
        },
        libretroThumbFolder = "Nintendo - Family Computer Disk System",
        ssId = 106,
        key = "fds",
        name = "Nintendo - Famicom Disk System",
        muos = "Nintendo FDS"
      },
      saturn = {
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Saturn"
          }
        },
        tgdbId = 17,
        ssId = 22,
        libretroThumbFolder = "Sega - Saturn",
        extensions = {
          "chd",
          "cue",
          "iso",
          "m3u",
          "mdf"
        },
        key = "saturn",
        name = "SEGA Saturn",
        muos = "Sega Saturn"
      },
      nes = {
        dat = {
          {
            "libretro/dat",
            "Nintendo - Nintendo Entertainment System"
          },
          {
            "libretro/metadat/hacks",
            "Nintendo - Nintendo Entertainment System"
          },
          {
            "libretro/metadat/headered",
            "Nintendo - Nintendo Entertainment System"
          },
          {
            "libretro/metadat/homebrew",
            "Nintendo - Nintendo Entertainment System"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Nintendo Entertainment System"
          },
          {
            "libretro/metadat/tosec",
            "Nintendo - Nintendo Entertainment System"
          }
        },
        tgdbId = 7,
        extensions = {
          "fig",
          "mgd",
          "nes",
          "sfc",
          "smc",
          "swc"
        },
        prefer = {
          "no-intro",
          "libretro-dats"
        },
        key = "nes",
        ssId = 3,
        libretroThumbFolder = "Nintendo - Nintendo Entertainment System",
        name = "Nintendo - Entertainment System",
        muos = "Nintendo NES - Famicom"
      },
      gb = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Nintendo - Game Boy.dat"
          },
          {
            "libretro/metadat/homebrew",
            "Nintendo - Game Boy.dat"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Game Boy.dat"
          },
          {
            "libretro/metadat/tosec",
            "Nintendo - Game Boy.dat"
          }
        },
        tgdbId = 4,
        extensions = {
          "gb"
        },
        prefer = {
          "no-intro"
        },
        key = "gb",
        ssId = 9,
        libretroThumbFolder = "Nintendo - Game Boy",
        name = "Nintendo - Gameboy",
        muos = "Nintendo Game Boy"
      },
      scummvm = {
        dat = {
          {
            "libretro/dat",
            "ScummVM"
          },
          {
            "libretro/metadat/magazine/edge",
            "ScummVM"
          }
        },
        ssParentId = 135,
        extensions = {
          "scummvm",
          "svm"
        },
        libretroThumbFolder = "ScummVM",
        ssId = 123,
        key = "scummvm",
        name = "ScummVM",
        muos = "ScummVM"
      },
      a800 = {
        dat = {
          {
            "libretro/metadat/no-intro/",
            "Atari - 8-bit"
          },
          {
            "libretro/metadat/tosec/",
            "Atari - 8-bit"
          }
        },
        tgdbId = 4943,
        prefer = {
          "no-intro"
        },
        key = "a800",
        ssId = 43,
        libretroThumbFolder = "Atari - 8-bit",
        name = "Atari 8-bit Family",
        extensions = {
          "a52",
          "atr",
          "atr.gz",
          "atx",
          "bas",
          "bin",
          "car",
          "cas",
          "com",
          "dcm",
          "rom",
          "xex",
          "xfd",
          "xfd.gz"
        }
      },
      sega32x = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Sega - 32X"
          },
          {
            "libretro/metadat/no-intro",
            "Sega - 32X"
          },
          {
            "libretro/metadat/tosec",
            "Sega - 32X"
          }
        },
        tgdbId = 33,
        ssParentId = 1,
        extensions = {
          "32x",
          "bin",
          "md",
          "smd"
        },
        prefer = {
          "no-intro"
        },
        key = "sega32x",
        ssId = 19,
        libretroThumbFolder = "Sega - 32X",
        name = "SEGA 32X",
        muos = "Sega 32X"
      },
      gba = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Nintendo - Game Boy Advance"
          },
          {
            "libretro/metadat/homebrew",
            "Nintendo - Game Boy Advance"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Game Boy Advance"
          },
          {
            "libretro/metadat/tosec",
            "Nintendo - Game Boy Advance"
          }
        },
        tgdbId = 5,
        extensions = {
          "gba"
        },
        prefer = {
          "no-intro"
        },
        key = "gba",
        ssId = 12,
        libretroThumbFolder = "Nintendo - Game Boy Advance",
        name = "Nintendo - Game Boy Advance",
        muos = "Nintendo Game Boy Advance"
      },
      pcecd = {
        dat = {
          {
            "libretro/metadat/redump",
            "NEC - PC Engine CD - TurboGrafx-CD"
          }
        },
        tgdbId = 4955,
        ssParentId = 31,
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        libretroThumbFolder = "NEC - PC Engine CD - TurboGrafx-CD",
        ssId = 114,
        key = "pcecd",
        name = "PC Engine CD-ROM²",
        muos = "NEC PC Engine CD"
      },
      sg1000 = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Sega - SG-1000"
          },
          {
            "libretro/metadat/tosec",
            "Sega - SG-1000"
          }
        },
        tgdbId = 4949,
        ssParentId = 2,
        extensions = {
          "bin",
          "sg"
        },
        libretroThumbFolder = "Sega - SG-1000",
        ssId = 109,
        key = "sg1000",
        name = "SEGA SG-1000",
        muos = "Sega SG-1000"
      },
      channelf = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Fairchild - Channel F"
          }
        },
        tgdbId = 4928,
        ssId = 80,
        libretroThumbFolder = "Fairchild - Channel F",
        extensions = {
          "bin",
          "rom"
        },
        key = "channelf",
        name = "Fairchild ChannelF",
        muos = "Fairchild ChannelF"
      },
      jaguar = {
        dat = {
          {
            "libretro/metadat/magazine/edge/",
            "Atari - Jaguar"
          },
          {
            "libretro/metadat/no-intro",
            "Atari - Jaguar"
          },
          {
            "libretro/metadat/tosec",
            "Atari - Jaguar"
          }
        },
        tgdbId = 28,
        extensions = {
          "chd",
          "cue",
          "j64",
          "jag"
        },
        prefer = {
          "no-intro"
        },
        key = "jaguar",
        ssId = 27,
        libretroThumbFolder = "Atari - Jaguar",
        name = "Atari Jaguar",
        muos = "Atari Jaguar"
      },
      pico8 = {
        dat = {
          {
            "libretro/dat",
            "PICO-8"
          }
        },
        ssParentId = 234,
        key = "pico8",
        extensions = {
          "p8",
          "png"
        },
        name = "Pico-8",
        muos = "PICO-8"
      },
      pokemini = {
        dat = {
          {
            "libretro/metadat/homebrew",
            "Nintendo - Pokemon Mini.dat"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Pokemon Mini.dat"
          }
        },
        tgdbId = 4957,
        ssId = 211,
        libretroThumbFolder = "Nintendo - Pokemon Mini",
        extensions = {
          "min"
        },
        key = "pokemini",
        name = "Nintendo - Pokemon Mini",
        muos = "Nintendo Pokemon Mini"
      },
      gbc = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Nintendo - Game Boy Color"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Game Boy Color"
          },
          {
            "libretro/metadat/tosec",
            "Nintendo - Game Boy Color"
          }
        },
        tgdbId = 41,
        ssParentId = 9,
        extensions = {
          "gbc",
          "gb"
        },
        prefer = {
          "no-intro"
        },
        key = "gbc",
        ssId = 10,
        libretroThumbFolder = "Nintendo - Game Boy Color",
        name = "Nintendo - Game Boy Color",
        muos = "Nintendo Game Boy Color"
      },
      pce = {
        dat = {
          {
            "libretro/metadat/hacks",
            "NEC - PC Engine - TurboGrafx 16"
          },
          {
            "libretro/metadat/no-intro",
            "NEC - PC Engine - TurboGrafx 16"
          }
        },
        tgdbId = 34,
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        prefer = {
          "no-intro"
        },
        key = "pce",
        ssId = 31,
        libretroThumbFolder = "NEC - PC Engine - TurboGrafx 16",
        name = "PC Engine",
        muos = "NEC PC Engine"
      },
      sms = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Sega - Master System - Mark III"
          }
        },
        tgdbId = 35,
        ssId = 2,
        libretroThumbFolder = "Sega - Master System - Mark III",
        extensions = {
          "bin",
          "sms"
        },
        key = "sms",
        name = "SEGA Master System",
        muos = "Sega Master System"
      },
      gw = {
        dat = {
          {
            "no-intro/No-Intro",
            "Nintendo - Game & Watch"
          }
        },
        tgdbId = 4950,
        key = "gw",
        ssId = 52,
        extensions = {
          "mgw"
        },
        name = "Nintendo - Game & Watch",
        muos = "Handheld Electronic - Game and Watch"
      },
      gg = {
        dat = {
          {
            "libretro/metadat/hacks",
            "Sega - Game Gear"
          },
          {
            "libretro/metadat/no-intro",
            "Sega - Game Gear"
          },
          {
            "libretro/metadat/tosec",
            "Sega - Game Gear"
          }
        },
        tgdbId = 20,
        extensions = {
          "bin",
          "gg",
          "sms"
        },
        prefer = {
          "no-intro"
        },
        key = "gg",
        ssId = 21,
        libretroThumbFolder = "Sega - Game Gear",
        name = "SEGA Game Gear",
        muos = "Sega Game Gear"
      },
      naomi = {
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi.dat"
          }
        },
        alternate = {
          "naomi2"
        },
        ssParentId = 75,
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        libretroThumbFolder = "Sega - Naomi",
        ssId = 56,
        key = "naomi",
        name = "SEGA Naomi",
        muos = "Naomi"
      },
      psx = {
        dat = {
          {
            "libretro/metadat/redump",
            "Sony - PlayStation.dat"
          },
          {
            "libretro/metadat/hacks",
            "Sony - PlayStation.dat"
          },
          {
            "libretro/metadat/magazine/edge",
            "Sony - PlayStation.dat"
          }
        },
        tgdbId = 10,
        extensions = {
          "cbn",
          "chd",
          "cue",
          "img",
          "iso",
          "m3u",
          "mdf",
          "pbp",
          "toc",
          "z",
          "znx"
        },
        prefer = {
          "redump"
        },
        key = "psx",
        ssId = 57,
        libretroThumbFolder = "Sony - PlayStation",
        name = "Sony PlayStation",
        muos = "Sony PlayStation"
      },
      spectrum = {
        dat = {
          {
            "libretro/dat",
            "Sinclair - ZX Spectrum"
          },
          {
            "libretro/metadat/tosec",
            "Sinclair - ZX Spectrum.dat"
          },
          {
            "libretro/metadat/no-intro",
            "Sinclair - ZX Spectrum +3"
          }
        },
        tgdbId = 4913,
        ssId = 76,
        libretroThumbFolder = "Sinclair - ZX Spectrum",
        extensions = {
          "dsk",
          "gz",
          "img",
          "mgt",
          "rzx",
          "scl",
          "sna",
          "szx",
          "tap",
          "trd",
          "tzx",
          "udi",
          "z80"
        },
        key = "spectrum",
        name = "ZX Spectrum",
        muos = "Sinclair ZX Spectrum"
      },
      gx4000 = {
        dat = {
          {
            "libretro/metadat/tosec",
            "Amstrad - GX4000"
          }
        },
        tgdbId = 4999,
        ssParentId = 65,
        extensions = {
          "cpr",
          "bin"
        },
        libretroThumbFolder = "Amstrad - GX4000",
        ssId = 87,
        key = "gx4000",
        name = "Amstrad GX4000",
        muos = "Amstrad"
      },
      atari2600 = {
        dat = {
          {
            "libretro/metadat/no-intro/",
            "Atari - 2600"
          },
          {
            "libretro/metadat/tosec/",
            "Atari - 2600"
          }
        },
        tgdbId = 22,
        extensions = {
          "a26",
          "bin",
          "gz",
          "rom"
        },
        prefer = {
          "no-intro"
        },
        key = "atari2600",
        ssId = 26,
        libretroThumbFolder = "Atari - 2600",
        name = "Atari 2600",
        muos = "Atari 2600"
      },
      openbor = {
        ssId = 214,
        key = "openbor",
        muos = "OpenBOR",
        name = "OpenBOR",
        extensions = {
          "bor",
          "pak"
        }
      },
      intv = {
        dat = {
          {
            "libretro/metadat/homebrew",
            "Mattel - Intellivision"
          },
          {
            "libretro/metadat/no-intro",
            "Mattel - Intellivision"
          },
          {
            "libretro/metadat/tosec",
            "Mattel - Intellivision"
          }
        },
        tgdbId = 32,
        extensions = {
          "bin",
          "int",
          "itv",
          "rom"
        },
        prefer = {
          "no-intro"
        },
        key = "intv",
        ssId = 115,
        libretroThumbFolder = "Mattel - Intellivision",
        name = "Mattel Intellivision",
        muos = "Mattel - Intellivision"
      },
      pces = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "NEC - PC Engine SuperGrafx"
          }
        },
        ssParentId = 31,
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        libretroThumbFolder = "NEC - PC Engine SuperGrafx",
        ssId = 105,
        key = "pces",
        name = "PC Engine SuperGrafx",
        muos = "NEC PC Engine SuperGrafx"
      },
      odyssey2 = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Magnavox - Odyssey2.dat"
          }
        },
        tgdbId = {
          4961,
          4927
        },
        ssId = 104,
        libretroThumbFolder = "Magnavox - Odyssey2",
        extensions = {
          "bin"
        },
        key = "odyssey2",
        name = "Magnavox Odyssey - Videopac",
        muos = "Odyssey2 - VideoPac"
      },
      atari5200 = {
        dat = {
          {
            "libretro/metadat/no-intro/",
            "Atari - 5200"
          },
          {
            "libretro/metadat/tosec/",
            "Atari - 5200"
          }
        },
        tgdbId = 26,
        extensions = {
          "a52",
          "atr",
          "atr.gz",
          "bas",
          "bin",
          "car",
          "dcm",
          "xex",
          "xfd",
          "xfd.gz"
        },
        prefer = {
          "no-intro"
        },
        key = "atari5200",
        ssId = 40,
        libretroThumbFolder = "Atari - 5200",
        name = "Atari 5200",
        muos = "Atari 5200"
      },
      psp = {
        dat = {
          {
            "libretro/metadat/no-intro",
            "Sony - PlayStation Portable (PSN)"
          },
          {
            "libretro/metadat/no-intro",
            "Sony - PlayStation Portable (PSX2PSP)"
          },
          {
            "libretro/metadat/no-intro",
            "Sony - PlayStation Portable (UMD Music)"
          },
          {
            "libretro/metadat/no-intro",
            "Sony - PlayStation Portable (UMD Video)"
          }
        },
        tgdbId = 13,
        ssId = 61,
        libretroThumbFolder = "Sony - PlayStation Portable",
        extensions = {
          "chd",
          "cso",
          "iso",
          "pbp"
        },
        key = "psp",
        name = "Sony PlayStation Portable",
        muos = "Sony Playstation Portable"
      },
      snes = {
        dat = {
          {
            "libretro/dat",
            "Nintendo - Super Nintendo Entertainment System"
          },
          {
            "libretro/metadat/hacks",
            "Nintendo - Super Nintendo Entertainment System"
          },
          {
            "libretro/metadat/homebrew",
            "Nintendo - Super Nintendo Entertainment System"
          },
          {
            "libretro/metadat/libretro-dats",
            "Nintendo - Super Nintendo Entertainment System"
          },
          {
            "libretro/metadat/magazine/edge",
            "Nintendo - Super Nintendo Entertainment System"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Super Nintendo Entertainment System"
          },
          {
            "libretro/metadat/tosec",
            "Nintendo - Super Nintendo Entertainment System"
          }
        },
        tgdbId = 6,
        ssId = 4,
        libretroThumbFolder = "Nintendo - Super Nintendo Entertainment System",
        extensions = {
          "bin",
          "bs",
          "fig",
          "mgd",
          "sfc",
          "smc",
          "swc"
        },
        key = "snes",
        name = "Nintendo - SNES",
        muos = "Nintendo SNES - SFC"
      },
      atari7800 = {
        dat = {
          {
            "libretro/metadat/no-intro/",
            "Atari - 7800"
          },
          {
            "libretro/metadat/tosec/",
            "Atari - 7800"
          },
          {
            "libretro/metadat/headered/",
            "Atari - 7800"
          }
        },
        tgdbId = 27,
        extensions = {
          "a78",
          "bin"
        },
        prefer = {
          "no-intro",
          "headered"
        },
        key = "atari7800",
        ssId = 41,
        libretroThumbFolder = "Atari - 7800",
        name = "Atari 7800",
        muos = "Atari 7800"
      }
    }
  }

return M
