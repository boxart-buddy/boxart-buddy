---
linkTitle: config_portmaster.yml
title: config_portmaster.yml
weight: 3
---

<br>

This configuration file is optional, even if you are generating portmaster art it doesn't need to be explicitly
configued.

The default behaviour _without_ setting anything in this file is that portmaster artwork will be generated for _every_
portmaster title which is compatible with RG35XX devices. Most people using portmaster will only have a few titles
installed. You can set an array of port titles in this file which wil restrict art generation to only those titles. e.g.

```yaml {filename="config_portmaster.yml"}
[ balatro, stardewvalley, 'duke.nukem.3d', gta3, sonic.mania, 'cave.story' ]
```

Or like this

```yaml {filename="config_portmaster.yml"}
  - balatro
  - stardewvalley
  - duke.nukem.3d
```

Use the 'name' value from this
file [this file](https://github.com/PortsMaster/PortMaster-Info/blob/main/ports.json)

Or unzip the zip file of screenshots from here and use those (the values are the same as above):
[https://github.com/PortsMaster/PortMaster-New/releases/latest/download/images.zip](https://github.com/PortsMaster/PortMaster-New/releases/latest/download/images.zip)

