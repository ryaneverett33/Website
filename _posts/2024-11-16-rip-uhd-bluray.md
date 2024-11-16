---
layout: post
title: How-To Ripping UHD BluRays with Dolby Vision
categories: [general]
tags: [ffmpeg, dovi-tool, hdr10, dolbyvision, video, makemkv]
fullview: true
---

Like many others, I rip movies so that I can watch them more easily with tools like [Plex](https://www.plex.tv/) or [Jellyfin](https://jellyfin.org/). With tools like [MakeMKV](https://www.makemkv.com/), BluRay discs can be ripped and enjoyed similarly to DVDs of old. However with UHD BluRays, containing Dolby Vision, things are a little more complicated.

UHD BluRays with Dolby Vision generally have poor player compatibility with basic ripping. Specifically, BluRays with an Enhancement Layer for Dolby Vision, aka Profile 7, require more processing power for playback. This higher playback requirement results in devices from streaming sticks to desktop PCs being unable to playback these rips.

The solution demonstrated in this post optimizes for compatibility by converting Profile 7 rips to Profile 8. To be clear, converting to Profile 8 involves a loss of quality. I don't mean to say that the underlying video stream is compressed or altered in anyway, but that the Dolby Vision metadata has less quality with Profile 8 than Profile 7.

If you have a setup that works with Profile 7, feel free to ignore this post. Alternatively, you could bother device manufacturers to support Profile 7 to help the rest of us out.

## Rip the BluRay with MakeMKV

The first step here is to rip the disc with MakeMKV. If you're not already setup to do this, refer to [this guide](https://forum.makemkv.com/forum/viewtopic.php?t=19634) on the MakeMKV forums. Choose whatever settings you want and then rip the disc to an `.mkv` file.

![Ripping a Disc in MakeMKV](/assets/posts/2024-11-16/img/makemkv-rip.png "Ripping a Disc in MakeMKV")

## Check if the file has Profile 7

After MakeMKV rips the disc, you should have a playable video file with the Dolby Vision metadata intact. At this point, we need to check what metadata exists. Almost all UHD BluRays with Dolby Vision support are released with some variant of Profile 7: either with a Minimum Enhancement Layer or a Full Enhancement Layer. However, it is technically possible to author a BluRay with alternative profiles, so we should check just to be safe.

In order to check the file, just run `ffprobe` on it:

```sh
> ffprobe '.\The Boy and the Heron_t01.mkv'
  Stream #0:0(eng): Video: hevc (Main 10), yuv420p10le(tv, bt2020nc/bt2020/smpte2084), 3840x2160 [SAR 1:1 DAR 16:9], q=2-31, 23.98 fps, 23.98 tbr, 23.98 tbn
    Metadata:
      BPS-eng         : 81313117
      DURATION-eng    : 02:03:56.929500000
      NUMBER_OF_FRAMES-eng: 178308
      NUMBER_OF_BYTES-eng: 75589985204
      SOURCE_ID-eng   : 001011
      _STATISTICS_WRITING_APP-eng: MakeMKV v1.17.7 win(x64-release)
      _STATISTICS_WRITING_DATE_UTC-eng: 2024-07-26 22:03:40
      _STATISTICS_TAGS-eng: BPS DURATION NUMBER_OF_FRAMES NUMBER_OF_BYTES SOURCE_ID
    Side data:
      DOVI configuration record: version: 1.0, profile: 7, level: 6, rpu flag: 1, el flag: 1, bl flag: 1, compatibility id: 6
Stream mapping:
  Stream #0:0 -> #0:0 (copy)
Press [q] to stop, [?] for help
frame=178308 fps=661 q=-1.0 Lsize=73820752kB time=02:03:56.76 bitrate=81317.6kbits/s speed=27.6x
video:73818345kB audio:0kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 0.003261%
```

From the above snippet we can see that the ripped file indeed has Profile 7.

## Extracting the Dolby Vision Metadata

In order to convert the Profile 7 data to Profile 8, we turn to our good friend [dovi_tool](https://github.com/quietvoid/dovi_tool). `dovi_tool` has support for adding, removing, and converting Dolby Vision metadata within a HEVC stream.

In order to convert the Profile 7 metadata, we first need to extract the HEVC bitstream from our file.

```
> ffmpeg -i '.\The Boy and the Heron_t01.mkv' -map 0:0 -vcodec copy video.hevc
  Stream #0:0(eng): Video: hevc (Main 10), yuv420p10le(tv, bt2020nc/bt2020/smpte2084), 3840x2160 [SAR 1:1 DAR 16:9], q=2-31, 23.98 fps, 23.98 tbr, 23.98 tbn
    Metadata:
      BPS-eng         : 81313117
      DURATION-eng    : 02:03:56.929500000
...
    Side data:
      DOVI configuration record: version: 1.0, profile: 7, level: 6, rpu flag: 1, el flag: 1, bl flag: 1, compatibility id: 6
Stream mapping:
  Stream #0:0 -> #0:0 (copy)
Press [q] to stop, [?] for help
frame=178308 fps=661 q=-1.0 Lsize=73820752kB time=02:03:56.76 bitrate=81317.6kbits/s speed=27.6x
video:73818345kB audio:0kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 0.003261%
```

Once the bitstream has been extracted, we can extract and convert the Dolby Vision metadata within it.

```
> dovi_tool -m 2 extract-rpu .\video.hevc
Reordering metadata... Done.
```

The above command will produce a `RPU.bin` file with the Profile 8 metadata (converted with the `-m 2` flag).

## Injecting Profile 8 Metadata

Now that we have the re-written metadata, we need to re-inject it back into our HEVC bitstream. But before we do that, we need to remove the Profile 7 enhancement layer. With Dolby Vision, the Enhancement Layer is a separate 1080p(1K) HEVC stream thats combined with the base 10-bit video stream to produce a combined 12-bit stream.

In order to remove the Enhancement Layer, we can "demux" the original bitstream.

```
> dovi_tool.exe demux .\video.hevc
```

This will produce two separate HEVC files: `BL.hevc` for the base video stream and `EL.hevc` for the enhancement layer.

With the base layer bitstream file, we can inject our newly converted metadata to make it a Profile 8 bitstream.

```
> dovi_tool.exe inject-rpu -r .\RPU.bin -i .\BL.hevc -o profile8.hevc
Parsing RPU file...
Processing input video for frame order info...
Rewriting file with interleaved RPU NALs..
```

## Muxing back to MKV

Now that we have a Profile 8 bitstream, we need to re-mux it back into our original ripped file. For safety reasons, we need to do this in two steps: mux the Profile 8 bitstream to a temporary `profile8.mkv` and then mux the original file with `profile8.mkv` to get the final file. `ffmpeg` is great but seems to struggle with raw HEVC bitstreams (it could be user error, I ain't pointing fingers). Because of this, we use `mkvmerge` to do the initial muxing.

In order to do this muxing, we need two more bits of info: the MaxCLL and MaxFALL values. You can grab this info by loading the original ripped file into MediaInfo and examining the video track. These values should be substituted into the below command for the `--max-content-light` and `max-frame-light` flags accordingly. While you're in MediaInfo, double check that the Mastering display luminance and the video frame rate are correct.

```
> mkvmerge.exe -o .\profile8.mkv --default-duration 0:24000/1001p --fix-bitstream-timing-information 0:1 --colour-matrix 0:9 --colour-range 0:1 --colour-transfer-characteristics 0:16 --colour-primaries 0:9 --max-content-light 0:991 --max-frame-light 0:299 --max-luminance 0:1000.0 --min-luminance 0:0.0001 --chromaticity-coordinates 0:0.708,0.292,0.17,0.797,0.131,0.046 --white-colour-coordinates 0:0.3127,0.329 .\profile8.hevc
mkvmerge v82.0 ('I'm The President') 64-bit
'.\profile8.hevc': Using the demultiplexer for the format 'HEVC/H.265'.
'.\profile8.hevc' track 0: Using the output module for the format 'HEVC/H.265 (unframed)'.
The file '.\profile8.mkv' has been opened for writing.
'.\profile8.hevc' track 0: Extracted the aspect ratio information from the video bitstream and set the display dimensions to 3840/2160.
The cue entries (the index) are being written...
Multiplexing took 1 minute 42 seconds.
```

_NOTE: The above command targets: bt.2020 color primaries, PQ transfer coefficients, bt.2020nc (non-constant) matrix coefficients, and a limited color range._

Once we have the `profile8.mkv` intermediary file, we can perform the final mux back with the ripped file.

```
> ffmpeg -i '.\The Boy and the Heron_t01.mkv' -i .\profile8.mkv -i -map 1:0 -map 0:a -map 0:s -codec copy 'The Boy and the Heron - HDR.mkv'
  Stream #0:0(eng): Video: hevc (Main 10), yuv420p10le(tv, bt2020nc/bt2020/smpte2084), 3840x2160 [SAR 1:1 DAR 16:9], 23.98 fps, 23.98 tbr, 1k tbn
    Metadata:
      BPS-eng         : 81313117
      DURATION-eng    : 02:03:56.929500000
...
frame=178308 fps=121 q=-1.0 Lsize=18788296kB time=02:03:56.93 bitrate=20695.9kbits/s speed=5.05x
video:13337014kB audio:5380842kB subtitle:40kB other streams:0kB global headers:1kB muxing overhead: 0.376107%
```

## Closing

After the final mux is done, you should have a Profile 8 Blu-Ray rip that works on more devices. Again, if you have a setup that supports Profile 7 then you don't need to do this. This guide focuses on compatibility and sacrifices a little bit of quality.