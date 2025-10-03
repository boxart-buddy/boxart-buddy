-- DO NOT EDIT THIS CODE IT IS GENERATED AUTOMATICALLY
local M = {
    byMuos = {
      ["nintendo famicon disk system"] = {
        muos = "Nintendo Famicon Disk System",
        libretroThumbFolder = "Nintendo - Family Computer Disk System",
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
        ssId = 106,
        extensions = {
          "fds",
          "nes"
        },
        tgdbId = 4936,
        name = "Nintendo - Famicom Disk System",
        key = "fds",
        ssParentId = 3
      },
      ["odyssey2 - videopac"] = {
        tgdbId = {
          4961,
          4927
        },
        extensions = {
          "bin"
        },
        ssId = 104,
        muos = "Odyssey2 - VideoPac",
        name = "Magnavox Odyssey - Videopac",
        libretroThumbFolder = "Magnavox - Odyssey2",
        key = "odyssey2",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Magnavox - Odyssey2.dat"
          }
        }
      },
      ["sega mega cd - sega cd"] = {
        tgdbId = 21,
        extensions = {
          "chd",
          "cue",
          "iso",
          "m3u"
        },
        ssId = 20,
        muos = "Sega Mega CD - Sega CD",
        name = "SEGA Mega-CD",
        libretroThumbFolder = "Sega - Mega-CD - Sega CD",
        key = "mdcd",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Mega-CD - Sega CD"
          }
        }
      },
      ["sony playstation"] = {
        prefer = {
          "redump"
        },
        muos = "Sony PlayStation",
        libretroThumbFolder = "Sony - PlayStation",
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
        ssId = 57,
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
        tgdbId = 10,
        key = "psx",
        name = "Sony PlayStation"
      },
      ["nintendo game boy"] = {
        prefer = {
          "no-intro"
        },
        muos = "Nintendo Game Boy",
        libretroThumbFolder = "Nintendo - Game Boy",
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
        ssId = 9,
        extensions = {
          "gb"
        },
        tgdbId = 4,
        key = "gb",
        name = "Nintendo - Gameboy"
      },
      ["nintendo game boy advance"] = {
        prefer = {
          "no-intro"
        },
        muos = "Nintendo Game Boy Advance",
        libretroThumbFolder = "Nintendo - Game Boy Advance",
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
        ssId = 12,
        extensions = {
          "gba"
        },
        tgdbId = 5,
        key = "gba",
        name = "Nintendo - Game Boy Advance"
      },
      ["sega game gear"] = {
        prefer = {
          "no-intro"
        },
        muos = "Sega Game Gear",
        libretroThumbFolder = "Sega - Game Gear",
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
        ssId = 21,
        extensions = {
          "bin",
          "gg",
          "sms"
        },
        tgdbId = 20,
        key = "gg",
        name = "SEGA Game Gear"
      },
      ["nec pc engine cd"] = {
        muos = "NEC PC Engine CD",
        libretroThumbFolder = "NEC - PC Engine CD - TurboGrafx-CD",
        dat = {
          {
            "libretro/metadat/redump",
            "NEC - PC Engine CD - TurboGrafx-CD"
          }
        },
        ssId = 114,
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        tgdbId = 4955,
        name = "PC Engine CD-ROM²",
        key = "pcecd",
        ssParentId = 31
      },
      ["nintendo game boy color"] = {
        prefer = {
          "no-intro"
        },
        muos = "Nintendo Game Boy Color",
        libretroThumbFolder = "Nintendo - Game Boy Color",
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
        ssId = 10,
        extensions = {
          "gbc",
          "gb"
        },
        tgdbId = 41,
        ssParentId = 9,
        key = "gbc",
        name = "Nintendo - Game Boy Color"
      },
      ["atari 2600"] = {
        prefer = {
          "no-intro"
        },
        muos = "Atari 2600",
        libretroThumbFolder = "Atari - 2600",
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
        ssId = 26,
        extensions = {
          "a26",
          "bin",
          "gz",
          "rom"
        },
        tgdbId = 22,
        key = "atari2600",
        name = "Atari 2600"
      },
      ["microsoft - msx"] = {
        muos = "Microsoft - MSX",
        libretroThumbFolder = "Microsoft - MSX2",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX2.dat"
          }
        },
        tgdbId = 4929,
        ssId = 116,
        extensions = {
          "col",
          "dsk",
          "mx1",
          "mx2",
          "rom"
        },
        ssParentId = 113,
        key = "msx2",
        alternate = {
          "msx"
        },
        name = "MSX2 Computer"
      },
      ["sega mega drive - genesis"] = {
        prefer = {
          "no-intro"
        },
        muos = "Sega Mega Drive - Genesis",
        libretroThumbFolder = "Sega - Mega Drive - Genesis",
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
        ssId = 1,
        extensions = {
          "bin",
          "gen",
          "md",
          "sg",
          "smd"
        },
        tgdbId = {
          36,
          18
        },
        key = "md",
        name = "SEGA Megadrive"
      },
      ["nintendo nes - famicom"] = {
        prefer = {
          "no-intro",
          "libretro-dats"
        },
        muos = "Nintendo NES - Famicom",
        libretroThumbFolder = "Nintendo - Nintendo Entertainment System",
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
        ssId = 3,
        extensions = {
          "fig",
          "mgd",
          "nes",
          "sfc",
          "smc",
          "swc"
        },
        tgdbId = 7,
        key = "nes",
        name = "Nintendo - Entertainment System"
      },
      ["sega atomiswave naomi"] = {
        muos = "Sega Atomiswave Naomi",
        libretroThumbFolder = "Atomiswave",
        dat = {
          {
            "libretro/dat",
            "Atomiswave"
          }
        },
        ssId = 53,
        extensions = {
          "bin",
          "chd",
          "dat",
          "zip"
        },
        ssParentId = 75,
        key = "atomiswave",
        alternate = {
          "arcade",
          "fbneo",
          "naomi"
        },
        name = "Atomiswave"
      },
      ["sharp x68000"] = {
        prefer = {
          "no-intro"
        },
        muos = "Sharp X68000",
        libretroThumbFolder = "Sharp - X68000",
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
        ssId = 79,
        extensions = {
          "2hd",
          "d88",
          "dim",
          "hdf",
          "hdm",
          "m3u",
          "xdf"
        },
        tgdbId = 4931,
        key = "x68000",
        name = "Sharp X68000"
      },
      scummvm = {
        muos = "ScummVM",
        libretroThumbFolder = "ScummVM",
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
        ssId = 123,
        extensions = {
          "scummvm",
          "svm"
        },
        name = "ScummVM",
        key = "scummvm",
        ssParentId = 135
      },
      ["bandai wonderswan color"] = {
        muos = "Bandai WonderSwan Color",
        libretroThumbFolder = "Bandai - WonderSwan Color",
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
        ssId = 46,
        extensions = {
          "wsc"
        },
        tgdbId = 4926,
        name = "WonderSwan Color",
        key = "wsc",
        ssParentId = 45
      },
      ["nec pc engine"] = {
        prefer = {
          "no-intro"
        },
        muos = "NEC PC Engine",
        libretroThumbFolder = "NEC - PC Engine - TurboGrafx 16",
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
        ssId = 31,
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        tgdbId = 34,
        key = "pce",
        name = "PC Engine"
      },
      ["snk neo geo pocket - color"] = {
        muos = "SNK Neo Geo Pocket - Color",
        libretroThumbFolder = "SNK - Neo Geo Pocket Color",
        dat = {
          {
            "libretro/metadat/no-intro",
            "SNK - Neo Geo Pocket Color.dat"
          }
        },
        ssId = 82,
        extensions = {
          "ngc"
        },
        tgdbId = 4923,
        key = "ngpc",
        alternate = {
          "ngpc"
        },
        name = "Neo Geo Pocket Color"
      },
      ["microsoft msx"] = {
        muos = "Microsoft MSX",
        libretroThumbFolder = "Microsoft - MSX",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX.dat"
          }
        },
        ssId = 113,
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
        key = "msx",
        alternate = {
          "msx2"
        },
        name = "MSX Computer"
      },
      ["fairchild channel f"] = {
        tgdbId = 4928,
        extensions = {
          "bin",
          "rom"
        },
        ssId = 80,
        muos = "Fairchild Channel F",
        name = "Fairchild ChannelF",
        libretroThumbFolder = "Fairchild - Channel F",
        key = "channelf",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Fairchild - Channel F"
          }
        }
      },
      arduboy = {
        prefer = {
          "libretro-dats"
        },
        muos = "Arduboy",
        libretroThumbFolder = "Arduboy Inc - Arduboy",
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
        ssId = 263,
        extensions = {
          "hex",
          "arduboy"
        },
        key = "arduboy",
        name = "Arduboy"
      },
      ["mega duck - cougar boy"] = {
        ssId = 90,
        extensions = {
          "bin"
        },
        tgdbId = 4948,
        muos = "Mega Duck - Cougar Boy",
        key = "megaduck",
        name = "Mega Duck"
      },
      ["nintendo snes - sfc"] = {
        tgdbId = 6,
        extensions = {
          "bin",
          "bs",
          "fig",
          "mgd",
          "sfc",
          "smc",
          "swc"
        },
        ssId = 4,
        muos = "Nintendo SNES - SFC",
        name = "Nintendo - SNES",
        libretroThumbFolder = "Nintendo - Super Nintendo Entertainment System",
        key = "snes",
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
        }
      },
      ["nintendo pokemon mini"] = {
        tgdbId = 4957,
        extensions = {
          "min"
        },
        ssId = 211,
        muos = "Nintendo Pokemon Mini",
        name = "Nintendo - Pokemon Mini",
        libretroThumbFolder = "Nintendo - Pokemon Mini",
        key = "pokemini",
        dat = {
          {
            "libretro/metadat/homebrew",
            "Nintendo - Pokemon Mini.dat"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Pokemon Mini.dat"
          }
        }
      },
      naomi = {
        muos = "Naomi",
        libretroThumbFolder = "Sega - Naomi",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi.dat"
          }
        },
        ssId = 56,
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        ssParentId = 75,
        key = "naomi",
        alternate = {
          "naomi2"
        },
        name = "SEGA Naomi"
      },
      openbor = {
        ssId = 214,
        extensions = {
          "bor",
          "pak"
        },
        muos = "OpenBOR",
        key = "openbor",
        name = "OpenBOR"
      },
      ["gce vectrex"] = {
        tgdbId = 4939,
        extensions = {
          "bin",
          "gam",
          "vec"
        },
        ssId = 102,
        muos = "GCE Vectrex",
        name = "GCE Vectrex",
        libretroThumbFolder = "GCE - Vectrex",
        key = "vectrex",
        dat = {
          {
            "libretro/metadat/no-intro",
            "GCE - Vectrex"
          }
        }
      },
      ["sega sg-1000"] = {
        muos = "Sega SG-1000",
        libretroThumbFolder = "Sega - SG-1000",
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
        ssId = 109,
        extensions = {
          "bin",
          "sg"
        },
        tgdbId = 4949,
        name = "SEGA SG-1000",
        key = "sg1000",
        ssParentId = 2
      },
      ["watara supervision"] = {
        tgdbId = 4959,
        extensions = {
          "bin",
          "sv"
        },
        ssId = 207,
        muos = "Watara Supervision",
        name = "Watara Supervision",
        libretroThumbFolder = "Watara - Supervision",
        key = "supervision",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Watara - Supervision"
          }
        }
      },
      ["atari lynx"] = {
        prefer = {
          "no-intro"
        },
        muos = "Atari Lynx",
        libretroThumbFolder = "Atari - Lynx",
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
        ssId = 28,
        extensions = {
          "lnx"
        },
        tgdbId = 4924,
        key = "lynx",
        name = "Atari Lynx"
      },
      ["the 3do company - 3do"] = {
        tgdbId = 25,
        extensions = {
          "chd",
          "cue",
          "iso"
        },
        ssId = 29,
        muos = "The 3DO Company - 3DO",
        name = "Panasonic 3DO",
        libretroThumbFolder = "The 3DO Company - 3DO",
        key = "3do",
        dat = {
          {
            "libretro/metadat/redump/",
            "The 3DO Company"
          }
        }
      },
      ["pico-8"] = {
        ssParentId = 234,
        muos = "PICO-8",
        extensions = {
          "p8",
          "png"
        },
        dat = {
          {
            "libretro/dat",
            "PICO-8"
          }
        },
        key = "pico8",
        name = "Pico-8"
      },
      ["handheld electronic - game and watch"] = {
        tgdbId = 4950,
        ssId = 52,
        muos = "Handheld Electronic - Game and Watch",
        extensions = {
          "mgw"
        },
        dat = {
          {
            "no-intro/No-Intro",
            "Nintendo - Game & Watch"
          }
        },
        key = "gw",
        name = "Nintendo - Game & Watch"
      },
      ["sega saturn"] = {
        tgdbId = 17,
        extensions = {
          "chd",
          "cue",
          "iso",
          "m3u",
          "mdf"
        },
        ssId = 22,
        muos = "Sega Saturn",
        name = "SEGA Saturn",
        libretroThumbFolder = "Sega - Saturn",
        key = "saturn",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Saturn"
          }
        }
      },
      ["sony playstation portable"] = {
        tgdbId = 13,
        extensions = {
          "chd",
          "cso",
          "iso",
          "pbp"
        },
        ssId = 61,
        muos = "Sony PlayStation Portable",
        name = "Sony PlayStation Portable",
        libretroThumbFolder = "Sony - PlayStation Portable",
        key = "psp",
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
        }
      },
      ["sega 32x"] = {
        prefer = {
          "no-intro"
        },
        muos = "Sega 32X",
        libretroThumbFolder = "Sega - 32X",
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
        ssId = 19,
        extensions = {
          "32x",
          "bin",
          "md",
          "smd"
        },
        tgdbId = 33,
        ssParentId = 1,
        key = "sega32x",
        name = "SEGA 32X"
      },
      ["commodore amiga"] = {
        prefer = {
          "whdload",
          "libretro-dats",
          "no-intro"
        },
        muos = "Commodore Amiga",
        libretroThumbFolder = "Commodore - Amiga",
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
        ssId = 64,
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
        tgdbId = 4911,
        key = "amiga",
        name = "Commodore Amiga"
      },
      ["snk neo geo cd"] = {
        tgdbId = 4956,
        extensions = {
          "chd",
          "cue",
          "fba",
          "iso"
        },
        ssId = 70,
        muos = "SNK Neo Geo CD",
        name = "SNK Neo Geo CD",
        libretroThumbFolder = "SNK - Neo Geo CD",
        key = "neocd",
        dat = {
          {
            "libretro/metadat/redump",
            "SNK - Neo Geo CD"
          }
        }
      },
      amstrad = {
        muos = "Amstrad",
        libretroThumbFolder = "Amstrad - GX4000",
        dat = {
          {
            "libretro/metadat/tosec",
            "Amstrad - GX4000"
          }
        },
        ssId = 87,
        extensions = {
          "cpr",
          "bin"
        },
        tgdbId = 4999,
        name = "Amstrad GX4000",
        key = "gx4000",
        ssParentId = 65
      },
      ["mattel - intellivision"] = {
        prefer = {
          "no-intro"
        },
        muos = "Mattel - Intellivision",
        libretroThumbFolder = "Mattel - Intellivision",
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
        ssId = 115,
        extensions = {
          "bin",
          "int",
          "itv",
          "rom"
        },
        tgdbId = 32,
        key = "intv",
        name = "Mattel Intellivision"
      },
      ["atari 5200"] = {
        prefer = {
          "no-intro"
        },
        muos = "Atari 5200",
        libretroThumbFolder = "Atari - 5200",
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
        ssId = 40,
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
        tgdbId = 26,
        key = "atari5200",
        name = "Atari 5200"
      },
      ["nintendo ds"] = {
        muos = "Nintendo DS",
        libretroThumbFolder = "Nintendo - Nintendo DSi",
        dat = {
          {
            "libretro/metadat/no-intro",
            "/Nintendo - Nintendo DSi.dat"
          }
        },
        ssId = 15,
        extensions = {
          "nds"
        },
        tgdbId = 8,
        key = "ndsi",
        alternate = {
          "nds"
        },
        name = "Nintendo - DSi"
      },
      ["snk neo geo"] = {
        muos = "SNK Neo Geo",
        libretroThumbFolder = "SNK - Neo Geo",
        dat = {
          {
            "libretro/dat",
            "SNK - Neo Geo.dat"
          }
        },
        ssId = 142,
        extensions = {
          "chd",
          "cue",
          "fba",
          "iso",
          "zip"
        },
        tgdbId = 24,
        name = "SNK Neo Geo",
        key = "neogeo",
        ssParentId = 75
      },
      ["sega dreamcast"] = {
        prefer = {
          "redump"
        },
        muos = "Sega Dreamcast",
        libretroThumbFolder = "Sega - Dreamcast",
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
        ssId = 23,
        extensions = {
          "cdi",
          "chd",
          "cue",
          "gdi",
          "iso",
          "m3u"
        },
        tgdbId = 16,
        key = "dreamcast",
        name = "SEGA Dreamcast"
      },
      ["philips cdi"] = {
        tgdbId = 4917,
        extensions = {
          "chd"
        },
        ssId = 133,
        muos = "Philips CDi",
        name = "Philips CD-i",
        libretroThumbFolder = "Philips - CD-i",
        key = "cdi",
        dat = {
          {
            "libretro/metadat/redump",
            "Philips - CD-i"
          }
        }
      },
      ["nec pc engine supergrafx"] = {
        muos = "NEC PC Engine SuperGrafx",
        libretroThumbFolder = "NEC - PC Engine SuperGrafx",
        dat = {
          {
            "libretro/metadat/no-intro",
            "NEC - PC Engine SuperGrafx"
          }
        },
        ssId = 105,
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        name = "PC Engine SuperGrafx",
        key = "pces",
        ssParentId = 31
      },
      ["atari jaguar"] = {
        prefer = {
          "no-intro"
        },
        muos = "Atari Jaguar",
        libretroThumbFolder = "Atari - Jaguar",
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
        ssId = 27,
        extensions = {
          "chd",
          "cue",
          "j64",
          "jag"
        },
        tgdbId = 28,
        key = "jaguar",
        name = "Atari Jaguar"
      },
      ["sinclair zx 81"] = {
        tgdbId = 5010,
        extensions = {
          "p",
          "t81",
          "tzx"
        },
        ssId = 77,
        muos = "Sinclair ZX 81",
        name = "Sinclair ZX81",
        libretroThumbFolder = "Sinclair - ZX 81",
        key = "zx81",
        dat = {
          {
            "libretro/dat",
            "Sinclair - ZX 81"
          }
        }
      },
      ["tic-80"] = {
        extensions = {
          "tic"
        },
        ssId = 222,
        muos = "TIC-80",
        name = "TIC-80 Tiny Computer",
        libretroThumbFolder = "TIC-80",
        key = "tic80",
        dat = {
          {
            "libretro/dat",
            "TIC-80"
          }
        }
      },
      ["commodore c64"] = {
        tgdbId = 40,
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
        ssId = 66,
        muos = "Commodore C64",
        name = "Commodore 64",
        libretroThumbFolder = "Commodore - 64",
        key = "c64",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Commodore - 64"
          }
        }
      },
      ["sinclair zx spectrum"] = {
        tgdbId = 4913,
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
        ssId = 76,
        muos = "Sinclair ZX Spectrum",
        name = "ZX Spectrum",
        libretroThumbFolder = "Sinclair - ZX Spectrum",
        key = "spectrum",
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
        }
      },
      ["java j2me"] = {
        extensions = {
          "jar"
        },
        tgdbId = 5018,
        muos = "Java J2ME",
        key = "j2me",
        name = "Java J2ME-Platform"
      },
      ["sharp x1"] = {
        prefer = {
          "no-intro"
        },
        muos = "Sharp X1",
        libretroThumbFolder = "Sharp - X1",
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
        ssId = 220,
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
        tgdbId = 4977,
        key = "x1",
        name = "Sharp X1"
      },
      ["naomi 2"] = {
        muos = "Naomi 2",
        libretroThumbFolder = "Sega - Naomi 2",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi 2.dat"
          }
        },
        ssId = 230,
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        ssParentId = 75,
        key = "naomi2",
        alternate = {
          "naomi"
        },
        name = "SEGA Naomi 2"
      },
      ["nintendo n64"] = {
        prefer = {
          "no-intro"
        },
        muos = "Nintendo N64",
        libretroThumbFolder = "Nintendo - Nintendo 64",
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
        ssId = 14,
        extensions = {
          "n64",
          "v64",
          "z64"
        },
        tgdbId = 3,
        key = "n64",
        name = "Nintendo - 64"
      },
      ["nintendo virtual boy"] = {
        tgdbId = 4918,
        extensions = {
          "vb"
        },
        ssId = 11,
        muos = "Nintendo Virtual Boy",
        name = "Nintendo - Virtual Boy",
        libretroThumbFolder = "Nintendo - Virtual Boy",
        key = "vb",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Nintendo - Virtual Boy"
          }
        }
      },
      ["atari 7800"] = {
        prefer = {
          "no-intro",
          "headered"
        },
        muos = "Atari 7800",
        libretroThumbFolder = "Atari - 7800",
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
        ssId = 41,
        extensions = {
          "a78",
          "bin"
        },
        tgdbId = 27,
        key = "atari7800",
        name = "Atari 7800"
      },
      arcade = {
        muos = "Arcade",
        libretroThumbFolder = "FBNeo - Arcade Games",
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
        ssId = 75,
        extensions = {
          "bin",
          "cue",
          "dat",
          "fba",
          "iso",
          "zip"
        },
        tgdbId = 23,
        key = "fbneo",
        alternate = {
          "arcade"
        },
        name = "Arcade (FB NEO)"
      },
      ["sega master system"] = {
        tgdbId = 35,
        extensions = {
          "bin",
          "sms"
        },
        ssId = 2,
        muos = "Sega Master System",
        name = "SEGA Master System",
        libretroThumbFolder = "Sega - Master System - Mark III",
        key = "sms",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Sega - Master System - Mark III"
          }
        }
      }
    },
    byKey = {
      ["3do"] = {
        tgdbId = 25,
        extensions = {
          "chd",
          "cue",
          "iso"
        },
        ssId = 29,
        muos = "The 3DO Company - 3DO",
        name = "Panasonic 3DO",
        libretroThumbFolder = "The 3DO Company - 3DO",
        key = "3do",
        dat = {
          {
            "libretro/metadat/redump/",
            "The 3DO Company"
          }
        }
      },
      ws = {
        tgdbId = 4925,
        extensions = {
          "ws"
        },
        ssId = 45,
        muos = "Bandai WonderSwan Color",
        name = "WonderSwan",
        libretroThumbFolder = "Bandai - WonderSwan",
        key = "ws",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Bandai - WonderSwan.dat"
          },
          {
            "libretro/metadat/hacks",
            "Bandai - WonderSwan.dat"
          }
        }
      },
      megaduck = {
        ssId = 90,
        extensions = {
          "bin"
        },
        tgdbId = 4948,
        muos = "Mega Duck - Cougar Boy",
        key = "megaduck",
        name = "Mega Duck"
      },
      wsc = {
        muos = "Bandai WonderSwan Color",
        libretroThumbFolder = "Bandai - WonderSwan Color",
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
        ssId = 46,
        extensions = {
          "wsc"
        },
        tgdbId = 4926,
        name = "WonderSwan Color",
        key = "wsc",
        ssParentId = 45
      },
      neocd = {
        tgdbId = 4956,
        extensions = {
          "chd",
          "cue",
          "fba",
          "iso"
        },
        ssId = 70,
        muos = "SNK Neo Geo CD",
        name = "SNK Neo Geo CD",
        libretroThumbFolder = "SNK - Neo Geo CD",
        key = "neocd",
        dat = {
          {
            "libretro/metadat/redump",
            "SNK - Neo Geo CD"
          }
        }
      },
      a800 = {
        tgdbId = 4943,
        prefer = {
          "no-intro"
        },
        ssId = 43,
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
        },
        name = "Atari 8-bit Family",
        libretroThumbFolder = "Atari - 8-bit",
        key = "a800",
        dat = {
          {
            "libretro/metadat/no-intro/",
            "Atari - 8-bit"
          },
          {
            "libretro/metadat/tosec/",
            "Atari - 8-bit"
          }
        }
      },
      msx2 = {
        muos = "Microsoft - MSX",
        libretroThumbFolder = "Microsoft - MSX2",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX2.dat"
          }
        },
        tgdbId = 4929,
        ssId = 116,
        extensions = {
          "col",
          "dsk",
          "mx1",
          "mx2",
          "rom"
        },
        ssParentId = 113,
        key = "msx2",
        alternate = {
          "msx"
        },
        name = "MSX2 Computer"
      },
      fbneo = {
        muos = "Arcade",
        libretroThumbFolder = "FBNeo - Arcade Games",
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
        ssId = 75,
        extensions = {
          "bin",
          "cue",
          "dat",
          "fba",
          "iso",
          "zip"
        },
        tgdbId = 23,
        key = "fbneo",
        alternate = {
          "arcade"
        },
        name = "Arcade (FB NEO)"
      },
      ngp = {
        muos = "SNK Neo Geo Pocket - Color",
        libretroThumbFolder = "SNK - Neo Geo Pocket",
        dat = {
          {
            "libretro/metadat/no-intro",
            "SNK - Neo Geo Pocket.dat"
          }
        },
        tgdbId = 4922,
        ssId = 25,
        extensions = {
          "ngp"
        },
        ssParentId = 82,
        key = "ngp",
        alternate = {
          "ngpc"
        },
        name = "Neo Geo Pocket"
      },
      x68000 = {
        prefer = {
          "no-intro"
        },
        muos = "Sharp X68000",
        libretroThumbFolder = "Sharp - X68000",
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
        ssId = 79,
        extensions = {
          "2hd",
          "d88",
          "dim",
          "hdf",
          "hdm",
          "m3u",
          "xdf"
        },
        tgdbId = 4931,
        key = "x68000",
        name = "Sharp X68000"
      },
      arduboy = {
        prefer = {
          "libretro-dats"
        },
        muos = "Arduboy",
        libretroThumbFolder = "Arduboy Inc - Arduboy",
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
        ssId = 263,
        extensions = {
          "hex",
          "arduboy"
        },
        key = "arduboy",
        name = "Arduboy"
      },
      ngpc = {
        muos = "SNK Neo Geo Pocket - Color",
        libretroThumbFolder = "SNK - Neo Geo Pocket Color",
        dat = {
          {
            "libretro/metadat/no-intro",
            "SNK - Neo Geo Pocket Color.dat"
          }
        },
        ssId = 82,
        extensions = {
          "ngc"
        },
        tgdbId = 4923,
        key = "ngpc",
        alternate = {
          "ngpc"
        },
        name = "Neo Geo Pocket Color"
      },
      atomiswave = {
        muos = "Sega Atomiswave Naomi",
        libretroThumbFolder = "Atomiswave",
        dat = {
          {
            "libretro/dat",
            "Atomiswave"
          }
        },
        ssId = 53,
        extensions = {
          "bin",
          "chd",
          "dat",
          "zip"
        },
        ssParentId = 75,
        key = "atomiswave",
        alternate = {
          "arcade",
          "fbneo",
          "naomi"
        },
        name = "Atomiswave"
      },
      naomi = {
        muos = "Naomi",
        libretroThumbFolder = "Sega - Naomi",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi.dat"
          }
        },
        ssId = 56,
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        ssParentId = 75,
        key = "naomi",
        alternate = {
          "naomi2"
        },
        name = "SEGA Naomi"
      },
      openbor = {
        ssId = 214,
        extensions = {
          "bor",
          "pak"
        },
        muos = "OpenBOR",
        key = "openbor",
        name = "OpenBOR"
      },
      c64 = {
        tgdbId = 40,
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
        ssId = 66,
        muos = "Commodore C64",
        name = "Commodore 64",
        libretroThumbFolder = "Commodore - 64",
        key = "c64",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Commodore - 64"
          }
        }
      },
      odyssey2 = {
        tgdbId = {
          4961,
          4927
        },
        extensions = {
          "bin"
        },
        ssId = 104,
        muos = "Odyssey2 - VideoPac",
        name = "Magnavox Odyssey - Videopac",
        libretroThumbFolder = "Magnavox - Odyssey2",
        key = "odyssey2",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Magnavox - Odyssey2.dat"
          }
        }
      },
      pce = {
        prefer = {
          "no-intro"
        },
        muos = "NEC PC Engine",
        libretroThumbFolder = "NEC - PC Engine - TurboGrafx 16",
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
        ssId = 31,
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        tgdbId = 34,
        key = "pce",
        name = "PC Engine"
      },
      pces = {
        muos = "NEC PC Engine SuperGrafx",
        libretroThumbFolder = "NEC - PC Engine SuperGrafx",
        dat = {
          {
            "libretro/metadat/no-intro",
            "NEC - PC Engine SuperGrafx"
          }
        },
        ssId = 105,
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        name = "PC Engine SuperGrafx",
        key = "pces",
        ssParentId = 31
      },
      pcecd = {
        muos = "NEC PC Engine CD",
        libretroThumbFolder = "NEC - PC Engine CD - TurboGrafx-CD",
        dat = {
          {
            "libretro/metadat/redump",
            "NEC - PC Engine CD - TurboGrafx-CD"
          }
        },
        ssId = 114,
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        tgdbId = 4955,
        name = "PC Engine CD-ROM²",
        key = "pcecd",
        ssParentId = 31
      },
      channelf = {
        tgdbId = 4928,
        extensions = {
          "bin",
          "rom"
        },
        ssId = 80,
        muos = "Fairchild Channel F",
        name = "Fairchild ChannelF",
        libretroThumbFolder = "Fairchild - Channel F",
        key = "channelf",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Fairchild - Channel F"
          }
        }
      },
      pico8 = {
        ssParentId = 234,
        muos = "PICO-8",
        extensions = {
          "p8",
          "png"
        },
        dat = {
          {
            "libretro/dat",
            "PICO-8"
          }
        },
        key = "pico8",
        name = "Pico-8"
      },
      cdi = {
        tgdbId = 4917,
        extensions = {
          "chd"
        },
        ssId = 133,
        muos = "Philips CDi",
        name = "Philips CD-i",
        libretroThumbFolder = "Philips - CD-i",
        key = "cdi",
        dat = {
          {
            "libretro/metadat/redump",
            "Philips - CD-i"
          }
        }
      },
      pokemini = {
        tgdbId = 4957,
        extensions = {
          "min"
        },
        ssId = 211,
        muos = "Nintendo Pokemon Mini",
        name = "Nintendo - Pokemon Mini",
        libretroThumbFolder = "Nintendo - Pokemon Mini",
        key = "pokemini",
        dat = {
          {
            "libretro/metadat/homebrew",
            "Nintendo - Pokemon Mini.dat"
          },
          {
            "libretro/metadat/no-intro",
            "Nintendo - Pokemon Mini.dat"
          }
        }
      },
      cpc = {
        prefer = {
          "libretro-dats"
        },
        muos = "Amstrad",
        libretroThumbFolder = "Amstrad - CPC",
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
        ssId = 65,
        extensions = {
          "cdt",
          "cpc",
          "cpr",
          "dsk",
          "m3u",
          "tap"
        },
        tgdbId = 4914,
        key = "cpc",
        name = "Amstrad CPC"
      },
      psx = {
        prefer = {
          "redump"
        },
        muos = "Sony PlayStation",
        libretroThumbFolder = "Sony - PlayStation",
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
        ssId = 57,
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
        tgdbId = 10,
        key = "psx",
        name = "Sony PlayStation"
      },
      dreamcast = {
        prefer = {
          "redump"
        },
        muos = "Sega Dreamcast",
        libretroThumbFolder = "Sega - Dreamcast",
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
        ssId = 23,
        extensions = {
          "cdi",
          "chd",
          "cue",
          "gdi",
          "iso",
          "m3u"
        },
        tgdbId = 16,
        key = "dreamcast",
        name = "SEGA Dreamcast"
      },
      psp = {
        tgdbId = 13,
        extensions = {
          "chd",
          "cso",
          "iso",
          "pbp"
        },
        ssId = 61,
        muos = "Sony PlayStation Portable",
        name = "Sony PlayStation Portable",
        libretroThumbFolder = "Sony - PlayStation Portable",
        key = "psp",
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
        }
      },
      fds = {
        muos = "Nintendo Famicon Disk System",
        libretroThumbFolder = "Nintendo - Family Computer Disk System",
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
        ssId = 106,
        extensions = {
          "fds",
          "nes"
        },
        tgdbId = 4936,
        name = "Nintendo - Famicom Disk System",
        key = "fds",
        ssParentId = 3
      },
      x1 = {
        prefer = {
          "no-intro"
        },
        muos = "Sharp X1",
        libretroThumbFolder = "Sharp - X1",
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
        ssId = 220,
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
        tgdbId = 4977,
        key = "x1",
        name = "Sharp X1"
      },
      saturn = {
        tgdbId = 17,
        extensions = {
          "chd",
          "cue",
          "iso",
          "m3u",
          "mdf"
        },
        ssId = 22,
        muos = "Sega Saturn",
        name = "SEGA Saturn",
        libretroThumbFolder = "Sega - Saturn",
        key = "saturn",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Saturn"
          }
        }
      },
      nes = {
        prefer = {
          "no-intro",
          "libretro-dats"
        },
        muos = "Nintendo NES - Famicom",
        libretroThumbFolder = "Nintendo - Nintendo Entertainment System",
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
        ssId = 3,
        extensions = {
          "fig",
          "mgd",
          "nes",
          "sfc",
          "smc",
          "swc"
        },
        tgdbId = 7,
        key = "nes",
        name = "Nintendo - Entertainment System"
      },
      gb = {
        prefer = {
          "no-intro"
        },
        muos = "Nintendo Game Boy",
        libretroThumbFolder = "Nintendo - Game Boy",
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
        ssId = 9,
        extensions = {
          "gb"
        },
        tgdbId = 4,
        key = "gb",
        name = "Nintendo - Gameboy"
      },
      scummvm = {
        muos = "ScummVM",
        libretroThumbFolder = "ScummVM",
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
        ssId = 123,
        extensions = {
          "scummvm",
          "svm"
        },
        name = "ScummVM",
        key = "scummvm",
        ssParentId = 135
      },
      sega32x = {
        prefer = {
          "no-intro"
        },
        muos = "Sega 32X",
        libretroThumbFolder = "Sega - 32X",
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
        ssId = 19,
        extensions = {
          "32x",
          "bin",
          "md",
          "smd"
        },
        tgdbId = 33,
        ssParentId = 1,
        key = "sega32x",
        name = "SEGA 32X"
      },
      gba = {
        prefer = {
          "no-intro"
        },
        muos = "Nintendo Game Boy Advance",
        libretroThumbFolder = "Nintendo - Game Boy Advance",
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
        ssId = 12,
        extensions = {
          "gba"
        },
        tgdbId = 5,
        key = "gba",
        name = "Nintendo - Game Boy Advance"
      },
      gbc = {
        prefer = {
          "no-intro"
        },
        muos = "Nintendo Game Boy Color",
        libretroThumbFolder = "Nintendo - Game Boy Color",
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
        ssId = 10,
        extensions = {
          "gbc",
          "gb"
        },
        tgdbId = 41,
        ssParentId = 9,
        key = "gbc",
        name = "Nintendo - Game Boy Color"
      },
      sg1000 = {
        muos = "Sega SG-1000",
        libretroThumbFolder = "Sega - SG-1000",
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
        ssId = 109,
        extensions = {
          "bin",
          "sg"
        },
        tgdbId = 4949,
        name = "SEGA SG-1000",
        key = "sg1000",
        ssParentId = 2
      },
      gg = {
        prefer = {
          "no-intro"
        },
        muos = "Sega Game Gear",
        libretroThumbFolder = "Sega - Game Gear",
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
        ssId = 21,
        extensions = {
          "bin",
          "gg",
          "sms"
        },
        tgdbId = 20,
        key = "gg",
        name = "SEGA Game Gear"
      },
      sms = {
        tgdbId = 35,
        extensions = {
          "bin",
          "sms"
        },
        ssId = 2,
        muos = "Sega Master System",
        name = "SEGA Master System",
        libretroThumbFolder = "Sega - Master System - Mark III",
        key = "sms",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Sega - Master System - Mark III"
          }
        }
      },
      snes = {
        tgdbId = 6,
        extensions = {
          "bin",
          "bs",
          "fig",
          "mgd",
          "sfc",
          "smc",
          "swc"
        },
        ssId = 4,
        muos = "Nintendo SNES - SFC",
        name = "Nintendo - SNES",
        libretroThumbFolder = "Nintendo - Super Nintendo Entertainment System",
        key = "snes",
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
        }
      },
      spectrum = {
        tgdbId = 4913,
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
        ssId = 76,
        muos = "Sinclair ZX Spectrum",
        name = "ZX Spectrum",
        libretroThumbFolder = "Sinclair - ZX Spectrum",
        key = "spectrum",
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
        }
      },
      intv = {
        prefer = {
          "no-intro"
        },
        muos = "Mattel - Intellivision",
        libretroThumbFolder = "Mattel - Intellivision",
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
        ssId = 115,
        extensions = {
          "bin",
          "int",
          "itv",
          "rom"
        },
        tgdbId = 32,
        key = "intv",
        name = "Mattel Intellivision"
      },
      zx81 = {
        tgdbId = 5010,
        extensions = {
          "p",
          "t81",
          "tzx"
        },
        ssId = 77,
        muos = "Sinclair ZX 81",
        name = "Sinclair ZX81",
        libretroThumbFolder = "Sinclair - ZX 81",
        key = "zx81",
        dat = {
          {
            "libretro/dat",
            "Sinclair - ZX 81"
          }
        }
      },
      arcade = {
        muos = "Arcade",
        libretroThumbFolder = "MAME",
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
        ssId = 75,
        extensions = {
          "bin",
          "cue",
          "dat",
          "fba",
          "iso",
          "zip"
        },
        tgdbId = 23,
        key = "arcade",
        alternate = {
          "fbneo"
        },
        name = "Arcade"
      },
      n64 = {
        prefer = {
          "no-intro"
        },
        muos = "Nintendo N64",
        libretroThumbFolder = "Nintendo - Nintendo 64",
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
        ssId = 14,
        extensions = {
          "n64",
          "v64",
          "z64"
        },
        tgdbId = 3,
        key = "n64",
        name = "Nintendo - 64"
      },
      jaguar = {
        prefer = {
          "no-intro"
        },
        muos = "Atari Jaguar",
        libretroThumbFolder = "Atari - Jaguar",
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
        ssId = 27,
        extensions = {
          "chd",
          "cue",
          "j64",
          "jag"
        },
        tgdbId = 28,
        key = "jaguar",
        name = "Atari Jaguar"
      },
      amiga = {
        prefer = {
          "whdload",
          "libretro-dats",
          "no-intro"
        },
        muos = "Commodore Amiga",
        libretroThumbFolder = "Commodore - Amiga",
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
        ssId = 64,
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
        tgdbId = 4911,
        key = "amiga",
        name = "Commodore Amiga"
      },
      atari2600 = {
        prefer = {
          "no-intro"
        },
        muos = "Atari 2600",
        libretroThumbFolder = "Atari - 2600",
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
        ssId = 26,
        extensions = {
          "a26",
          "bin",
          "gz",
          "rom"
        },
        tgdbId = 22,
        key = "atari2600",
        name = "Atari 2600"
      },
      atari5200 = {
        prefer = {
          "no-intro"
        },
        muos = "Atari 5200",
        libretroThumbFolder = "Atari - 5200",
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
        ssId = 40,
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
        tgdbId = 26,
        key = "atari5200",
        name = "Atari 5200"
      },
      naomi2 = {
        muos = "Naomi 2",
        libretroThumbFolder = "Sega - Naomi 2",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi 2.dat"
          }
        },
        ssId = 230,
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        ssParentId = 75,
        key = "naomi2",
        alternate = {
          "naomi"
        },
        name = "SEGA Naomi 2"
      },
      j2me = {
        extensions = {
          "jar"
        },
        tgdbId = 5018,
        muos = "Java J2ME",
        key = "j2me",
        name = "Java J2ME-Platform"
      },
      mdcd = {
        tgdbId = 21,
        extensions = {
          "chd",
          "cue",
          "iso",
          "m3u"
        },
        ssId = 20,
        muos = "Sega Mega CD - Sega CD",
        name = "SEGA Mega-CD",
        libretroThumbFolder = "Sega - Mega-CD - Sega CD",
        key = "mdcd",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Mega-CD - Sega CD"
          }
        }
      },
      supervision = {
        tgdbId = 4959,
        extensions = {
          "bin",
          "sv"
        },
        ssId = 207,
        muos = "Watara Supervision",
        name = "Watara Supervision",
        libretroThumbFolder = "Watara - Supervision",
        key = "supervision",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Watara - Supervision"
          }
        }
      },
      ndsi = {
        muos = "Nintendo DS",
        libretroThumbFolder = "Nintendo - Nintendo DSi",
        dat = {
          {
            "libretro/metadat/no-intro",
            "/Nintendo - Nintendo DSi.dat"
          }
        },
        ssId = 15,
        extensions = {
          "nds"
        },
        tgdbId = 8,
        key = "ndsi",
        alternate = {
          "nds"
        },
        name = "Nintendo - DSi"
      },
      lynx = {
        prefer = {
          "no-intro"
        },
        muos = "Atari Lynx",
        libretroThumbFolder = "Atari - Lynx",
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
        ssId = 28,
        extensions = {
          "lnx"
        },
        tgdbId = 4924,
        key = "lynx",
        name = "Atari Lynx"
      },
      neogeo = {
        muos = "SNK Neo Geo",
        libretroThumbFolder = "SNK - Neo Geo",
        dat = {
          {
            "libretro/dat",
            "SNK - Neo Geo.dat"
          }
        },
        ssId = 142,
        extensions = {
          "chd",
          "cue",
          "fba",
          "iso",
          "zip"
        },
        tgdbId = 24,
        name = "SNK Neo Geo",
        key = "neogeo",
        ssParentId = 75
      },
      tic80 = {
        extensions = {
          "tic"
        },
        ssId = 222,
        muos = "TIC-80",
        name = "TIC-80 Tiny Computer",
        libretroThumbFolder = "TIC-80",
        key = "tic80",
        dat = {
          {
            "libretro/dat",
            "TIC-80"
          }
        }
      },
      atari7800 = {
        prefer = {
          "no-intro",
          "headered"
        },
        muos = "Atari 7800",
        libretroThumbFolder = "Atari - 7800",
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
        ssId = 41,
        extensions = {
          "a78",
          "bin"
        },
        tgdbId = 27,
        key = "atari7800",
        name = "Atari 7800"
      },
      gx4000 = {
        muos = "Amstrad",
        libretroThumbFolder = "Amstrad - GX4000",
        dat = {
          {
            "libretro/metadat/tosec",
            "Amstrad - GX4000"
          }
        },
        ssId = 87,
        extensions = {
          "cpr",
          "bin"
        },
        tgdbId = 4999,
        name = "Amstrad GX4000",
        key = "gx4000",
        ssParentId = 65
      },
      md = {
        prefer = {
          "no-intro"
        },
        muos = "Sega Mega Drive - Genesis",
        libretroThumbFolder = "Sega - Mega Drive - Genesis",
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
        ssId = 1,
        extensions = {
          "bin",
          "gen",
          "md",
          "sg",
          "smd"
        },
        tgdbId = {
          36,
          18
        },
        key = "md",
        name = "SEGA Megadrive"
      },
      vb = {
        tgdbId = 4918,
        extensions = {
          "vb"
        },
        ssId = 11,
        muos = "Nintendo Virtual Boy",
        name = "Nintendo - Virtual Boy",
        libretroThumbFolder = "Nintendo - Virtual Boy",
        key = "vb",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Nintendo - Virtual Boy"
          }
        }
      },
      nds = {
        prefer = {
          "no-intro"
        },
        muos = "Nintendo DS",
        libretroThumbFolder = "Nintendo - Nintendo DS",
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
        ssId = 15,
        extensions = {
          "nds"
        },
        tgdbId = 8,
        key = "nds",
        alternate = {
          "ndsi"
        },
        name = "Nintendo - DS"
      },
      gw = {
        tgdbId = 4950,
        ssId = 52,
        muos = "Handheld Electronic - Game and Watch",
        extensions = {
          "mgw"
        },
        dat = {
          {
            "no-intro/No-Intro",
            "Nintendo - Game & Watch"
          }
        },
        key = "gw",
        name = "Nintendo - Game & Watch"
      },
      vectrex = {
        tgdbId = 4939,
        extensions = {
          "bin",
          "gam",
          "vec"
        },
        ssId = 102,
        muos = "GCE Vectrex",
        name = "GCE Vectrex",
        libretroThumbFolder = "GCE - Vectrex",
        key = "vectrex",
        dat = {
          {
            "libretro/metadat/no-intro",
            "GCE - Vectrex"
          }
        }
      },
      msx = {
        muos = "Microsoft MSX",
        libretroThumbFolder = "Microsoft - MSX",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX.dat"
          }
        },
        ssId = 113,
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
        key = "msx",
        alternate = {
          "msx2"
        },
        name = "MSX Computer"
      }
    }
  }

return M
