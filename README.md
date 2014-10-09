## source-code-pro-deb

Adobe Soucre Code Pro font package for Debian

This is initial impl. for building them directly from git sources.

## Requirements

1. Adobe's AFDKO for GNU/Linux (specifically, makeotf)
  * can be obtained from: http://www.adobe.com/devnet/opentype/afdko.html
1. dpkg-dev package
  * install by running: `sudo apt-get install dpkg-dev`

## Installation:

1. Clone this repo, and cd to its directory
1. Run: `./runme.sh`
1. Get one directory up, and install the `.deb` file from there.

