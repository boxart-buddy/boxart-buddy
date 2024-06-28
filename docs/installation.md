---
linkTitle: Installation
title: Installation
weight: 1
breadcrumbs: false
---

First [Setup Skyscraper](https://github.com/Gemba/Skyscraper/?tab=readme-ov-file#installation-prerequisites-on-other-systems-or-architectures). Make sure you use the [newest fork](https://github.com/Gemba/Skyscraper/)

This application runs on PHP 8.2+ and requires a few other packages to be installed.

## Install Dependencies

{{< tabs items="macOS,Ubuntu/Debian,Fedora/RHEL/Centos" >}}

{{< tab >}}

```shell
brew install php@8.2 composer p7zip imagemagick pkg-config
pecl install imagick
```

Image optimization steps require additional packages to
be [installed](https://github.com/spatie/image-optimizer?tab=readme-ov-file#optimization-tools) for best
results.

```shell
brew install jpegoptim optipng pngquant
```

{{< /tab >}}

{{< tab >}}
Install PHP 8.2+ using a guide relevant to your
system [from php.watch](https://php.watch/articles/install-php82-ubuntu-debian) for example

Install [Composer](https://getcomposer.org/download/)

Install remaining dependencies

```shell
sudo apt install p7zip-full imagemagick php-imagick
```

Image optimization steps require additional packages to be installed for best
results. [See here](https://github.com/spatie/image-optimizer?tab=readme-ov-file#optimization-tools)

```shell
sudo apt install jpegoptim optipng pngquant
```

{{< /tab >}}

{{< tab >}}

Install PHP 8.2+ using a guide relevant to your
system [from php.watch](https://php.watch/articles/php-8.3-install-upgrade-on-fedora-rhel-el) for example

Install [Composer](https://getcomposer.org/download/)

Install remaining dependencies

```shell
sudo dnf install php composer
sudo dnf install p7zip p7zip-plugins ImageMagick php-pecl-imagick
```

Image optimization steps require additional packages to be installed for best
results. [See here](https://github.com/spatie/image-optimizer?tab=readme-ov-file#optimization-tools)

```shell
sudo dnf install jpegoptim optipng pngquant
```

{{< /tab >}}

{{< /tabs >}}

## Clone repository & composer install

Once requirements are installed clone this repo and run `composer install` dependencies

```shell
git clone https://github.com/boxart-buddy/boxart-buddy
cd boxart-buddy 

composer install
```