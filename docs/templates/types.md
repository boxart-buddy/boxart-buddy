---
linkTitle: Template Types
title: Template Types
weight: 2
breadcrumbs: false
---

The [Template Gallery]({{< ref "gallery" >}}) has information about each template.

### Types

|                                                            |                                                                                                                                                                                                        |
|------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| {{< badge text="standalone" title="type" color="green" >}} | Generated without reference to siblings. Missing entries don't look as bad. Fast to generate                                                                                                           |
| {{< badge text="sibling" title="type" color="green" >}}    | Loads next & previous artwork when generating. Any missing artwork will break the visual effect. All artwork must be generated 'up front'. i.e. If new roms are added then artwork must be regenerated |

### Height

|                                                          |                                                                                                                                                                  |
|----------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| {{< badge text="full" title="height" color="blue" >}}    | Full height artwork fills the vertical space of the screen. **_Could_** make system logos (wifi/battery/time etc) in header and footer harder to read            |
| {{< badge text="inner" title="height" color="blue" >}}   | Inner height artwork leaves a transparent 42px border at the top and bottom of the screen. This means artwork will never clash with important system UI elements |
| {{< badge text="partial" title="height" color="blue" >}} | Partial height artwork is smaller and will only cover a small area of the screen. Least intrusive                                                                |

### Setting Template Options in MUOS