---
linkTitle: Quickstart
title: Quickstart
weight: 2
---

{{< callout type="info" >}}
All commands should be run from the root of the boxart-buddy repository
{{< /callout >}}

{{% steps %}}

### Bootstrap

```shell
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

You must edit ```config.yml``` and ```config_platform.yml``` before you can proceed.
See [Configuration Reference](/configuration) for more details

{{< callout type="info" >}}
You can also run ```make bootstrap-tinybest``` or ```make bootstrap-done2``` if you are using those romsets. This will
create ```config_platform.yml``` preconfigured for those romsets.
{{< /callout >}}

### Scrape

```shell
make scrape
```

This will take a while (depending on the number of roms you have).

### Generate

```shell
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

```shell
make simple-examples-system-and-game-logos
```

![Standfirst](images/gif/standfirst.gif)

Completed artwork will be output into ```./package```

{{< callout type="warning" >}}
After generating, some roms may be skipped due to not being scraped properly. See the [skipped section](/skipped) for
how
to handle this
{{< /callout >}}

{{% /steps %}}

### Indivdiual commands

These 'make' commands provide an easy way to get started but there are many more options for generating artwork. If you
run a 'make' command with the '-n' flag it will output the full underlying command which is being used to generate the
artwork.

```shell
# running this
make simple-examples-system-and-game-logos -n

# will output this
php bin/console build  --artwork='simple-examples:system_logo_with_game_logo.xml' --folder='simple-examples:system_logo.xml' --package-name='system-and-game-logos'
```

Run these commands with '--help' to see a full configuration reference e.g

```shell
php bin/console build --help
```

| Command                        | Description                                                                        |
|--------------------------------|------------------------------------------------------------------------------------|
| php bin/console bootstrap      | Generate config files and folders                                                  |
| php bin/console prime-cache    | Primes the cache by scraping using [screenscraper.fr](http://www.screenscraper.fr) |
| php bin/console build          | Generates and packages artwork                                                     |
| php bin/console new-template   | Creates a new template folder with correct folder structure                        |
| php bin/console import-skipped | Imports 'skipped' data from the './skipped' folder into the cache                  |



