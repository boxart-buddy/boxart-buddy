---
linkTitle: Quickstart
title: Quickstart
weight: 2
---

```sh
make bootstrap
```

This will generate config files inside ./user_config folder.

{{< filetree/container >}}
{{< filetree/folder name="user_config" >}}
{{< filetree/file name="config.yml" >}}
{{< filetree/file name="config_platform.yml" >}}
{{< filetree/file name="config_portmaster.yml" >}}
{{< filetree/file name="folder_roms.yml" >}}
{{< filetree/file name="name_extra.json" >}}
{{< /filetree/folder >}}
{{< /filetree/container >}}

Edit these files: See the [Configuration Reference](configuration) for more details

Once you have updated the config files you can scrape and prime the cache ready for generating artwork.

```sh
make scrape
```

This will take a while (depending on the number of roms you have).

{{< callout type="info" >}}
On first run you may want to only provide 1 or 2 lines in config_platform.yml to reduce the time this takes.
{{< /callout >}}

Once the cache is filled you can generate artwork.

```sh
# will show a list of templates that can be generated
make help
```

```console
bootstrap                                                    Bootstrap to create config files on initial setup (run this 1st)
scrape                                                       Scrape screenscraper and fill the cache prior to generation (run this 2nd)
complex-examples-game-logo-scrolling-with-muos-classic-bg    Template: Game logos w/ post processing and scrollbar
simple-examples-gradient-screenshot-with-game-logo           Template: A simple gradient mask w/ screenshot & game logo (with portmaster)
simple-examples-system-and-game-logos                        Template: System Logo + Game Logo. Folder art w/ simple platform logos.
```

Pick one and run it to generate artwork

```sh
make simple-examples-system-and-game-logos
```

Completed artwork will be output into ```./package```

These 'make' commands provide an easy way to get started but there are many more options for generating artwork. If you
run a 'make' command with the '-n' flag it will output the full underlying command which is being used to generate the
artwork.

```sh
make simple-examples-system-and-game-logos -n
php bin/console build  --artwork='simple-examples:system_logo_with_game_logo.xml' --folder='simple-examples:system_logo.xml' --package-name='system-and-game-logos'
```

You can the run this command directly or modify it to your own requirements.
