---
linkTitle: Quickstart
title: Quickstart
weight: 2
breadcrumbs: false
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
See [Configuration Reference]( {{< ref "configuration" >}}) for more details

{{< callout type="info" >}}
You can also run ```make bootstrap-tinybest``` or ```make bootstrap-done2``` if you are using those romsets. This will
create ```config_platform.yml``` preconfigured for those romsets.
{{< /callout >}}

### Scrape

```shell
make scrape
```

This process is **slow** and can take hours depending on number of roms<br>
This only needs to be done once.

### Generate

```shell
make build
```

{{< callout >}}
See the [templates gallery]({{< ref "/templates/gallery" >}}) for previews
{{< /callout >}}

![Standfirst](images/gif/build.gif)

Completed artwork will be output into ```./package```. <br>
See [templates transfer]({{< ref "/templates/transfer" >}})
for information on copying to device

{{< callout type="warning" >}}
After generating, some roms may be skipped due to not being scraped properly.
See the [skipped section]({{< ref "skipped" >}}) for how to handle this
{{< /callout >}}

{{% /steps %}}
