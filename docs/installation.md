---
linkTitle: Installation
title: Installation
weight: 1
---

First [Setup Skyscraper](https://github.com/Gemba/Skyscraper/?tab=readme-ov-file#installation-prerequisites-on-other-systems-or-architectures).
Note that for macOS users there is an issue that requires a [small workaround during
installation](https://github.com/Gemba/skyscraper/issues/64#issuecomment-2142623055)

This application runs on PHP 8.2+ and requires a few other extensions to be installed (eg imagemagick, 7zip etc).

<details>
   <summary>macOS</summary>

```sh
brew install php@8.2 composer p7zip imagemagick pkg-config
pecl install imagick
```

Image optimization steps require additional packages to be installed for best
results. [See here](https://github.com/spatie/image-optimizer?tab=readme-ov-file#optimization-tools)

```sh
brew install jpegoptim optipng pngquant
```

</details>

<details>
   <summary>Ubuntu/Debian</summary>

Install PHP 8.2+ using a guide relevant to your
system [from php.watch](https://php.watch/articles/install-php82-ubuntu-debian) for example

Install [Composer](https://getcomposer.org/download/)

Install remaining dependencies

```sh
sudo apt install p7zip-full imagemagick php-imagick
```

Image optimization steps require additional packages to be installed for best
results. [See here](https://github.com/spatie/image-optimizer?tab=readme-ov-file#optimization-tools)

```sh
sudo apt install jpegoptim optipng pngquant
```

</details>

<details>
   <summary>Fedora/RHEL/Centos/Rocky Linux</summary>

Install PHP 8.2+ using a guide relevant to your
system [from php.watch](https://php.watch/articles/php-8.3-install-upgrade-on-fedora-rhel-el) for example

Install [Composer](https://getcomposer.org/download/)

Install remaining dependencies

```sh
sudo dnf install php composer
sudo dnf install p7zip p7zip-plugins ImageMagick php-pecl-imagick
```

Image optimization steps require additional packages to be installed for best
results. [See here](https://github.com/spatie/image-optimizer?tab=readme-ov-file#optimization-tools)

```sh
sudo dnf install jpegoptim optipng pngquant
```

</details>

Once requirements are installed clone this repo and run `composer install` dependencies

```sh
git clone https://github.com/boxart-buddy/boxart-buddy
cd boxart-buddy 

composer install
```