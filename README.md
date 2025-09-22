<div align="center">

![Boxart Buddy](/doc/image/logo.png?raw=true "Boxart Buddy")

**Boxart Buddy** is a ROM artwork scraper and composite image (mix) editor for MuOS, that splits the artwork creation process into four stages. 

SCAN > SCRAPE > MIX > PACK

(It's sort of like [Skraper](https://www.skraper.net) but it runs directly on your handheld)

</div>

***

- **Scan** and verify your roms against a database of known roms using bundled .dat data. (Improves matches when scraping roms)

- **Scrape** artwork from Libretro, Screenscraper.fr and SteamGridDB.com, with support for multi-threading for improved performance.

- **Mix** media together using preset styles or configure your own with the interactive editor.

- **Pack** media into Catalog Packages or install directly into MuOS

- All configuration is done via the app GUI. Very easy to use!

- Browse roms & override individual media with the interactive scraper

- Uses existing MuOS Core assignment to automatically select "platforms" for roms (no manual platform config required)

- Supports all devices, screen resolutions and aspect ratios of MuOS compatible devices. (Anbernic, TrimUI etc.)

- All scanning and scraping code is natively implemented with Lua code and C modules for speed and flexibility.

## Gallery

![Screen 1](/doc/image/screen1.png?raw=true "Screen 1")
![Screen 2](/doc/image/screen2.png?raw=true "Screen 2")
![Screen 3](/doc/image/screen3.png?raw=true "Screen 3")
![Screen 4](/doc/image/screen4.png?raw=true "Screen 4")
![Screen 5](/doc/image/screen5.png?raw=true "Screen 5")
![Screen 6](/doc/image/screen6.png?raw=true "Screen 6")
![Screen 7](/doc/image/screen7.png?raw=true "Screen 7")

# Installation

- Download the [latest release](https://github.com/boxart-buddy/boxart-buddy/releases) and place into the 'Archive' folder on your SD1 card (/ARCHIVE). Use the 'Archive Manager' app to unzip the application.

# Quickstart / First Run

- On first run the app will initialize by creating a backup of the primary database. This takes around 45 seconds. Be patient (screen will hang for ~20 seconds at the end of this process)

- Use l2 & r2 to navigate to the config section. You'll probably want to enter your Screenscraper.fr credentials. (Only increase the number of threads if your screenscraper account supports them!). If you want to scrape 'SteamGridDB' grid images then enter your SteamGridDB API Key and enable the 'grid' media under ```(CONFIG > MEDIA)```. Don't forget to save the config (X Button).

- Navigate back to "HOME" and start a scan ("START" Button) After scan is complete, you can start a "Scrape. (Note: If you want to test a subset of your roms before scanning your whole collection then filter to single system first with "Y Button")". If the scrape process hangs at the end then cancel out of it (with "SELECT"). I'm working on a timeout option for hung requests...

- After Scraping you can check the "stats" under the "ROMS > STATS" section (press "START" in the rom screen) to see if any media is missing. <sup> >*Stat screen currently loads slowly currenly on large romsets</sup>. You can use the filters ("Y" Button) to see which roms have partially or fully missing media. Sometimes running an additional scrape is helpful to rescrape any roms stragglers that failed the first time (e.g timeout or server error). By default only unscraped images will be rescraped.

- On the "MIX" screen you can navigate (l1 & r1) and select ("START" Button) a preset mix type, or use the interactive editor to modify the layout in any way you like. You can save your preset for reuse later. If you want to see how a particular ROM will look you can go back to the ROM screen, navigate to the rom you want and then navigate back to the MIX screen (the last viewed rom on the ROM screen will be used for the preview on the MIX screen).

- The currently select "mix" is indicated with a star icon above the preset name. If you are ready to generate mixes, head back to the HOME screen and press the "GENERATE MIXES" button

- Finally the "PACK IMAGES" button will export images out of the application. You can choose to export images into a "Catalogue Set" (.muxcat) by changing settings in ```(CONFIG > PACK)```.

# Additional Tips

- Note that the "Filter" (in ROMS and HOME) is applied to all actions on the HOME screen (i.e SCRAPE, MIX, PACK). That means you can take actions against a subset of platforms at a time. Be aware of this though (i.e if you run a PACK process while a filter is applied then you will only be exporting a subset of rom images).

- Bail out of a long running process by pressing SELECT

- On the "MIX" screen you can use "Background > Header/Footer" to trim off the top and bottom of the mix image so that it doesn't encroach on the header/footer of your theme. By default these are both set to 42px but you can change them under ```(CONFIG > MIX)```.

- If you want a really simple "mix" (e.g screenshot + box2d), you can disable media types (e.g Wheel/Box3d) that you are not going to use. This will greatly speed up the scrape process ```(CONFIG > MEDIA)```.

- The green shield on the ROMS screen just signifies that the ROM was verified as a known good version against DAT data. This allows access to additional metadata that improves the hit rate when scraping. Roms don't need to be 'verified' to be scraped so don't worry too much about it.

- "Mix" images are generated at the full height/width of the device screen, therefore in the MuOS config you should set (Customisation > Context Box Art) to "Fullscreen + Behind" for best results.

- Is a whole "platform" missing? Make sure that MuOS knows how assign the roms in the folder before "Scanning". You may need to manually set the core for a folder in MuOS first if you don't use a standard name for the folder.

- The "SCAN" process only needs to be rerun if you add/remove roms, or you fix core assignment issues and want to pick up previously missing roms. This process is non destructive, but when scanning previously scanned roms they are first "hidden" and then re-enabled if the rom still exists on the disk. No existing images are removed during this process. If you "quit" the scan process while it is running then roms will appear to be missing, so ideally you should let this process complete fully any time you run it.

- This application can also be run on MacOS (Apple Silicon only). (No Docs right now, check .vscode/launch.json if you are interested). Use the git repository rather than the release (.zip) if you want to run on MacOS.

- You can modify the configuration directly on the filesystem if needed (maybe you have a very long password that you don't want to type out...) by editing `./data/config/config.toml`. This file is created after the first time the application is started (so if you intend to do this then start the app once and then quit it before editing the file)

# Fixing missing media

- If you have a ROM that doesn't match in screenscraper.fr (but you know it exists on the site) you can set an 'id number' which acts as an override to match the ROM directly. ```(ROMS > OPTIONS > SCREENSCRAPER GAME ID)```. You'll find this id in the URL of the game on the screenscraper.fr website (e.g: ....&gameid=2140)

- If you have roms with missing media (e.g a romhack or homebrew) you can provide your own media. First enable the file scraper ```(CONFIG > SCRAPER > FILE SCRAPER)```. Place your image files into a folder under ```~/MUOS/application/BoxartBuddy/data/media/{platform_name}/{rom_name}/{type}.{extension}```.
  - **platform_name:** matches the "key" of the platform [in this file](https://github.com/boxart-buddy/boxart-buddy/blob/master/boxart-buddy/resources/platforms.lua)
  - **rom_name:** case sensitive folder name matching the name of the rom, minus the extension
  - **type:** is one of (screenshot, wheel, box2d, box3d, grid3x2, grid1x1)
  - **extension:** jpg, jpeg or png

<div align="center">

<img src="doc/image/file_scraper_tree.png?raw=true" width="70%">

</div>


# Background, Development & Alternatives

This version of Boxart Buddy has been updated for use with "2508.1 Canada Goose"

This application is under development. Please report any bugs. I would like to add more presets and options to the mix builder. Feedback welcome.

This version is "Pre-Release" so there is a focus on completing features and taking feedback. I'll work on making it more robust if there is enthusiasm from other members of the community.

At present the application doesn't handle failure very well as failure routes are mostly untested. For best results make sure you have a strong internet connection.

**There are other scrapers for MuOS which have different strengths and may suit your needs better**

### [Scrappy](https://github.com/gabrielfvale/scrappy/wiki)

Under the hood uses [Skyscraper](https://github.com/Gemba/skyscraper) so has all the strengths of that application (mature, robust, many scraping backends, can provide your own mixes via XML templates)

### [Artie](https://github.com/milouk/artie)
A minimal scraper written in Python 


# Issues & Logging/Debugging

If you encounter an issue and wish to submit a bug report, please enable file logging ```(CONFIG > LOG)``` at the "debug" level and provide the log file with your bug report (as well as a description of the issue, version of MuOS etc). Note that after changing log settings you need to restart for the changes to take effect. Log files are saved to ~/MUOS/application/BoxartBuddy/data/log.

---

## Third-party components

This project uses code from the following projects:

- **RetroArch / Libretro**  
  Portions of code in `discscanner.so` are derived from RetroArch (`task_database_cue.c`). [https://github.com/libretro/RetroArch](https://github.com/libretro/RetroArch)
- **lua-vips** (MIT) – Lua bindings for libvips. [https://github.com/libvips/lua-vips](https://github.com/libvips/lua-vips)
- **libvips** (LGPL-2.1+) – Image processing library. [https://github.com/libvips/libvips](https://github.com/libvips/libvips)
- **lua-sqlite3** (MIT) – SQLite binding for Lua. [https://lua.sqlite.org/home/index](https://lua.sqlite.org/home/index)
- **lua-archive** (MIT) – libarchive binding for Lua. [https://github.com/brimworks/lua-archive](https://github.com/brimworks/lua-archive) 
- **lua-ezlib** (MIT) – Easy zlib bindings for Lua: [https://github.com/neoxic/lua-ezlib](https://github.com/neoxic/lua-ezlib)
- **LÖVE** (MIT) – The Application framework LOVE. [https://github.com/love2d/love](https://github.com/love2d/love)
- **Batteries** - Helpful library for writing LOVE games & applications [https://github.com/1bardesign/batteries](https://github.com/1bardesign/batteries)
- **xml2lua** - Library for reading XML in Lua [https://github.com/manoelcampos/xml2lua](https://github.com/manoelcampos/xml2lua)
- **Cargo** - Lightweight asset loader for LOVE.[https://github.com/bjornbytes/cargo](https://github.com/bjornbytes/cargo)
- **json.lua** - Read/Write json in LUA [https://github.com/rxi/json.lua](https://github.com/rxi/json.lua)
- **toml2lua** - Read/Write toml in LUA [https://github.com/nexo-tech/toml2lua](https://github.com/nexo-tech/toml2lua)
- **url.lua** - URL Parsing for lua [https://github.com/golgote/neturl](https://github.com/golgote/neturl)
- **nativefs** - Allows filesystem access outside of the application directory in LOVE [https://github.com/EngineerSmith/nativefs](https://github.com/EngineerSmith/nativefs)
- **Flux** - Tweening library for LOVE. [https://github.com/rxi/flux](https://github.com/rxi/flux)
---

## Acknowledgments

Thanks to the authors and maintainers of the above projects for making their work available.

In addition thank you to the following projects.

### [MuOS](https://github.com/MustardOS)
This application is designed for MuOS. You must download and install the latest version of MuOS to your device. Visit [https://muos.dev](https://muos.dev) for installation and setup instructions. You can support the project here [https://ko-fi.com/xonglebongle](https://ko-fi.com/xonglebongle)

### [Libretro](https://www.libretro.com)
This application uses various parts of the libretro project. The consolidated dat files from [https://github.com/libretro/libretro-database](https://github.com/libretro/libretro-database) are used as source files for the DAT database. In addition the code that scans 'disc' based roms (e.g PSX/DC) to extract serial numbers is derived from libretro. Finally the image assets from [https://github.com/libretro-thumbnails/libretro-thumbnails](https://github.com/libretro-thumbnails/libretro-thumbnails) and hosted at [https://thumbnails.libretro.com](https://thumbnails.libretro.com) are used as a source for scraping images.

### [Screenscraper.fr](https://www.screenscraper.fr)
A comprehensive API used as a source for scraping media in this application. For best results you should sign up for an account (in order to use the API during times of high demand you will require an account). For additional resource limits and threads (which will speed up your scraping process), you can donate to the project here[https://en.tipeee.com/screenscraper](https://en.tipeee.com/screenscraper). 

### [SteamGridDB](https://www.steamgriddb.com)
A media API used to fetch 'grid' assets. You need to sign up for an account here an generate an API key in order to use this as a source.

### [No-Intro](https://no-intro.org) & [Redump](http://redump.org) 
Dat data for verifying roms.

## License

This project is released under the **GNU General Public License version 3 (GPLv3) or later**.  
See [LICENSE](LICENSE) for details.