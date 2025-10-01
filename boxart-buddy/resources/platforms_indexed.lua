-- DO NOT EDIT THIS CODE IT IS GENERATED AUTOMATICALLY
local M = {
    byKey = {
      msx = {
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
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX.dat"
          }
        },
        libretroThumbFolder = "Microsoft - MSX",
        name = "MSX Computer",
        muos = "Microsoft MSX",
        ssId = 113,
        tgdbId = 4929,
        alternate = {
          "msx2"
        }
      },
      channelf = {
        muos = "Fairchild ChannelF",
        key = "channelf",
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
        name = "Fairchild ChannelF"
      },
      cdi = {
        muos = "Philips CDi",
        key = "cdi",
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
        name = "Philips CD-i"
      },
      msx2 = {
        extensions = {
          "col",
          "dsk",
          "mx1",
          "mx2",
          "rom"
        },
        key = "msx2",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX2.dat"
          }
        },
        libretroThumbFolder = "Microsoft - MSX2",
        name = "MSX2 Computer",
        muos = "Microsoft - MSX",
        ssId = 116,
        tgdbId = 4929,
        ssParentId = 113,
        alternate = {
          "msx"
        }
      },
      cpc = {
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
        libretroThumbFolder = "Amstrad - CPC",
        name = "Amstrad CPC",
        muos = "Amstrad",
        ssId = 65,
        tgdbId = 4914,
        key = "cpc"
      },
      n64 = {
        extensions = {
          "n64",
          "v64",
          "z64"
        },
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
        libretroThumbFolder = "Nintendo - Nintendo 64",
        name = "Nintendo - 64",
        muos = "Nintendo N64",
        ssId = 14,
        tgdbId = 3,
        key = "n64"
      },
      ["3do"] = {
        muos = "The 3DO Company - 3DO",
        key = "3do",
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
        name = "Panasonic 3DO"
      },
      dreamcast = {
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
        libretroThumbFolder = "Sega - Dreamcast",
        name = "SEGA Dreamcast",
        muos = "Sega Dreamcast",
        ssId = 23,
        tgdbId = 16,
        key = "dreamcast"
      },
      fds = {
        extensions = {
          "fds",
          "nes"
        },
        key = "fds",
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
        libretroThumbFolder = "Nintendo - Family Computer Disk System",
        name = "Nintendo - Famicom Disk System",
        muos = "Nintendo Famicon Disk System",
        ssId = 106,
        tgdbId = 4936,
        ssParentId = 3
      },
      x1 = {
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
        libretroThumbFolder = "Sharp - X1",
        name = "Sharp X1",
        muos = "Sharp X1",
        ssId = 220,
        tgdbId = 4977,
        key = "x1"
      },
      a800 = {
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
        prefer = {
          "no-intro"
        },
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
        libretroThumbFolder = "Atari - 8-bit",
        key = "a800",
        name = "Atari 8-bit Family"
      },
      nds = {
        extensions = {
          "nds"
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
        libretroThumbFolder = "Nintendo - Nintendo DS",
        name = "Nintendo - DS",
        muos = "Nintendo DS",
        ssId = 15,
        tgdbId = 8,
        key = "nds",
        alternate = {
          "ndsi"
        }
      },
      gb = {
        extensions = {
          "gb"
        },
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
        libretroThumbFolder = "Nintendo - Game Boy",
        name = "Nintendo - Gameboy",
        muos = "Nintendo Game Boy",
        ssId = 9,
        tgdbId = 4,
        key = "gb"
      },
      ndsi = {
        extensions = {
          "nds"
        },
        key = "ndsi",
        dat = {
          {
            "libretro/metadat/no-intro",
            "/Nintendo - Nintendo DSi.dat"
          }
        },
        libretroThumbFolder = "Nintendo - Nintendo DSi",
        name = "Nintendo - DSi",
        muos = "Nintendo DS",
        ssId = 15,
        tgdbId = 8,
        alternate = {
          "nds"
        }
      },
      gba = {
        extensions = {
          "gba"
        },
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
        libretroThumbFolder = "Nintendo - Game Boy Advance",
        name = "Nintendo - Game Boy Advance",
        muos = "Nintendo Game Boy Advance",
        ssId = 12,
        tgdbId = 5,
        key = "gba"
      },
      neogeo = {
        extensions = {
          "chd",
          "cue",
          "fba",
          "iso",
          "zip"
        },
        key = "neogeo",
        dat = {
          {
            "libretro/dat",
            "SNK - Neo Geo.dat"
          }
        },
        libretroThumbFolder = "SNK - Neo Geo",
        name = "SNK Neo Geo",
        muos = "SNK Neo Geo",
        ssId = 142,
        tgdbId = 24,
        ssParentId = 75
      },
      gbc = {
        extensions = {
          "gbc",
          "gb"
        },
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
        libretroThumbFolder = "Nintendo - Game Boy Color",
        name = "Nintendo - Game Boy Color",
        muos = "Nintendo Game Boy Color",
        ssId = 10,
        tgdbId = 41,
        ssParentId = 9,
        key = "gbc"
      },
      gg = {
        extensions = {
          "bin",
          "gg",
          "sms"
        },
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
        libretroThumbFolder = "Sega - Game Gear",
        name = "SEGA Game Gear",
        muos = "Sega Game Gear",
        ssId = 21,
        tgdbId = 20,
        key = "gg"
      },
      sms = {
        muos = "Sega Master System",
        key = "sms",
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
        name = "SEGA Master System"
      },
      gw = {
        muos = "Handheld Electronic - Game and Watch",
        key = "gw",
        dat = {
          {
            "no-intro/No-Intro",
            "Nintendo - Game & Watch"
          }
        },
        tgdbId = 4950,
        ssId = 52,
        extensions = {
          "mgw"
        },
        name = "Nintendo - Game & Watch"
      },
      atari2600 = {
        extensions = {
          "a26",
          "bin",
          "gz",
          "rom"
        },
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
        libretroThumbFolder = "Atari - 2600",
        name = "Atari 2600",
        muos = "Atari 2600",
        ssId = 26,
        tgdbId = 22,
        key = "atari2600"
      },
      ngp = {
        extensions = {
          "ngp"
        },
        key = "ngp",
        dat = {
          {
            "libretro/metadat/no-intro",
            "SNK - Neo Geo Pocket.dat"
          }
        },
        libretroThumbFolder = "SNK - Neo Geo Pocket",
        name = "Neo Geo Pocket",
        muos = "SNK Neo Geo Pocket - Color",
        ssId = 25,
        tgdbId = 4922,
        ssParentId = 82,
        alternate = {
          "ngpc"
        }
      },
      atari7800 = {
        extensions = {
          "a78",
          "bin"
        },
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
        libretroThumbFolder = "Atari - 7800",
        name = "Atari 7800",
        muos = "Atari 7800",
        ssId = 41,
        tgdbId = 27,
        key = "atari7800"
      },
      ngpc = {
        extensions = {
          "ngc"
        },
        key = "ngpc",
        dat = {
          {
            "libretro/metadat/no-intro",
            "SNK - Neo Geo Pocket Color.dat"
          }
        },
        libretroThumbFolder = "SNK - Neo Geo Pocket Color",
        name = "Neo Geo Pocket Color",
        muos = "SNK Neo Geo Pocket - Color",
        ssId = 82,
        tgdbId = 4923,
        alternate = {
          "ngpc"
        }
      },
      amiga = {
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
        libretroThumbFolder = "Commodore - Amiga",
        name = "Commodore Amiga",
        muos = "Commodore Amiga",
        ssId = 64,
        tgdbId = 4911,
        key = "amiga"
      },
      openbor = {
        muos = "OpenBOR",
        key = "openbor",
        ssId = 214,
        extensions = {
          "bor",
          "pak"
        },
        name = "OpenBOR"
      },
      odyssey2 = {
        muos = "Odyssey2 - VideoPac",
        key = "odyssey2",
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
        name = "Magnavox Odyssey - Videopac"
      },
      pce = {
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
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
        libretroThumbFolder = "NEC - PC Engine - TurboGrafx 16",
        name = "PC Engine",
        muos = "NEC PC Engine",
        ssId = 31,
        tgdbId = 34,
        key = "pce"
      },
      supervision = {
        muos = "Watara Supervision",
        key = "supervision",
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
        name = "Watara Supervision"
      },
      pces = {
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        key = "pces",
        dat = {
          {
            "libretro/metadat/no-intro",
            "NEC - PC Engine SuperGrafx"
          }
        },
        libretroThumbFolder = "NEC - PC Engine SuperGrafx",
        name = "PC Engine SuperGrafx",
        muos = "NEC PC Engine SuperGrafx",
        ssId = 105,
        ssParentId = 31
      },
      tic80 = {
        muos = "TIC-80",
        key = "tic80",
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
        name = "TIC-80 Tiny Computer"
      },
      arcade = {
        extensions = {
          "bin",
          "cue",
          "dat",
          "fba",
          "iso",
          "zip"
        },
        key = "arcade",
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
        libretroThumbFolder = "MAME",
        name = "Arcade",
        muos = "Arcade",
        ssId = 75,
        tgdbId = 23,
        alternate = {
          "fbneo"
        }
      },
      pcecd = {
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        key = "pcecd",
        dat = {
          {
            "libretro/metadat/redump",
            "NEC - PC Engine CD - TurboGrafx-CD"
          }
        },
        libretroThumbFolder = "NEC - PC Engine CD - TurboGrafx-CD",
        name = "PC Engine CD-ROM²",
        muos = "NEC PC Engine CD",
        ssId = 114,
        tgdbId = 4955,
        ssParentId = 31
      },
      vb = {
        muos = "Nintendo Virtual Boy",
        key = "vb",
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
        name = "Nintendo - Virtual Boy"
      },
      vectrex = {
        muos = "GCE-Vectrex",
        key = "vectrex",
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
        name = "GCE Vectrex"
      },
      pokemini = {
        muos = "Nintendo Pokemon Mini",
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
        },
        tgdbId = 4957,
        ssId = 211,
        libretroThumbFolder = "Nintendo - Pokemon Mini",
        extensions = {
          "min"
        },
        name = "Nintendo - Pokemon Mini"
      },
      ws = {
        muos = "Bandai WonderSwan Color",
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
        },
        tgdbId = 4925,
        ssId = 45,
        libretroThumbFolder = "Bandai - WonderSwan",
        extensions = {
          "ws"
        },
        name = "WonderSwan"
      },
      gx4000 = {
        extensions = {
          "cpr",
          "bin"
        },
        key = "gx4000",
        dat = {
          {
            "libretro/metadat/tosec",
            "Amstrad - GX4000"
          }
        },
        libretroThumbFolder = "Amstrad - GX4000",
        name = "Amstrad GX4000",
        muos = "Amstrad",
        ssId = 87,
        tgdbId = 4999,
        ssParentId = 65
      },
      wsc = {
        extensions = {
          "wsc"
        },
        key = "wsc",
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
        libretroThumbFolder = "Bandai - WonderSwan Color",
        name = "WonderSwan Color",
        muos = "Bandai WonderSwan Color",
        ssId = 46,
        tgdbId = 4926,
        ssParentId = 45
      },
      fbneo = {
        extensions = {
          "bin",
          "cue",
          "dat",
          "fba",
          "iso",
          "zip"
        },
        key = "fbneo",
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
        libretroThumbFolder = "FBNeo - Arcade Games",
        name = "Arcade (FB NEO)",
        muos = "Arcade",
        ssId = 75,
        tgdbId = 23,
        alternate = {
          "arcade"
        }
      },
      jaguar = {
        extensions = {
          "chd",
          "cue",
          "j64",
          "jag"
        },
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
        libretroThumbFolder = "Atari - Jaguar",
        name = "Atari Jaguar",
        muos = "Atari Jaguar",
        ssId = 27,
        tgdbId = 28,
        key = "jaguar"
      },
      psp = {
        muos = "Sony PlayStation Portable",
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
        name = "Sony PlayStation Portable"
      },
      arduboy = {
        extensions = {
          "hex",
          "arduboy"
        },
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
        libretroThumbFolder = "Arduboy Inc - Arduboy",
        name = "Arduboy",
        muos = "Arduboy",
        ssId = 263,
        key = "arduboy"
      },
      neocd = {
        muos = "SNK Neo Geo CD",
        key = "neocd",
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
        name = "SNK Neo Geo CD"
      },
      j2me = {
        muos = "Java J2ME",
        key = "j2me",
        tgdbId = 5018,
        extensions = {
          "jar"
        },
        name = "Java J2ME-Platform"
      },
      snes = {
        muos = "Nintendo SNES - SFC",
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
        name = "Nintendo - SNES"
      },
      atomiswave = {
        alternate = {
          "arcade",
          "fbneo",
          "naomi"
        },
        key = "atomiswave",
        dat = {
          {
            "libretro/dat",
            "Atomiswave"
          }
        },
        libretroThumbFolder = "Atomiswave",
        name = "Atomiswave",
        muos = "Sega Atomiswave Naomi",
        ssId = 53,
        ssParentId = 75,
        extensions = {
          "bin",
          "chd",
          "dat",
          "zip"
        }
      },
      x68000 = {
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
        libretroThumbFolder = "Sharp - X68000",
        name = "Sharp X68000",
        muos = "Sharp X68000",
        ssId = 79,
        tgdbId = 4931,
        key = "x68000"
      },
      saturn = {
        muos = "Sega Saturn",
        key = "saturn",
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
        name = "SEGA Saturn"
      },
      naomi = {
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        key = "naomi",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi.dat"
          }
        },
        libretroThumbFolder = "Sega - Naomi",
        name = "SEGA Naomi",
        muos = "Naomi",
        ssId = 56,
        ssParentId = 75,
        alternate = {
          "naomi2"
        }
      },
      mdcd = {
        muos = "Sega Mega CD - Sega CD",
        key = "mdcd",
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
        name = "SEGA Mega-CD"
      },
      zx81 = {
        muos = "Sinclair ZX 81",
        key = "zx81",
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
        name = "Sinclair ZX81"
      },
      scummvm = {
        extensions = {
          "scummvm",
          "svm"
        },
        key = "scummvm",
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
        libretroThumbFolder = "ScummVM",
        name = "ScummVM",
        muos = "ScummVM",
        ssId = 123,
        ssParentId = 135
      },
      md = {
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
        libretroThumbFolder = "Sega - Mega Drive - Genesis",
        name = "SEGA Megadrive",
        muos = "Sega Mega Drive - Genesis",
        ssId = 1,
        tgdbId = {
          36,
          18
        },
        key = "md"
      },
      nes = {
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
        libretroThumbFolder = "Nintendo - Nintendo Entertainment System",
        name = "Nintendo - Entertainment System",
        muos = "Nintendo NES - Famicom",
        ssId = 3,
        tgdbId = 7,
        key = "nes"
      },
      sega32x = {
        extensions = {
          "32x",
          "bin",
          "md",
          "smd"
        },
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
        libretroThumbFolder = "Sega - 32X",
        name = "SEGA 32X",
        muos = "Sega 32X",
        ssId = 19,
        tgdbId = 33,
        ssParentId = 1,
        key = "sega32x"
      },
      atari5200 = {
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
        libretroThumbFolder = "Atari - 5200",
        name = "Atari 5200",
        muos = "Atari 5200",
        ssId = 40,
        tgdbId = 26,
        key = "atari5200"
      },
      naomi2 = {
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        key = "naomi2",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi 2.dat"
          }
        },
        libretroThumbFolder = "Sega - Naomi 2",
        name = "SEGA Naomi 2",
        muos = "Naomi 2",
        ssId = 230,
        ssParentId = 75,
        alternate = {
          "naomi"
        }
      },
      c64 = {
        muos = "Commodore C64",
        key = "c64",
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
        name = "Commodore 64"
      },
      lynx = {
        extensions = {
          "lnx"
        },
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
        libretroThumbFolder = "Atari - Lynx",
        name = "Atari Lynx",
        muos = "Atari Lynx",
        ssId = 28,
        tgdbId = 4924,
        key = "lynx"
      },
      sg1000 = {
        extensions = {
          "bin",
          "sg"
        },
        key = "sg1000",
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
        libretroThumbFolder = "Sega - SG-1000",
        name = "SEGA SG-1000",
        muos = "Sega SG-1000",
        ssId = 109,
        tgdbId = 4949,
        ssParentId = 2
      },
      psx = {
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
        libretroThumbFolder = "Sony - PlayStation",
        name = "Sony PlayStation",
        muos = "Sony PlayStation",
        ssId = 57,
        tgdbId = 10,
        key = "psx"
      },
      intv = {
        extensions = {
          "bin",
          "int",
          "itv",
          "rom"
        },
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
        libretroThumbFolder = "Mattel - Intellivision",
        name = "Mattel Intellivision",
        muos = "Mattel - Intellivision",
        ssId = 115,
        tgdbId = 32,
        key = "intv"
      },
      pico8 = {
        muos = "PICO-8",
        key = "pico8",
        dat = {
          {
            "libretro/dat",
            "PICO-8"
          }
        },
        ssParentId = 234,
        extensions = {
          "p8",
          "png"
        },
        name = "Pico-8"
      },
      megaduck = {
        muos = "Mega Duck - Cougar Boy",
        key = "megaduck",
        ssId = 90,
        tgdbId = 4948,
        extensions = {
          "bin"
        },
        name = "Mega Duck"
      },
      spectrum = {
        muos = "Sinclair ZX Spectrum",
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
        name = "ZX Spectrum"
      }
    },
    byMuos = {
      openbor = {
        muos = "OpenBOR",
        key = "openbor",
        ssId = 214,
        extensions = {
          "bor",
          "pak"
        },
        name = "OpenBOR"
      },
      ["watara supervision"] = {
        muos = "Watara Supervision",
        key = "supervision",
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
        name = "Watara Supervision"
      },
      ["atari lynx"] = {
        extensions = {
          "lnx"
        },
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
        libretroThumbFolder = "Atari - Lynx",
        name = "Atari Lynx",
        muos = "Atari Lynx",
        ssId = 28,
        tgdbId = 4924,
        key = "lynx"
      },
      ["the 3do company - 3do"] = {
        muos = "The 3DO Company - 3DO",
        key = "3do",
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
        name = "Panasonic 3DO"
      },
      ["pico-8"] = {
        muos = "PICO-8",
        key = "pico8",
        dat = {
          {
            "libretro/dat",
            "PICO-8"
          }
        },
        ssParentId = 234,
        extensions = {
          "p8",
          "png"
        },
        name = "Pico-8"
      },
      ["handheld electronic - game and watch"] = {
        muos = "Handheld Electronic - Game and Watch",
        key = "gw",
        dat = {
          {
            "no-intro/No-Intro",
            "Nintendo - Game & Watch"
          }
        },
        tgdbId = 4950,
        ssId = 52,
        extensions = {
          "mgw"
        },
        name = "Nintendo - Game & Watch"
      },
      ["sega saturn"] = {
        muos = "Sega Saturn",
        key = "saturn",
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
        name = "SEGA Saturn"
      },
      ["sony playstation portable"] = {
        muos = "Sony PlayStation Portable",
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
        name = "Sony PlayStation Portable"
      },
      ["sega 32x"] = {
        extensions = {
          "32x",
          "bin",
          "md",
          "smd"
        },
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
        libretroThumbFolder = "Sega - 32X",
        name = "SEGA 32X",
        muos = "Sega 32X",
        ssId = 19,
        tgdbId = 33,
        ssParentId = 1,
        key = "sega32x"
      },
      ["commodore amiga"] = {
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
        libretroThumbFolder = "Commodore - Amiga",
        name = "Commodore Amiga",
        muos = "Commodore Amiga",
        ssId = 64,
        tgdbId = 4911,
        key = "amiga"
      },
      ["snk neo geo cd"] = {
        muos = "SNK Neo Geo CD",
        key = "neocd",
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
        name = "SNK Neo Geo CD"
      },
      amstrad = {
        extensions = {
          "cpr",
          "bin"
        },
        key = "gx4000",
        dat = {
          {
            "libretro/metadat/tosec",
            "Amstrad - GX4000"
          }
        },
        libretroThumbFolder = "Amstrad - GX4000",
        name = "Amstrad GX4000",
        muos = "Amstrad",
        ssId = 87,
        tgdbId = 4999,
        ssParentId = 65
      },
      ["mattel - intellivision"] = {
        extensions = {
          "bin",
          "int",
          "itv",
          "rom"
        },
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
        libretroThumbFolder = "Mattel - Intellivision",
        name = "Mattel Intellivision",
        muos = "Mattel - Intellivision",
        ssId = 115,
        tgdbId = 32,
        key = "intv"
      },
      arcade = {
        extensions = {
          "bin",
          "cue",
          "dat",
          "fba",
          "iso",
          "zip"
        },
        key = "fbneo",
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
        libretroThumbFolder = "FBNeo - Arcade Games",
        name = "Arcade (FB NEO)",
        muos = "Arcade",
        ssId = 75,
        tgdbId = 23,
        alternate = {
          "arcade"
        }
      },
      ["atari 5200"] = {
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
        libretroThumbFolder = "Atari - 5200",
        name = "Atari 5200",
        muos = "Atari 5200",
        ssId = 40,
        tgdbId = 26,
        key = "atari5200"
      },
      ["nintendo ds"] = {
        extensions = {
          "nds"
        },
        key = "ndsi",
        dat = {
          {
            "libretro/metadat/no-intro",
            "/Nintendo - Nintendo DSi.dat"
          }
        },
        libretroThumbFolder = "Nintendo - Nintendo DSi",
        name = "Nintendo - DSi",
        muos = "Nintendo DS",
        ssId = 15,
        tgdbId = 8,
        alternate = {
          "nds"
        }
      },
      ["snk neo geo"] = {
        extensions = {
          "chd",
          "cue",
          "fba",
          "iso",
          "zip"
        },
        key = "neogeo",
        dat = {
          {
            "libretro/dat",
            "SNK - Neo Geo.dat"
          }
        },
        libretroThumbFolder = "SNK - Neo Geo",
        name = "SNK Neo Geo",
        muos = "SNK Neo Geo",
        ssId = 142,
        tgdbId = 24,
        ssParentId = 75
      },
      ["sega dreamcast"] = {
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
        libretroThumbFolder = "Sega - Dreamcast",
        name = "SEGA Dreamcast",
        muos = "Sega Dreamcast",
        ssId = 23,
        tgdbId = 16,
        key = "dreamcast"
      },
      ["philips cdi"] = {
        muos = "Philips CDi",
        key = "cdi",
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
        name = "Philips CD-i"
      },
      ["nec pc engine supergrafx"] = {
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        key = "pces",
        dat = {
          {
            "libretro/metadat/no-intro",
            "NEC - PC Engine SuperGrafx"
          }
        },
        libretroThumbFolder = "NEC - PC Engine SuperGrafx",
        name = "PC Engine SuperGrafx",
        muos = "NEC PC Engine SuperGrafx",
        ssId = 105,
        ssParentId = 31
      },
      ["atari jaguar"] = {
        extensions = {
          "chd",
          "cue",
          "j64",
          "jag"
        },
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
        libretroThumbFolder = "Atari - Jaguar",
        name = "Atari Jaguar",
        muos = "Atari Jaguar",
        ssId = 27,
        tgdbId = 28,
        key = "jaguar"
      },
      ["sinclair zx 81"] = {
        muos = "Sinclair ZX 81",
        key = "zx81",
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
        name = "Sinclair ZX81"
      },
      ["tic-80"] = {
        muos = "TIC-80",
        key = "tic80",
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
        name = "TIC-80 Tiny Computer"
      },
      ["commodore c64"] = {
        muos = "Commodore C64",
        key = "c64",
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
        name = "Commodore 64"
      },
      ["sinclair zx spectrum"] = {
        muos = "Sinclair ZX Spectrum",
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
        name = "ZX Spectrum"
      },
      ["java j2me"] = {
        muos = "Java J2ME",
        key = "j2me",
        tgdbId = 5018,
        extensions = {
          "jar"
        },
        name = "Java J2ME-Platform"
      },
      ["sharp x1"] = {
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
        libretroThumbFolder = "Sharp - X1",
        name = "Sharp X1",
        muos = "Sharp X1",
        ssId = 220,
        tgdbId = 4977,
        key = "x1"
      },
      ["naomi 2"] = {
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        key = "naomi2",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi 2.dat"
          }
        },
        libretroThumbFolder = "Sega - Naomi 2",
        name = "SEGA Naomi 2",
        muos = "Naomi 2",
        ssId = 230,
        ssParentId = 75,
        alternate = {
          "naomi"
        }
      },
      ["nintendo n64"] = {
        extensions = {
          "n64",
          "v64",
          "z64"
        },
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
        libretroThumbFolder = "Nintendo - Nintendo 64",
        name = "Nintendo - 64",
        muos = "Nintendo N64",
        ssId = 14,
        tgdbId = 3,
        key = "n64"
      },
      ["nintendo virtual boy"] = {
        muos = "Nintendo Virtual Boy",
        key = "vb",
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
        name = "Nintendo - Virtual Boy"
      },
      ["atari 7800"] = {
        extensions = {
          "a78",
          "bin"
        },
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
        libretroThumbFolder = "Atari - 7800",
        name = "Atari 7800",
        muos = "Atari 7800",
        ssId = 41,
        tgdbId = 27,
        key = "atari7800"
      },
      ["nintendo snes - sfc"] = {
        muos = "Nintendo SNES - SFC",
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
        name = "Nintendo - SNES"
      },
      ["sega master system"] = {
        muos = "Sega Master System",
        key = "sms",
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
        name = "SEGA Master System"
      },
      ["nintendo famicon disk system"] = {
        extensions = {
          "fds",
          "nes"
        },
        key = "fds",
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
        libretroThumbFolder = "Nintendo - Family Computer Disk System",
        name = "Nintendo - Famicom Disk System",
        muos = "Nintendo Famicon Disk System",
        ssId = 106,
        tgdbId = 4936,
        ssParentId = 3
      },
      ["odyssey2 - videopac"] = {
        muos = "Odyssey2 - VideoPac",
        key = "odyssey2",
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
        name = "Magnavox Odyssey - Videopac"
      },
      ["sega mega cd - sega cd"] = {
        muos = "Sega Mega CD - Sega CD",
        key = "mdcd",
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
        name = "SEGA Mega-CD"
      },
      ["sony playstation"] = {
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
        libretroThumbFolder = "Sony - PlayStation",
        name = "Sony PlayStation",
        muos = "Sony PlayStation",
        ssId = 57,
        tgdbId = 10,
        key = "psx"
      },
      arduboy = {
        extensions = {
          "hex",
          "arduboy"
        },
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
        libretroThumbFolder = "Arduboy Inc - Arduboy",
        name = "Arduboy",
        muos = "Arduboy",
        ssId = 263,
        key = "arduboy"
      },
      ["nintendo game boy"] = {
        extensions = {
          "gb"
        },
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
        libretroThumbFolder = "Nintendo - Game Boy",
        name = "Nintendo - Gameboy",
        muos = "Nintendo Game Boy",
        ssId = 9,
        tgdbId = 4,
        key = "gb"
      },
      ["nintendo game boy advance"] = {
        extensions = {
          "gba"
        },
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
        libretroThumbFolder = "Nintendo - Game Boy Advance",
        name = "Nintendo - Game Boy Advance",
        muos = "Nintendo Game Boy Advance",
        ssId = 12,
        tgdbId = 5,
        key = "gba"
      },
      ["sega game gear"] = {
        extensions = {
          "bin",
          "gg",
          "sms"
        },
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
        libretroThumbFolder = "Sega - Game Gear",
        name = "SEGA Game Gear",
        muos = "Sega Game Gear",
        ssId = 21,
        tgdbId = 20,
        key = "gg"
      },
      ["nec pc engine cd"] = {
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
        key = "pcecd",
        dat = {
          {
            "libretro/metadat/redump",
            "NEC - PC Engine CD - TurboGrafx-CD"
          }
        },
        libretroThumbFolder = "NEC - PC Engine CD - TurboGrafx-CD",
        name = "PC Engine CD-ROM²",
        muos = "NEC PC Engine CD",
        ssId = 114,
        tgdbId = 4955,
        ssParentId = 31
      },
      ["nintendo game boy color"] = {
        extensions = {
          "gbc",
          "gb"
        },
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
        libretroThumbFolder = "Nintendo - Game Boy Color",
        name = "Nintendo - Game Boy Color",
        muos = "Nintendo Game Boy Color",
        ssId = 10,
        tgdbId = 41,
        ssParentId = 9,
        key = "gbc"
      },
      ["atari 2600"] = {
        extensions = {
          "a26",
          "bin",
          "gz",
          "rom"
        },
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
        libretroThumbFolder = "Atari - 2600",
        name = "Atari 2600",
        muos = "Atari 2600",
        ssId = 26,
        tgdbId = 22,
        key = "atari2600"
      },
      naomi = {
        extensions = {
          "bin",
          "chd",
          "dat"
        },
        key = "naomi",
        dat = {
          {
            "libretro/metadat/redump",
            "Sega - Naomi.dat"
          }
        },
        libretroThumbFolder = "Sega - Naomi",
        name = "SEGA Naomi",
        muos = "Naomi",
        ssId = 56,
        ssParentId = 75,
        alternate = {
          "naomi2"
        }
      },
      ["microsoft - msx"] = {
        extensions = {
          "col",
          "dsk",
          "mx1",
          "mx2",
          "rom"
        },
        key = "msx2",
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX2.dat"
          }
        },
        libretroThumbFolder = "Microsoft - MSX2",
        name = "MSX2 Computer",
        muos = "Microsoft - MSX",
        ssId = 116,
        tgdbId = 4929,
        ssParentId = 113,
        alternate = {
          "msx"
        }
      },
      ["sega mega drive - genesis"] = {
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
        libretroThumbFolder = "Sega - Mega Drive - Genesis",
        name = "SEGA Megadrive",
        muos = "Sega Mega Drive - Genesis",
        ssId = 1,
        tgdbId = {
          36,
          18
        },
        key = "md"
      },
      ["nintendo nes - famicom"] = {
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
        libretroThumbFolder = "Nintendo - Nintendo Entertainment System",
        name = "Nintendo - Entertainment System",
        muos = "Nintendo NES - Famicom",
        ssId = 3,
        tgdbId = 7,
        key = "nes"
      },
      ["sega atomiswave naomi"] = {
        alternate = {
          "arcade",
          "fbneo",
          "naomi"
        },
        key = "atomiswave",
        dat = {
          {
            "libretro/dat",
            "Atomiswave"
          }
        },
        libretroThumbFolder = "Atomiswave",
        name = "Atomiswave",
        muos = "Sega Atomiswave Naomi",
        ssId = 53,
        ssParentId = 75,
        extensions = {
          "bin",
          "chd",
          "dat",
          "zip"
        }
      },
      ["sharp x68000"] = {
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
        libretroThumbFolder = "Sharp - X68000",
        name = "Sharp X68000",
        muos = "Sharp X68000",
        ssId = 79,
        tgdbId = 4931,
        key = "x68000"
      },
      ["gce-vectrex"] = {
        muos = "GCE-Vectrex",
        key = "vectrex",
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
        name = "GCE Vectrex"
      },
      ["fairchild channelf"] = {
        muos = "Fairchild ChannelF",
        key = "channelf",
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
        name = "Fairchild ChannelF"
      },
      ["bandai wonderswan color"] = {
        extensions = {
          "wsc"
        },
        key = "wsc",
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
        libretroThumbFolder = "Bandai - WonderSwan Color",
        name = "WonderSwan Color",
        muos = "Bandai WonderSwan Color",
        ssId = 46,
        tgdbId = 4926,
        ssParentId = 45
      },
      ["nec pc engine"] = {
        extensions = {
          "ccd",
          "chd",
          "cue",
          "pce"
        },
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
        libretroThumbFolder = "NEC - PC Engine - TurboGrafx 16",
        name = "PC Engine",
        muos = "NEC PC Engine",
        ssId = 31,
        tgdbId = 34,
        key = "pce"
      },
      ["snk neo geo pocket - color"] = {
        extensions = {
          "ngc"
        },
        key = "ngpc",
        dat = {
          {
            "libretro/metadat/no-intro",
            "SNK - Neo Geo Pocket Color.dat"
          }
        },
        libretroThumbFolder = "SNK - Neo Geo Pocket Color",
        name = "Neo Geo Pocket Color",
        muos = "SNK Neo Geo Pocket - Color",
        ssId = 82,
        tgdbId = 4923,
        alternate = {
          "ngpc"
        }
      },
      ["microsoft msx"] = {
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
        dat = {
          {
            "libretro/metadat/no-intro",
            "Microsoft - MSX.dat"
          }
        },
        libretroThumbFolder = "Microsoft - MSX",
        name = "MSX Computer",
        muos = "Microsoft MSX",
        ssId = 113,
        tgdbId = 4929,
        alternate = {
          "msx2"
        }
      },
      ["sega sg-1000"] = {
        extensions = {
          "bin",
          "sg"
        },
        key = "sg1000",
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
        libretroThumbFolder = "Sega - SG-1000",
        name = "SEGA SG-1000",
        muos = "Sega SG-1000",
        ssId = 109,
        tgdbId = 4949,
        ssParentId = 2
      },
      scummvm = {
        extensions = {
          "scummvm",
          "svm"
        },
        key = "scummvm",
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
        libretroThumbFolder = "ScummVM",
        name = "ScummVM",
        muos = "ScummVM",
        ssId = 123,
        ssParentId = 135
      },
      ["nintendo pokemon mini"] = {
        muos = "Nintendo Pokemon Mini",
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
        },
        tgdbId = 4957,
        ssId = 211,
        libretroThumbFolder = "Nintendo - Pokemon Mini",
        extensions = {
          "min"
        },
        name = "Nintendo - Pokemon Mini"
      },
      ["mega duck - cougar boy"] = {
        muos = "Mega Duck - Cougar Boy",
        key = "megaduck",
        ssId = 90,
        tgdbId = 4948,
        extensions = {
          "bin"
        },
        name = "Mega Duck"
      }
    }
  }

return M
