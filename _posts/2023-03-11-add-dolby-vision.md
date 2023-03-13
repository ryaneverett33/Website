---
layout: post
title: How-To Add Dolby Vision to a HDR10 Blu-Ray RIP
categories: [general]
tags: [ffmpeg, dovi-tool, hdr10, dolbyvision, video]
fullview: true
---

Some UHD Blu-Ray owners are in awkward position: they bought the Blu-Ray release of a movie only to find online streaming services to contain a "better" version than what they paid for. With the emergence of Dolby Vision, some UHD movies are being released to streaming services, or other digital outlets, with the new HDR information while the older Blu-Ray version is still stuck with HDR10. The Blu-Ray version offers a bunch of benefits over a streaming alternative -- such as higher bitrate video, lossless audio, and bonus features if you're into that sort of thing -- but the lack of Dolby Vision means that some movie watchers aren't getting the best experience.

Thankfully as community efforts around understanding and supporting Dolby Vision have progressed, it's now possible to get the best of both worlds. Specificially, we're going to take the Dolby Vision info from an online source and add to our Blu-Ray rip. With this method, you'll still get all of the benefits of a UHD Blu-Ray rip while also getting that extra Dolby Vision sweetness.

## Tools you'll need

- MakeMKV if you haven't already ripped your Blu-Ray
- [dovi-tool](https://github.com/quietvoid/dovi_tool) by quietvoid
- [ffmpeg](https://ffmpeg.org/)
- A Muxer
    - [mkvmerge](https://mkvtoolnix.download/doc/mkvmerge.html) from [MKVToolNix](https://mkvtoolnix.download/) if your output is a `.mkv` file
    - [tsMuxer](https://github.com/justdan96/tsMuxer) if your output is a `.ts` or `.m2ts` file or you want to create a Blu-Ray disc
    - [mp4Muxer](https://github.com/DolbyLaboratories/dlb_mp4base/tree/master/bin) if your output is a `.mp4` file

## Sources

For this guide, we'll be looking at the movie [Arrival](https://www.amazon.com/Arrival-UHD-Digital-Combo-Blu-ray/dp/B01LTHYE0O/) which was distributed with a HDR10 source but is distributed [online](https://www.vudu.com/content/movies/details/title/826376) with Dolby Vision. We can confirm this by looking at the MediaInfo report of our rip:

![Arrival Blu-Ray rip Info](/assets/posts/2023-03-11/img/BluRay-MediaInfo.PNG "Arrival Blu-Ray rip Info")

As you can see from above, the HDR format is `SMPTE ST 2086, HDR10 compatible` without any Dolby-Vision information. Compare the above to our below source which contains Dolby Vision Profile 5 information:

![Arrival Online Source Info](/assets/posts/2023-03-11/img/Profile5-MediaInfo.PNG "Arrival Online Source Info")

From the online source, we see the HDR10 format as `Dolby Vision, Version 1.0, dvhe.05.06, BL+RPU` which translates to Dolby Vision Profile 5 for HEVC (`dvhe.05`). We can double-confirm this as containing Dolby Vision info by attempting to play with something that doesn't support Dolby Vision:

![Online Source in VLC](/assets/posts/2023-03-11/img/VLC-Profile5.PNG "Online Source in VLC")

As you can see from the VLC screenshot, the colors have a purple-ish tint to them. If the file had a HDR10 incompability, we would expect a light-blue washed-out tint instead. 

This guide will not be discussing how to obtain an online source, but it should be fairly easy to do.

## Extracting and Injecting Dolby Vision

Once you have your sources gathered, we can actually start extracting the Dolby Vision from our online source. In order to do that, we must first extract our video stream from our online source. In order to do that, we use `ffmpeg`. First find the video stream by probing the video:

```
> ffprobe '.\Arrival - Profile 5.mkv'
ffprobe version 5.1.2-full_build-www.gyan.dev Copyright (c) 2007-2022 the FFmpeg developers
  built with gcc 12.1.0 (Rev2, Built by MSYS2 project)
Input #0, matroska,webm, from '.\Arrival - Profile 5.mkv':
  Metadata:
    creation_time   : 2021-11-28T05:30:15.000000Z
    encoder         : libebml v1.4.2 + libmatroska v1.6.4
    Title           : Arrival (2016)
    IMDB            : tt2543164
    TMDB            : movie/329865
  Duration: 01:56:26.51, start: 0.000000, bitrate: 16955 kb/s
  Chapters:
    ...
  Stream #0:0: Video: hevc (Main 10), yuv420p10le(tv), 3832x1592 [SAR 1:1 DAR 479:199], 23.98 fps, 23.98 tbr, 1k tbn (default)
    Metadata:
      title           :
      BPS             : 14434899
      DURATION        : 01:56:22.684000000
      NUMBER_OF_FRAMES: 167417
      NUMBER_OF_BYTES : 12599292328
      _STATISTICS_WRITING_APP: mkvmerge v63.0.0 ('Everything') 64-bit
      _STATISTICS_WRITING_DATE_UTC: 2021-11-28 05:30:15
      _STATISTICS_TAGS: BPS DURATION NUMBER_OF_FRAMES NUMBER_OF_BYTES
    Side data:
      DOVI configuration record: version: 1.0, profile: 5, level: 6, rpu flag: 1, el flag: 0, bl flag: 1, compatibility id: 0
  Stream #0:1(eng): Audio: dts (DTS), 48000 Hz, 5.1(side), s32p (24 bit), 1536 kb/s (default)
    ...
  Stream #0:2(eng): Subtitle: subrip
    ...
  Stream #0:3(eng): Subtitle: subrip (hearing impaired)
    ...
  Stream #0:4(spa): Subtitle: subrip
    ...
```

From our `ffprobe` output, we can see that `Stream 0:0` is our video stream so that's the one we'll be extracting:

```
> > ffmpeg -i '.\Arrival - Profile 5.mkv' -map 0:0 -vcodec copy profile5.hevc
...
frame=167417 fps=388 q=-1.0 Lsize=12303996kB time=01:56:22.51 bitrate=14435.2kbits/s speed=16.2x
video:12303996kB audio:0kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 0.000000%
```

Once the video hasn't been extracted, we can then use it to extract the Dolby Vision metadata using quietvoid's excellent [dovi-tool](https://github.com/quietvoid/dovi_tool). Since we'll be adding this metadata to a HDR10 source, we need to make the metadata compatible. Specifically, we'll be converting from Profile 5 metadata to Profile 8.1 metadata.

```
> dovi_tool.exe -m 2 extract-rpu .\profile5.hevc
Reordering metadata... Done.
```

After the metadata has been extracted, we can inject it into our Blu-Ray rip. Similarly to our online source, we need to extract the video stream before `dovi_tool` can work with it.

```
> ffmpeg -i .\Arrival_t00.mkv -map 0:0 -vcodec copy video.hevc
ffmpeg version 5.1.2-full_build-www.gyan.dev Copyright (c) 2000-2022 the FFmpeg developers
...
  Stream #0:0(eng): Video: hevc (Main 10), yuv420p10le(tv, bt2020nc/bt2020/smpte2084), 3840x2160 [SAR 1:1 DAR 16:9], q=2-31, 23.98 fps, 23.98 tbr, 23.98 tbn
    Metadata:
      BPS-eng         : 50600247
      DURATION-eng    : 01:56:22.642333333
      NUMBER_OF_FRAMES-eng: 167416
      NUMBER_OF_BYTES-eng: 44165426831
      SOURCE_ID-eng   : 001011
      _STATISTICS_WRITING_APP-eng: MakeMKV v1.17.3 win(x64-release)
      _STATISTICS_WRITING_DATE_UTC-eng: 2023-02-22 22:55:35
      _STATISTICS_TAGS-eng: BPS DURATION NUMBER_OF_FRAMES NUMBER_OF_BYTES SOURCE_ID
Stream mapping:
  Stream #0:0 -> #0:0 (copy)
Press [q] to stop, [?] for help
frame=167416 fps=116 q=-1.0 Lsize=43136744kB time=01:56:22.60 bitrate=50608.1kbits/s speed=4.84x
video:43130300kB audio:0kB subtitle:0kB other streams:0kB global headers:1kB muxing overhead: 0.014942%
```

And then we inject the metadata:

```
> dovi_tool.exe inject-rpu -i .\video.hevc -r .\RPU.bin -o injected.hevc
Parsing RPU file...
Processing input video for frame order info...

Warning: mismatched lengths. video 167416, RPU 167417
Metadata will be skipped at the end to match video length

Rewriting file with interleaved RPU NALs..
```

## Re-authoring

Once you have the injected HEVC file, you can re-mux back into a container of your choice. Since we have a raw HEVC file, we must mux into an intermediary container before we can mux our final product. In this way, the muxing step is at least a two step process.

### Muxing with MKVToolNix

Muxing with the MKVToolNix GUI is fairly straight-forward. Simply use the `Multiplexing` tab and add the `injected.hevc` video to the multiplexing job:

![Muxing with MKVToolNix](/assets/posts/2023-03-11/img/mkvtoolnix-merge.PNG "Muxing with MKVToolNix")

It can also be done with the `mkvmerge` command:

```
> mkvmerge.exe .\injected.hevc -o injected.mkv
mkvmerge v74.0.0 ('You Oughta Know') 64-bit
'.\injected.hevc': Using the demultiplexer for the format 'HEVC/H.265'.
'.\injected.hevc' track 0: Using the output module for the format 'HEVC/H.265 (unframed)'.
The file 'injected.mkv' has been opened for writing.
'.\injected.hevc' track 0: Extracted the aspect ratio information from the video bitstream and set the display dimensions to 3840/2160.
The cue entries (the index) are being written...
Multiplexing took 27 minutes 16 seconds.
```

### Muxing with tsMuxer

Muxing with the tsMuxer GUI is much the same as `MKVToolNix`

![Muxing with MKVToolNix](/assets/posts/2023-03-11/img/mkvtoolnix-merge.PNG "Muxing with MKVToolNix")

### Muxing with mp4muxer

`mp4muxer` is used similarly to the `mkvmerge` tool:

```
> mp4muxer.exe -i .\injected.hevc --dv-profile 8 --dv-bl-compatible-id 1 -o .\injected.mp4
```

For some devices, you may need to use the `--dvh1flag` flag.


Once you've muxed to the intermediary container, you can mux back into the Blu-Ray rip with `ffmpeg`. 

```
> ffmpeg -i .\Arrival_t00.mkv -i .\injected.mkv -map 1:0 -map 0:a -map 0:s -codec copy 'Arrival-DV.mkv'
ffmpeg version 5.1.2-full_build-www.gyan.dev Copyright (c) 2000-2022 the FFmpeg developers
...
Stream mapping:
  Stream #1:0 -> #0:0 (copy)
  Stream #0:1 -> #0:1 (copy)
  Stream #0:2 -> #0:2 (copy)
  Stream #0:3 -> #0:3 (copy)
  Stream #0:4 -> #0:4 (copy)
  Stream #0:5 -> #0:5 (copy)
  Stream #0:6 -> #0:6 (copy)
  Stream #0:7 -> #0:7 (copy)
  Stream #0:8 -> #0:8 (copy)
  Stream #0:9 -> #0:9 (copy)
  Stream #0:10 -> #0:10 (copy)
  Stream #0:11 -> #0:11 (copy)
Press [q] to stop, [?] for help
[matroska @ 00000228e58cf6c0] Starting new cluster due to timestampe=57608.0kbits/s speed=3.99x
frame=167416 fps= 95 q=-1.0 Lsize=49792957kB time=01:56:22.65 bitrate=58416.7kbits/s speed=3.96x
video:43163882kB audio:6509135kB subtitle:104370kB other streams:0kB global headers:1kB muxing overhead: 0.031281%
```

which should result in:

![Injected MediaInfo](/assets/posts/2023-03-11/img/Injected-MediaInfo.PNG "Injected MediaInfo")