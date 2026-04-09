-- DO NOT EDIT THIS CODE IT IS GENERATED AUTOMATICALLY
local M = {
    byKey = {
      arcade = {
        alternate = {
          "fbneo"
        },
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
        libretroThumbFolder = "MAME",
        tgdbId = 23,
        muos = "Arcade",
        ssId = 75
      },
      openbor = {
        name = "OpenBOR",
        ssId = 214,
        muos = "OpenBOR",
        extensions = {
          "bor",
          "pak"
        },
        key = "openbor"
      },
      mdcd = {
        name = "SEGA Mega-CD",
        tgdbId = 21,
        libretroThumbFolder = "Sega - Mega-CD - Sega CD",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Mega-CD - Sega CD"
          }
        },
        ssId = 20,
        extensions = {
          "chd",
          "cue",
          "iso",
          "m3u"
        },
        muos = "Sega Mega CD - Sega CD",
        key = "mdcd"
      },
      odyssey2 = {
        name = "Magnavox Odyssey - Videopac",
        tgdbId = {
          4961,
          4927
        },
        libretroThumbFolder = "Magnavox - Odyssey2",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Magnavox - Odyssey2.dat"
          }
        },
        ssId = 104,
        extensions = {
          "bin"
        },
        muos = "Odyssey2 - VideoPac",
        key = "odyssey2"
      },
      megaduck = {
        name = "Mega Duck",
        tgdbId = 4948,
        ssId = 90,
        muos = "Mega Duck - Cougar Boy",
        extensions = {
          "bin"
        },
        key = "megaduck"
      },
      msx = {
        alternate = {
          "msx2"
        },
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX.dat"
          }
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
        key = "msx",
        name = "MSX Computer",
        libretroThumbFolder = "Microsoft - MSX",
        tgdbId = 4929,
        muos = "Microsoft MSX",
        ssId = 113
      },
      msx2 = {
        alternate = {
          "msx"
        },
        ssParentId = 113,
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX2.dat"
          }
        },
        extensions = {
          "col",
          "dsk",
          "mx1",
          "mx2",
          "rom"
        },
        key = "msx2",
        name = "MSX2 Computer",
        libretroThumbFolder = "Microsoft - MSX2",
        tgdbId = 4929,
        muos = "Microsoft - MSX",
        ssId = 116
      },
      fbneo = {
        alternate = {
          "arcade"
        },
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
        extensions = {
          "bin",
          "cue",
          "dat",
          "fba",
          "iso",
          "zip"
        },
        key = "fbneo",
        name = "Arcade (FB NEO)",
        libretroThumbFolder = "FBNeo - Arcade Games",
        tgdbId = 23,
        muos = "Arcade",
        ssId = 75
      },
      pcecd = {
        tgdbId = 4955,
        ssParentId = 31,
        dat = {
          {
            "libretro/metadat/redump",
            "NEC - PC Engine CD - TurboGrafx-CD"
          }
        },
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        key = "pcecd",
        name = "PC Engine CD-ROM²",
        libretroThumbFolder = "NEC - PC Engine CD - TurboGrafx-CD",
        muos = "NEC PC Engine CD",
        ssId = 114
      },
      n64 = {
        tgdbId = 3,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "n64",
          "v64",
          "z64"
        },
        key = "n64",
        name = "Nintendo - 64",
        libretroThumbFolder = "Nintendo - Nintendo 64",
        muos = "Nintendo N64",
        ssId = 14
      },
      pico8 = {
        name = "Pico-8",
        ssParentId = 234,
        dat = {
          {
            "libretro/dat",
            "PICO-8"
          }
        },
        extensions = {
          "p8",
          "png"
        },
        muos = "PICO-8",
        key = "pico8"
      },
      arduboy = {
        prefer = {
          "libretro-dats"
        },
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
        key = "arduboy",
        name = "Arduboy",
        libretroThumbFolder = "Arduboy Inc - Arduboy",
        muos = "Arduboy",
        ssId = 263
      },
      pokemini = {
        name = "Nintendo - Pokemon Mini",
        tgdbId = 4957,
        libretroThumbFolder = "Nintendo - Pokemon Mini",
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
        ssId = 211,
        extensions = {
          "min"
        },
        muos = "Nintendo Pokemon Mini",
        key = "pokemini"
      },
      atomiswave = {
        alternate = {
          "arcade",
          "fbneo",
          "naomi"
        },
        ssParentId = 75,
        dat = {
          {
            "libretro/dat",
            "Atomiswave"
          }
        },
        extensions = {
          "bin",
          "chd",
          "dat",
          "zip"
        },
        key = "atomiswave",
        name = "Atomiswave",
        libretroThumbFolder = "Atomiswave",
        muos = "Sega Atomiswave Naomi",
        ssId = 53
      },
      psx = {
        tgdbId = 10,
        prefer = {
          "redump"
        },
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
        key = "psx",
        name = "Sony PlayStation",
        libretroThumbFolder = "Sony - PlayStation",
        muos = "Sony PlayStation",
        ssId = 57
      },
      a800 = {
        name = "Atari 8-bit Family",
        prefer = {
          "no-intro"
        },
        libretroThumbFolder = "Atari - 8-bit",
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
        key = "a800"
      },
      c64 = {
        name = "Commodore 64",
        tgdbId = 40,
        libretroThumbFolder = "Commodore - 64",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Commodore - 64"
          }
        },
        ssId = 66,
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
        muos = "Commodore C64",
        key = "c64"
      },
      nds = {
        alternate = {
          "ndsi"
        },
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "nds"
        },
        key = "nds",
        name = "Nintendo - DS",
        libretroThumbFolder = "Nintendo - Nintendo DS",
        tgdbId = 8,
        muos = "Nintendo DS",
        ssId = 15
      },
      psp = {
        name = "Sony PlayStation Portable",
        tgdbId = 13,
        libretroThumbFolder = "Sony - PlayStation Portable",
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
        ssId = 61,
        extensions = {
          "chd",
          "cso",
          "iso",
          "pbp"
        },
        muos = "Sony PlayStation Portable",
        key = "psp"
      },
      ndsi = {
        alternate = {
          "nds"
        },
        dat = {
          {
            "libretro/metadat/no-intro",
            "/Nintendo - Nintendo DSi.dat"
          }
        },
        extensions = {
          "nds"
        },
        key = "ndsi",
        name = "Nintendo - DSi",
        libretroThumbFolder = "Nintendo - Nintendo DSi",
        tgdbId = 8,
        muos = "Nintendo DS",
        ssId = 15
      },
      saturn = {
        name = "SEGA Saturn",
        tgdbId = 17,
        libretroThumbFolder = "Sega - Saturn",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Saturn"
          }
        },
        ssId = 22,
        extensions = {
          "chd",
          "cue",
          "iso",
          "m3u",
          "mdf"
        },
        muos = "Sega Saturn",
        key = "saturn"
      },
      channelf = {
        name = "Fairchild ChannelF",
        tgdbId = 4928,
        libretroThumbFolder = "Fairchild - Channel F",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Fairchild - Channel F"
          }
        },
        ssId = 80,
        extensions = {
          "bin",
          "rom"
        },
        muos = "Fairchild Channel F",
        key = "channelf"
      },
      scummvm = {
        ssParentId = 135,
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
        extensions = {
          "scummvm",
          "svm"
        },
        key = "scummvm",
        name = "ScummVM",
        libretroThumbFolder = "ScummVM",
        muos = "ScummVM",
        ssId = 123
      },
      cdi = {
        name = "Philips CD-i",
        tgdbId = 4917,
        libretroThumbFolder = "Philips - CD-i",
        dat = {
          {
            "libretro/metadat/redump",
            "Philips - CD-i"
          }
        },
        ssId = 133,
        extensions = {
          "chd"
        },
        muos = "Philips CDi",
        key = "cdi"
      },
      sega32x = {
        tgdbId = 33,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "32x",
          "bin",
          "md",
          "smd"
        },
        key = "sega32x",
        name = "SEGA 32X",
        libretroThumbFolder = "Sega - 32X",
        ssParentId = 1,
        muos = "Sega 32X",
        ssId = 19
      },
      cpc = {
        tgdbId = 4914,
        prefer = {
          "libretro-dats"
        },
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
        extensions = {
          "cdt",
          "cpc",
          "cpr",
          "dsk",
          "m3u",
          "tap"
        },
        key = "cpc",
        name = "Amstrad CPC",
        libretroThumbFolder = "Amstrad - CPC",
        muos = "Amstrad",
        ssId = 65
      },
      sg1000 = {
        tgdbId = 4949,
        ssParentId = 2,
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
        extensions = {
          "bin",
          "sg"
        },
        key = "sg1000",
        name = "SEGA SG-1000",
        libretroThumbFolder = "Sega - SG-1000",
        muos = "Sega SG-1000",
        ssId = 109
      },
      ngp = {
        alternate = {
          "ngpc"
        },
        ssParentId = 82,
        dat = {
          {
            "libretro/metadat/no-intro",
            "SNK - Neo Geo Pocket.dat"
          }
        },
        extensions = {
          "ngp"
        },
        key = "ngp",
        name = "Neo Geo Pocket",
        libretroThumbFolder = "SNK - Neo Geo Pocket",
        tgdbId = 4922,
        muos = "SNK Neo Geo Pocket - Color",
        ssId = 25
      },
      dreamcast = {
        tgdbId = 16,
        prefer = {
          "redump"
        },
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
        extensions = {
          "cdi",
          "chd",
          "cue",
          "gdi",
          "iso",
          "m3u"
        },
        key = "dreamcast",
        name = "SEGA Dreamcast",
        libretroThumbFolder = "Sega - Dreamcast",
        muos = "Sega Dreamcast",
        ssId = 23
      },
      spectrum = {
        name = "ZX Spectrum",
        tgdbId = 4913,
        libretroThumbFolder = "Sinclair - ZX Spectrum",
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
        ssId = 76,
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
        muos = "Sinclair ZX Spectrum",
        key = "spectrum"
      },
      fds = {
        tgdbId = 4936,
        ssParentId = 3,
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
        extensions = {
          "fds",
          "nes"
        },
        key = "fds",
        name = "Nintendo - Famicom Disk System",
        libretroThumbFolder = "Nintendo - Family Computer Disk System",
        muos = "Nintendo Famicon Disk System",
        ssId = 106
      },
      nes = {
        tgdbId = 7,
        prefer = {
          "no-intro",
          "libretro-dats"
        },
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
        extensions = {
          "fig",
          "mgd",
          "nes",
          "sfc",
          "smc",
          "swc"
        },
        key = "nes",
        name = "Nintendo - Entertainment System",
        libretroThumbFolder = "Nintendo - Nintendo Entertainment System",
        muos = "Nintendo NES - Famicom",
        ssId = 3
      },
      gb = {
        tgdbId = 4,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "gb",
          "gba",
          "gbc"
        },
        key = "gb",
        name = "Nintendo - Gameboy",
        libretroThumbFolder = "Nintendo - Game Boy",
        muos = "Nintendo Game Boy",
        ssId = 9
      },
      gba = {
        tgdbId = 5,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "gb",
          "gba",
          "gbc"
        },
        key = "gba",
        name = "Nintendo - Game Boy Advance",
        libretroThumbFolder = "Nintendo - Game Boy Advance",
        muos = "Nintendo Game Boy Advance",
        ssId = 12
      },
      supervision = {
        name = "Watara Supervision",
        tgdbId = 4959,
        libretroThumbFolder = "Watara - Supervision",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Watara - Supervision"
          }
        },
        ssId = 207,
        extensions = {
          "bin",
          "sv"
        },
        muos = "Watara Supervision",
        key = "supervision"
      },
      tic80 = {
        name = "TIC-80 Tiny Computer",
        libretroThumbFolder = "TIC-80",
        dat = {
          {
            "libretro/dat",
            "TIC-80"
          }
        },
        ssId = 222,
        extensions = {
          "tic"
        },
        muos = "TIC-80",
        key = "tic80"
      },
      gg = {
        tgdbId = 20,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "bin",
          "gg",
          "sms"
        },
        key = "gg",
        name = "SEGA Game Gear",
        libretroThumbFolder = "Sega - Game Gear",
        muos = "Sega Game Gear",
        ssId = 21
      },
      vb = {
        name = "Nintendo - Virtual Boy",
        tgdbId = 4918,
        libretroThumbFolder = "Nintendo - Virtual Boy",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Nintendo - Virtual Boy"
          }
        },
        ssId = 11,
        extensions = {
          "vb"
        },
        muos = "Nintendo Virtual Boy",
        key = "vb"
      },
      x1 = {
        tgdbId = 4977,
        prefer = {
          "no-intro"
        },
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
        key = "x1",
        name = "Sharp X1",
        libretroThumbFolder = "Sharp - X1",
        muos = "Sharp X1",
        ssId = 220
      },
      atari2600 = {
        tgdbId = 22,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "a26",
          "bin",
          "gz",
          "rom"
        },
        key = "atari2600",
        name = "Atari 2600",
        libretroThumbFolder = "Atari - 2600",
        muos = "Atari 2600",
        ssId = 26
      },
      vectrex = {
        name = "GCE Vectrex",
        tgdbId = 4939,
        libretroThumbFolder = "GCE - Vectrex",
        dat = {
          {
            "libretro/metadat/no-intro",
            "GCE - Vectrex"
          }
        },
        ssId = 102,
        extensions = {
          "bin",
          "gam",
          "vec"
        },
        muos = "GCE Vectrex",
        key = "vectrex"
      },
      pc98 = {
        name = "NEC PC98",
        libretroThumbFolder = "NEC - PC-98",
        tgdbId = 4934,
        ssId = 208,
        extensions = {
          "d98",
          "zip",
          "98d",
          "fdi",
          "fdd",
          "2hd",
          "tfd",
          "d88",
          "88d",
          "hdm",
          "xdf",
          "dup",
          "cmd",
          "hdi",
          "thd",
          "nhd",
          "hdd",
          "hdn"
        },
        muos = "NEC PC98",
        key = "pc98"
      },
      atari5200 = {
        tgdbId = 26,
        prefer = {
          "no-intro"
        },
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
        key = "atari5200",
        name = "Atari 5200",
        libretroThumbFolder = "Atari - 5200",
        muos = "Atari 5200",
        ssId = 40
      },
      ws = {
        name = "WonderSwan",
        tgdbId = 4925,
        libretroThumbFolder = "Bandai - WonderSwan",
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
        ssId = 45,
        extensions = {
          "ws"
        },
        muos = "Bandai WonderSwan Color",
        key = "ws"
      },
      dos = {
        name = "DOS",
        libretroThumbFolder = "DOS",
        tgdbId = 1,
        ssId = 135,
        extensions = {
          "zip",
          "7z",
          "iso",
          "exe",
          "sh"
        },
        muos = "PC DOS",
        key = "dos"
      },
      intv = {
        tgdbId = 32,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "bin",
          "int",
          "itv",
          "rom"
        },
        key = "intv",
        name = "Mattel Intellivision",
        libretroThumbFolder = "Mattel - Intellivision",
        muos = "Mattel - Intellivision",
        ssId = 115
      },
      zx81 = {
        name = "Sinclair ZX81",
        tgdbId = 5010,
        libretroThumbFolder = "Sinclair - ZX 81",
        dat = {
          {
            "libretro/dat",
            "Sinclair - ZX 81"
          }
        },
        ssId = 77,
        extensions = {
          "p",
          "t81",
          "tzx"
        },
        muos = "Sinclair ZX 81",
        key = "zx81"
      },
      atari7800 = {
        tgdbId = 27,
        prefer = {
          "no-intro",
          "headered"
        },
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
        extensions = {
          "a78",
          "bin"
        },
        key = "atari7800",
        name = "Atari 7800",
        libretroThumbFolder = "Atari - 7800",
        muos = "Atari 7800",
        ssId = 41
      },
      wsc = {
        tgdbId = 4926,
        ssParentId = 45,
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
        extensions = {
          "wsc"
        },
        key = "wsc",
        name = "WonderSwan Color",
        libretroThumbFolder = "Bandai - WonderSwan Color",
        muos = "Bandai WonderSwan Color",
        ssId = 46
      },
      jaguar = {
        tgdbId = 28,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "chd",
          "cue",
          "j64",
          "jag"
        },
        key = "jaguar",
        name = "Atari Jaguar",
        libretroThumbFolder = "Atari - Jaguar",
        muos = "Atari Jaguar",
        ssId = 27
      },
      naomi = {
        alternate = {
          "naomi2"
        },
        ssParentId = 75,
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi.dat"
          }
        },
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        key = "naomi",
        name = "SEGA Naomi",
        libretroThumbFolder = "Sega - Naomi",
        muos = "Naomi",
        ssId = 56
      },
      amiga = {
        tgdbId = 4911,
        prefer = {
          "whdload",
          "libretro-dats",
          "no-intro"
        },
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
        key = "amiga",
        name = "Commodore Amiga",
        libretroThumbFolder = "Commodore - Amiga",
        muos = "Commodore Amiga",
        ssId = 64
      },
      sms = {
        name = "SEGA Master System",
        tgdbId = 35,
        libretroThumbFolder = "Sega - Master System - Mark III",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Sega - Master System - Mark III"
          }
        },
        ssId = 2,
        extensions = {
          "bin",
          "sms"
        },
        muos = "Sega Master System",
        key = "sms"
      },
      ["3do"] = {
        name = "Panasonic 3DO",
        tgdbId = 25,
        libretroThumbFolder = "The 3DO Company - 3DO",
        dat = {
          {
            "libretro/metadat/redump/",
            "The 3DO Company"
          }
        },
        ssId = 29,
        extensions = {
          "chd",
          "cue",
          "iso"
        },
        muos = "The 3DO Company - 3DO",
        key = "3do"
      },
      gw = {
        name = "Nintendo - Game & Watch",
        tgdbId = 4950,
        dat = {
          {
            "no-intro/No-Intro",
            "Nintendo - Game & Watch"
          }
        },
        ssId = 52,
        extensions = {
          "mgw"
        },
        muos = "Handheld Electronic - Game and Watch",
        key = "gw"
      },
      j2me = {
        name = "Java J2ME-Platform",
        tgdbId = 5018,
        muos = "Java J2ME",
        extensions = {
          "jar"
        },
        key = "j2me"
      },
      gx4000 = {
        tgdbId = 4999,
        ssParentId = 65,
        dat = {
          {
            "libretro/metadat/tosec",
            "Amstrad - GX4000"
          }
        },
        extensions = {
          "cpr",
          "bin"
        },
        key = "gx4000",
        name = "Amstrad GX4000",
        libretroThumbFolder = "Amstrad - GX4000",
        muos = "Amstrad",
        ssId = 87
      },
      neogeo = {
        tgdbId = 24,
        ssParentId = 75,
        dat = {
          {
            "libretro/dat",
            "SNK - Neo Geo.dat"
          }
        },
        extensions = {
          "chd",
          "cue",
          "fba",
          "iso",
          "zip"
        },
        key = "neogeo",
        name = "SNK Neo Geo",
        libretroThumbFolder = "SNK - Neo Geo",
        muos = "SNK Neo Geo",
        ssId = 142
      },
      neocd = {
        name = "SNK Neo Geo CD",
        tgdbId = 4956,
        libretroThumbFolder = "SNK - Neo Geo CD",
        dat = {
          {
            "libretro/metadat/redump",
            "SNK - Neo Geo CD"
          }
        },
        ssId = 70,
        extensions = {
          "chd",
          "cue",
          "fba",
          "iso"
        },
        muos = "SNK Neo Geo CD",
        key = "neocd"
      },
      lynx = {
        tgdbId = 4924,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "lnx"
        },
        key = "lynx",
        name = "Atari Lynx",
        libretroThumbFolder = "Atari - Lynx",
        muos = "Atari Lynx",
        ssId = 28
      },
      naomi2 = {
        alternate = {
          "naomi"
        },
        ssParentId = 75,
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi 2.dat"
          }
        },
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        key = "naomi2",
        name = "SEGA Naomi 2",
        libretroThumbFolder = "Sega - Naomi 2",
        muos = "Naomi 2",
        ssId = 230
      },
      x68000 = {
        tgdbId = 4931,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "2hd",
          "d88",
          "dim",
          "hdf",
          "hdm",
          "m3u",
          "xdf"
        },
        key = "x68000",
        name = "Sharp X68000",
        libretroThumbFolder = "Sharp - X68000",
        muos = "Sharp X68000",
        ssId = 79
      },
      pce = {
        tgdbId = 34,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        key = "pce",
        name = "PC Engine",
        libretroThumbFolder = "NEC - PC Engine - TurboGrafx 16",
        muos = "NEC PC Engine",
        ssId = 31
      },
      pces = {
        ssParentId = 31,
        dat = {
          {
            "libretro/metadat/no-intro",
            "NEC - PC Engine SuperGrafx"
          }
        },
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        key = "pces",
        name = "PC Engine SuperGrafx",
        libretroThumbFolder = "NEC - PC Engine SuperGrafx",
        muos = "NEC PC Engine SuperGrafx",
        ssId = 105
      },
      md = {
        tgdbId = {
          36,
          18
        },
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "bin",
          "gen",
          "md",
          "sg",
          "smd"
        },
        key = "md",
        name = "SEGA Megadrive",
        libretroThumbFolder = "Sega - Mega Drive - Genesis",
        muos = "Sega Mega Drive - Genesis",
        ssId = 1
      },
      ngpc = {
        alternate = {
          "ngpc"
        },
        dat = {
          {
            "libretro/metadat/no-intro",
            "SNK - Neo Geo Pocket Color.dat"
          }
        },
        extensions = {
          "ngc"
        },
        key = "ngpc",
        name = "Neo Geo Pocket Color",
        libretroThumbFolder = "SNK - Neo Geo Pocket Color",
        tgdbId = 4923,
        muos = "SNK Neo Geo Pocket - Color",
        ssId = 82
      },
      gbc = {
        tgdbId = 41,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "gb",
          "gba",
          "gbc"
        },
        key = "gbc",
        name = "Nintendo - Game Boy Color",
        libretroThumbFolder = "Nintendo - Game Boy Color",
        ssParentId = 9,
        muos = "Nintendo Game Boy Color",
        ssId = 10
      },
      snes = {
        name = "Nintendo - SNES",
        tgdbId = 6,
        libretroThumbFolder = "Nintendo - Super Nintendo Entertainment System",
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
        ssId = 4,
        extensions = {
          "bin",
          "bs",
          "fig",
          "mgd",
          "sfc",
          "smc",
          "swc"
        },
        muos = "Nintendo SNES - SFC",
        key = "snes"
      }
    },
    byMuos = {
      arcade = {
        alternate = {
          "arcade"
        },
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
        extensions = {
          "bin",
          "cue",
          "dat",
          "fba",
          "iso",
          "zip"
        },
        key = "fbneo",
        name = "Arcade (FB NEO)",
        libretroThumbFolder = "FBNeo - Arcade Games",
        tgdbId = 23,
        muos = "Arcade",
        ssId = 75
      },
      ["fairchild channel f"] = {
        name = "Fairchild ChannelF",
        tgdbId = 4928,
        libretroThumbFolder = "Fairchild - Channel F",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Fairchild - Channel F"
          }
        },
        ssId = 80,
        extensions = {
          "bin",
          "rom"
        },
        muos = "Fairchild Channel F",
        key = "channelf"
      },
      ["mega duck - cougar boy"] = {
        name = "Mega Duck",
        tgdbId = 4948,
        ssId = 90,
        muos = "Mega Duck - Cougar Boy",
        extensions = {
          "bin"
        },
        key = "megaduck"
      },
      ["nintendo snes - sfc"] = {
        name = "Nintendo - SNES",
        tgdbId = 6,
        libretroThumbFolder = "Nintendo - Super Nintendo Entertainment System",
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
        ssId = 4,
        extensions = {
          "bin",
          "bs",
          "fig",
          "mgd",
          "sfc",
          "smc",
          "swc"
        },
        muos = "Nintendo SNES - SFC",
        key = "snes"
      },
      ["nintendo pokemon mini"] = {
        name = "Nintendo - Pokemon Mini",
        tgdbId = 4957,
        libretroThumbFolder = "Nintendo - Pokemon Mini",
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
        ssId = 211,
        extensions = {
          "min"
        },
        muos = "Nintendo Pokemon Mini",
        key = "pokemini"
      },
      ["sega sg-1000"] = {
        tgdbId = 4949,
        ssParentId = 2,
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
        extensions = {
          "bin",
          "sg"
        },
        key = "sg1000",
        name = "SEGA SG-1000",
        libretroThumbFolder = "Sega - SG-1000",
        muos = "Sega SG-1000",
        ssId = 109
      },
      ["atari lynx"] = {
        tgdbId = 4924,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "lnx"
        },
        key = "lynx",
        name = "Atari Lynx",
        libretroThumbFolder = "Atari - Lynx",
        muos = "Atari Lynx",
        ssId = 28
      },
      ["pico-8"] = {
        name = "Pico-8",
        ssParentId = 234,
        dat = {
          {
            "libretro/dat",
            "PICO-8"
          }
        },
        extensions = {
          "p8",
          "png"
        },
        muos = "PICO-8",
        key = "pico8"
      },
      ["handheld electronic - game and watch"] = {
        name = "Nintendo - Game & Watch",
        tgdbId = 4950,
        dat = {
          {
            "no-intro/No-Intro",
            "Nintendo - Game & Watch"
          }
        },
        ssId = 52,
        extensions = {
          "mgw"
        },
        muos = "Handheld Electronic - Game and Watch",
        key = "gw"
      },
      ["sega saturn"] = {
        name = "SEGA Saturn",
        tgdbId = 17,
        libretroThumbFolder = "Sega - Saturn",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Saturn"
          }
        },
        ssId = 22,
        extensions = {
          "chd",
          "cue",
          "iso",
          "m3u",
          "mdf"
        },
        muos = "Sega Saturn",
        key = "saturn"
      },
      ["sony playstation portable"] = {
        name = "Sony PlayStation Portable",
        tgdbId = 13,
        libretroThumbFolder = "Sony - PlayStation Portable",
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
        ssId = 61,
        extensions = {
          "chd",
          "cso",
          "iso",
          "pbp"
        },
        muos = "Sony PlayStation Portable",
        key = "psp"
      },
      ["sega 32x"] = {
        tgdbId = 33,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "32x",
          "bin",
          "md",
          "smd"
        },
        key = "sega32x",
        name = "SEGA 32X",
        libretroThumbFolder = "Sega - 32X",
        ssParentId = 1,
        muos = "Sega 32X",
        ssId = 19
      },
      ["nec pc98"] = {
        name = "NEC PC98",
        libretroThumbFolder = "NEC - PC-98",
        tgdbId = 4934,
        ssId = 208,
        extensions = {
          "d98",
          "zip",
          "98d",
          "fdi",
          "fdd",
          "2hd",
          "tfd",
          "d88",
          "88d",
          "hdm",
          "xdf",
          "dup",
          "cmd",
          "hdi",
          "thd",
          "nhd",
          "hdd",
          "hdn"
        },
        muos = "NEC PC98",
        key = "pc98"
      },
      ["microsoft msx"] = {
        alternate = {
          "msx2"
        },
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX.dat"
          }
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
        key = "msx",
        name = "MSX Computer",
        libretroThumbFolder = "Microsoft - MSX",
        tgdbId = 4929,
        muos = "Microsoft MSX",
        ssId = 113
      },
      openbor = {
        name = "OpenBOR",
        ssId = 214,
        muos = "OpenBOR",
        extensions = {
          "bor",
          "pak"
        },
        key = "openbor"
      },
      ["commodore amiga"] = {
        tgdbId = 4911,
        prefer = {
          "whdload",
          "libretro-dats",
          "no-intro"
        },
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
        key = "amiga",
        name = "Commodore Amiga",
        libretroThumbFolder = "Commodore - Amiga",
        muos = "Commodore Amiga",
        ssId = 64
      },
      ["snk neo geo cd"] = {
        name = "SNK Neo Geo CD",
        tgdbId = 4956,
        libretroThumbFolder = "SNK - Neo Geo CD",
        dat = {
          {
            "libretro/metadat/redump",
            "SNK - Neo Geo CD"
          }
        },
        ssId = 70,
        extensions = {
          "chd",
          "cue",
          "fba",
          "iso"
        },
        muos = "SNK Neo Geo CD",
        key = "neocd"
      },
      amstrad = {
        tgdbId = 4999,
        ssParentId = 65,
        dat = {
          {
            "libretro/metadat/tosec",
            "Amstrad - GX4000"
          }
        },
        extensions = {
          "cpr",
          "bin"
        },
        key = "gx4000",
        name = "Amstrad GX4000",
        libretroThumbFolder = "Amstrad - GX4000",
        muos = "Amstrad",
        ssId = 87
      },
      ["mattel - intellivision"] = {
        tgdbId = 32,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "bin",
          "int",
          "itv",
          "rom"
        },
        key = "intv",
        name = "Mattel Intellivision",
        libretroThumbFolder = "Mattel - Intellivision",
        muos = "Mattel - Intellivision",
        ssId = 115
      },
      ["atari 5200"] = {
        tgdbId = 26,
        prefer = {
          "no-intro"
        },
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
        key = "atari5200",
        name = "Atari 5200",
        libretroThumbFolder = "Atari - 5200",
        muos = "Atari 5200",
        ssId = 40
      },
      ["nintendo ds"] = {
        alternate = {
          "nds"
        },
        dat = {
          {
            "libretro/metadat/no-intro",
            "/Nintendo - Nintendo DSi.dat"
          }
        },
        extensions = {
          "nds"
        },
        key = "ndsi",
        name = "Nintendo - DSi",
        libretroThumbFolder = "Nintendo - Nintendo DSi",
        tgdbId = 8,
        muos = "Nintendo DS",
        ssId = 15
      },
      ["snk neo geo"] = {
        tgdbId = 24,
        ssParentId = 75,
        dat = {
          {
            "libretro/dat",
            "SNK - Neo Geo.dat"
          }
        },
        extensions = {
          "chd",
          "cue",
          "fba",
          "iso",
          "zip"
        },
        key = "neogeo",
        name = "SNK Neo Geo",
        libretroThumbFolder = "SNK - Neo Geo",
        muos = "SNK Neo Geo",
        ssId = 142
      },
      ["sega dreamcast"] = {
        tgdbId = 16,
        prefer = {
          "redump"
        },
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
        extensions = {
          "cdi",
          "chd",
          "cue",
          "gdi",
          "iso",
          "m3u"
        },
        key = "dreamcast",
        name = "SEGA Dreamcast",
        libretroThumbFolder = "Sega - Dreamcast",
        muos = "Sega Dreamcast",
        ssId = 23
      },
      ["philips cdi"] = {
        name = "Philips CD-i",
        tgdbId = 4917,
        libretroThumbFolder = "Philips - CD-i",
        dat = {
          {
            "libretro/metadat/redump",
            "Philips - CD-i"
          }
        },
        ssId = 133,
        extensions = {
          "chd"
        },
        muos = "Philips CDi",
        key = "cdi"
      },
      ["nec pc engine supergrafx"] = {
        ssParentId = 31,
        dat = {
          {
            "libretro/metadat/no-intro",
            "NEC - PC Engine SuperGrafx"
          }
        },
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        key = "pces",
        name = "PC Engine SuperGrafx",
        libretroThumbFolder = "NEC - PC Engine SuperGrafx",
        muos = "NEC PC Engine SuperGrafx",
        ssId = 105
      },
      ["atari jaguar"] = {
        tgdbId = 28,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "chd",
          "cue",
          "j64",
          "jag"
        },
        key = "jaguar",
        name = "Atari Jaguar",
        libretroThumbFolder = "Atari - Jaguar",
        muos = "Atari Jaguar",
        ssId = 27
      },
      ["sinclair zx 81"] = {
        name = "Sinclair ZX81",
        tgdbId = 5010,
        libretroThumbFolder = "Sinclair - ZX 81",
        dat = {
          {
            "libretro/dat",
            "Sinclair - ZX 81"
          }
        },
        ssId = 77,
        extensions = {
          "p",
          "t81",
          "tzx"
        },
        muos = "Sinclair ZX 81",
        key = "zx81"
      },
      ["tic-80"] = {
        name = "TIC-80 Tiny Computer",
        libretroThumbFolder = "TIC-80",
        dat = {
          {
            "libretro/dat",
            "TIC-80"
          }
        },
        ssId = 222,
        extensions = {
          "tic"
        },
        muos = "TIC-80",
        key = "tic80"
      },
      ["commodore c64"] = {
        name = "Commodore 64",
        tgdbId = 40,
        libretroThumbFolder = "Commodore - 64",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Commodore - 64"
          }
        },
        ssId = 66,
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
        muos = "Commodore C64",
        key = "c64"
      },
      naomi = {
        alternate = {
          "naomi2"
        },
        ssParentId = 75,
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi.dat"
          }
        },
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        key = "naomi",
        name = "SEGA Naomi",
        libretroThumbFolder = "Sega - Naomi",
        muos = "Naomi",
        ssId = 56
      },
      ["sharp x1"] = {
        tgdbId = 4977,
        prefer = {
          "no-intro"
        },
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
        key = "x1",
        name = "Sharp X1",
        libretroThumbFolder = "Sharp - X1",
        muos = "Sharp X1",
        ssId = 220
      },
      ["naomi 2"] = {
        alternate = {
          "naomi"
        },
        ssParentId = 75,
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi 2.dat"
          }
        },
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        key = "naomi2",
        name = "SEGA Naomi 2",
        libretroThumbFolder = "Sega - Naomi 2",
        muos = "Naomi 2",
        ssId = 230
      },
      ["nintendo n64"] = {
        tgdbId = 3,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "n64",
          "v64",
          "z64"
        },
        key = "n64",
        name = "Nintendo - 64",
        libretroThumbFolder = "Nintendo - Nintendo 64",
        muos = "Nintendo N64",
        ssId = 14
      },
      ["nintendo virtual boy"] = {
        name = "Nintendo - Virtual Boy",
        tgdbId = 4918,
        libretroThumbFolder = "Nintendo - Virtual Boy",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Nintendo - Virtual Boy"
          }
        },
        ssId = 11,
        extensions = {
          "vb"
        },
        muos = "Nintendo Virtual Boy",
        key = "vb"
      },
      ["atari 7800"] = {
        tgdbId = 27,
        prefer = {
          "no-intro",
          "headered"
        },
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
        extensions = {
          "a78",
          "bin"
        },
        key = "atari7800",
        name = "Atari 7800",
        libretroThumbFolder = "Atari - 7800",
        muos = "Atari 7800",
        ssId = 41
      },
      ["pc dos"] = {
        name = "DOS",
        libretroThumbFolder = "DOS",
        tgdbId = 1,
        ssId = 135,
        extensions = {
          "zip",
          "7z",
          "iso",
          "exe",
          "sh"
        },
        muos = "PC DOS",
        key = "dos"
      },
      ["watara supervision"] = {
        name = "Watara Supervision",
        tgdbId = 4959,
        libretroThumbFolder = "Watara - Supervision",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Watara - Supervision"
          }
        },
        ssId = 207,
        extensions = {
          "bin",
          "sv"
        },
        muos = "Watara Supervision",
        key = "supervision"
      },
      ["sinclair zx spectrum"] = {
        name = "ZX Spectrum",
        tgdbId = 4913,
        libretroThumbFolder = "Sinclair - ZX Spectrum",
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
        ssId = 76,
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
        muos = "Sinclair ZX Spectrum",
        key = "spectrum"
      },
      ["gce vectrex"] = {
        name = "GCE Vectrex",
        tgdbId = 4939,
        libretroThumbFolder = "GCE - Vectrex",
        dat = {
          {
            "libretro/metadat/no-intro",
            "GCE - Vectrex"
          }
        },
        ssId = 102,
        extensions = {
          "bin",
          "gam",
          "vec"
        },
        muos = "GCE Vectrex",
        key = "vectrex"
      },
      ["nintendo famicon disk system"] = {
        tgdbId = 4936,
        ssParentId = 3,
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
        extensions = {
          "fds",
          "nes"
        },
        key = "fds",
        name = "Nintendo - Famicom Disk System",
        libretroThumbFolder = "Nintendo - Family Computer Disk System",
        muos = "Nintendo Famicon Disk System",
        ssId = 106
      },
      ["odyssey2 - videopac"] = {
        name = "Magnavox Odyssey - Videopac",
        tgdbId = {
          4961,
          4927
        },
        libretroThumbFolder = "Magnavox - Odyssey2",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Magnavox - Odyssey2.dat"
          }
        },
        ssId = 104,
        extensions = {
          "bin"
        },
        muos = "Odyssey2 - VideoPac",
        key = "odyssey2"
      },
      ["sega mega cd - sega cd"] = {
        name = "SEGA Mega-CD",
        tgdbId = 21,
        libretroThumbFolder = "Sega - Mega-CD - Sega CD",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Mega-CD - Sega CD"
          }
        },
        ssId = 20,
        extensions = {
          "chd",
          "cue",
          "iso",
          "m3u"
        },
        muos = "Sega Mega CD - Sega CD",
        key = "mdcd"
      },
      ["sony playstation"] = {
        tgdbId = 10,
        prefer = {
          "redump"
        },
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
        key = "psx",
        name = "Sony PlayStation",
        libretroThumbFolder = "Sony - PlayStation",
        muos = "Sony PlayStation",
        ssId = 57
      },
      ["the 3do company - 3do"] = {
        name = "Panasonic 3DO",
        tgdbId = 25,
        libretroThumbFolder = "The 3DO Company - 3DO",
        dat = {
          {
            "libretro/metadat/redump/",
            "The 3DO Company"
          }
        },
        ssId = 29,
        extensions = {
          "chd",
          "cue",
          "iso"
        },
        muos = "The 3DO Company - 3DO",
        key = "3do"
      },
      ["java j2me"] = {
        name = "Java J2ME-Platform",
        tgdbId = 5018,
        muos = "Java J2ME",
        extensions = {
          "jar"
        },
        key = "j2me"
      },
      ["nintendo game boy"] = {
        tgdbId = 4,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "gb",
          "gba",
          "gbc"
        },
        key = "gb",
        name = "Nintendo - Gameboy",
        libretroThumbFolder = "Nintendo - Game Boy",
        muos = "Nintendo Game Boy",
        ssId = 9
      },
      ["nintendo game boy advance"] = {
        tgdbId = 5,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "gb",
          "gba",
          "gbc"
        },
        key = "gba",
        name = "Nintendo - Game Boy Advance",
        libretroThumbFolder = "Nintendo - Game Boy Advance",
        muos = "Nintendo Game Boy Advance",
        ssId = 12
      },
      ["sega master system"] = {
        name = "SEGA Master System",
        tgdbId = 35,
        libretroThumbFolder = "Sega - Master System - Mark III",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Sega - Master System - Mark III"
          }
        },
        ssId = 2,
        extensions = {
          "bin",
          "sms"
        },
        muos = "Sega Master System",
        key = "sms"
      },
      scummvm = {
        ssParentId = 135,
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
        extensions = {
          "scummvm",
          "svm"
        },
        key = "scummvm",
        name = "ScummVM",
        libretroThumbFolder = "ScummVM",
        muos = "ScummVM",
        ssId = 123
      },
      arduboy = {
        prefer = {
          "libretro-dats"
        },
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
        key = "arduboy",
        name = "Arduboy",
        libretroThumbFolder = "Arduboy Inc - Arduboy",
        muos = "Arduboy",
        ssId = 263
      },
      ["sega game gear"] = {
        tgdbId = 20,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "bin",
          "gg",
          "sms"
        },
        key = "gg",
        name = "SEGA Game Gear",
        libretroThumbFolder = "Sega - Game Gear",
        muos = "Sega Game Gear",
        ssId = 21
      },
      ["nec pc engine cd"] = {
        tgdbId = 4955,
        ssParentId = 31,
        dat = {
          {
            "libretro/metadat/redump",
            "NEC - PC Engine CD - TurboGrafx-CD"
          }
        },
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        key = "pcecd",
        name = "PC Engine CD-ROM²",
        libretroThumbFolder = "NEC - PC Engine CD - TurboGrafx-CD",
        muos = "NEC PC Engine CD",
        ssId = 114
      },
      ["nintendo game boy color"] = {
        tgdbId = 41,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "gb",
          "gba",
          "gbc"
        },
        key = "gbc",
        name = "Nintendo - Game Boy Color",
        libretroThumbFolder = "Nintendo - Game Boy Color",
        ssParentId = 9,
        muos = "Nintendo Game Boy Color",
        ssId = 10
      },
      ["atari 2600"] = {
        tgdbId = 22,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "a26",
          "bin",
          "gz",
          "rom"
        },
        key = "atari2600",
        name = "Atari 2600",
        libretroThumbFolder = "Atari - 2600",
        muos = "Atari 2600",
        ssId = 26
      },
      ["microsoft - msx"] = {
        alternate = {
          "msx"
        },
        ssParentId = 113,
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX2.dat"
          }
        },
        extensions = {
          "col",
          "dsk",
          "mx1",
          "mx2",
          "rom"
        },
        key = "msx2",
        name = "MSX2 Computer",
        libretroThumbFolder = "Microsoft - MSX2",
        tgdbId = 4929,
        muos = "Microsoft - MSX",
        ssId = 116
      },
      ["sega mega drive - genesis"] = {
        tgdbId = {
          36,
          18
        },
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "bin",
          "gen",
          "md",
          "sg",
          "smd"
        },
        key = "md",
        name = "SEGA Megadrive",
        libretroThumbFolder = "Sega - Mega Drive - Genesis",
        muos = "Sega Mega Drive - Genesis",
        ssId = 1
      },
      ["nintendo nes - famicom"] = {
        tgdbId = 7,
        prefer = {
          "no-intro",
          "libretro-dats"
        },
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
        extensions = {
          "fig",
          "mgd",
          "nes",
          "sfc",
          "smc",
          "swc"
        },
        key = "nes",
        name = "Nintendo - Entertainment System",
        libretroThumbFolder = "Nintendo - Nintendo Entertainment System",
        muos = "Nintendo NES - Famicom",
        ssId = 3
      },
      ["sega atomiswave naomi"] = {
        alternate = {
          "arcade",
          "fbneo",
          "naomi"
        },
        ssParentId = 75,
        dat = {
          {
            "libretro/dat",
            "Atomiswave"
          }
        },
        extensions = {
          "bin",
          "chd",
          "dat",
          "zip"
        },
        key = "atomiswave",
        name = "Atomiswave",
        libretroThumbFolder = "Atomiswave",
        muos = "Sega Atomiswave Naomi",
        ssId = 53
      },
      ["sharp x68000"] = {
        tgdbId = 4931,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "2hd",
          "d88",
          "dim",
          "hdf",
          "hdm",
          "m3u",
          "xdf"
        },
        key = "x68000",
        name = "Sharp X68000",
        libretroThumbFolder = "Sharp - X68000",
        muos = "Sharp X68000",
        ssId = 79
      },
      ["bandai wonderswan color"] = {
        tgdbId = 4926,
        ssParentId = 45,
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
        extensions = {
          "wsc"
        },
        key = "wsc",
        name = "WonderSwan Color",
        libretroThumbFolder = "Bandai - WonderSwan Color",
        muos = "Bandai WonderSwan Color",
        ssId = 46
      },
      ["nec pc engine"] = {
        tgdbId = 34,
        prefer = {
          "no-intro"
        },
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
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        key = "pce",
        name = "PC Engine",
        libretroThumbFolder = "NEC - PC Engine - TurboGrafx 16",
        muos = "NEC PC Engine",
        ssId = 31
      },
      ["snk neo geo pocket - color"] = {
        alternate = {
          "ngpc"
        },
        dat = {
          {
            "libretro/metadat/no-intro",
            "SNK - Neo Geo Pocket Color.dat"
          }
        },
        extensions = {
          "ngc"
        },
        key = "ngpc",
        name = "Neo Geo Pocket Color",
        libretroThumbFolder = "SNK - Neo Geo Pocket Color",
        tgdbId = 4923,
        muos = "SNK Neo Geo Pocket - Color",
        ssId = 82
      }
    }
  }

return M
