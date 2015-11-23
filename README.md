# mac-setup

A bash script for OS X which preps your Mac for development. Optionally installs
my .bash_profile file from
[this GitHub repo](https://github.com/EddyLuten/bash_profile).

## Installation

Download `setup.sh` and execute the file or copy and paste this one-liner into your bash terminal:

    bash -i <(curl -s https://raw.githubusercontent.com/EddyLuten/mac-setup/master/setup.sh)

## What it Does

This script sets a couple of sane Finder defaults and installs the latest stable versions of:

* Xcode Command Line Tools (optional)
* Homebrew
* Homebrew Cask
* wget
* Vim + [The Ultimate vimrc](https://github.com/amix/vimrc)
* Git
* Node.js
* rbenv
* A default .bash_profile
* A Ruby version through a prompt (optional)
* Common applications (optional)
    * Atom
    * Google Chrome
    * Mozilla Firefox
    * Java (JRE)
