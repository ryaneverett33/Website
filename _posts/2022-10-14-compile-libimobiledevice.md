---
layout: post
title: How-To compile libimobiledevice
categories: [general]
tags: [libimobiledevice, ios, programming]
fullview: true
---

This is a quick post about how to compile [libimobiledevice](https://github.com/libimobiledevice) for use in a dev environment. The difference here being that the resultant builds are not installed to `/usr/` or `/usr/local` directories, but are instead contained within their original repository paths. 

## Compile `libplist`

```
$ git clone git@github.com:libimobiledevice/libplist.git
$ cd libplist
$ mkdir build
$ autoreconf --install
$ ./autogen.sh --prefix=`pwd`/build
$ make
$ make install
$ # Save the built directory path so the dependencies can use it
$ export LIBPLIST_PATH=`pwd`/build/
```

## Compile `libimobiledevice-glue`

```
$ git clone git@github.com:libimobiledevice/libimobiledevice-glue.git
$ cd libimobiledevice-glue
$ mkdir build
$ autoreconf --install
$ PKG_CONFIG_PATH=$LIBPLIST_PATH/lib/pkgconfig ./configure --prefix=`pwd`/build
$ make
$ make install
$ # Save the built directory path so the dependencies can use it
$ export GLUE_PATH=`pwd`/build/
```

## Compile `libusbmuxd`

```
$ git clone git@github.com:libimobiledevice/libusbmuxd.git
$ cd libusbmuxd
$ mkdir build
$ autoreconf --install
$ PKG_CONFIG_PATH="$LIBPLIST_PATH/lib/pkgconfig:$GLUE_PATH/lib/pkgconfig" ./configure --prefix=`pwd`/build
$ make
$ make install
$ # Save the built directory path so the dependencies can use it
$ export LIBUSBMUXD_PATH=`pwd`/build
```

## Compile `libimobiledevice`

```
$ git clone git@github.com:libimobiledevice/libimobiledevice.git
$ cd libimobildevice
$ mkdir build
$ autoreconf --install
$ PKG_CONFIG_PATH="$LIBPLIST_PATH/lib/pkgconfig:$GLUE_PATH/lib/pkgconfig:$LIBUSBMUXD_PATH/lib/pkgconfig" ./configure --prefix=`pwd`/build
$ make
$ make install
$ # Save the built directory path so the dependencies can use it
$ export LIBIMOBILEDEVICE_PATH=`pwd`/build
```

Add the `--enable-debug` flag to `./configure` to enable debug output.

## \[OPTIONAL\] Compile `usbmuxd`

```
$ git clone git@github.com:libimobiledevice/usbmuxd.git
$ cd usbmuxd
$ mkdir build
$ autoreconf --install
$ PKG_CONFIG_PATH="$LIBPLIST_PATH/lib/pkgconfig:$GLUE_PATH/lib/pkgconfig:$LIBUSBMUXD_PATH/lib/pkgconfig:$LIBIMOBILEDEVICE_PATH/lib/pkgconfig" ./autogen.sh --prefix=`pwd`/build
$ make
$ make install
$ # Save the built directory path so the dependencies can use it
$ export USBMUXD_PATH=`pwd`/build
```

## \[OPTIONAL\] Compile `ideviceinstaller`

```
$ git clone git@github.com:libimobiledevice/ideviceinstaller.git
$ cd ideviceinstaller
$ mkdir build
$ autoreconf --install
$ PKG_CONFIG_PATH="$LIBPLIST_PATH/lib/pkgconfig:$LIBUSBMUXD_PATH/lib/pkgconfig:$LIBIMOBILEDEVICE_PATH/lib/pkgconfig" ./autogen.sh --prefix=`pwd`/build
$ make
$ make install
```