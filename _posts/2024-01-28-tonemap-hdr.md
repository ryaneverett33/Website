---
layout: post
title: Tonemapping HDR to SDR with libplacebo
categories: [general]
tags: [ffmpeg, dovi-tool, hdr10, hdr10+, dolbyvision, video, libplacebo]
fullview: true
---

HDR video in almost all forms, from HLG and HDR10 to Dolby Vision and HDR10+, looks incredible. Vivid colors, brighter brights, darker darks; it just looks nice. But as good as HDR is, it really sucks to deal with on a SDR display. Once vibrant colors now look dull and lifeless, brighter brights are no longer bright, and darker darks are even darker. Powerful media playback software can ease this pain by dynamically tonemapping HDR content into the SDR space but it can be resource intensive and not support all HDR contents. Worse still is that that powerful playback software can be missing on lower-end platforms like phones and "smart" TVs.

Because of HDR10 limitations, HLG limitations will be skipped here but do also exist, it's valuable to maintain the HDR copy of a movie and an SDR copy to support both clients. With the libplacebo video filter in ffmpeg, we can do this fairly easily.

## Selecting the Tone-mapping algorithm

Using libplacebo within `ffmpeg` is fairly easy, simply have a Vulkan supported GPU and you're reading to rock.

```sh
$ # Example using NVENC encoding and CPU decoding
$ ffmpeg -i '.\Dune - HDR.mkv' -init_hw_device vulkan=gpu:0.0 -vf "hwupload,libplacebo=colorspace=bt709:color_primaries=bt709:color_trc=bt709:range=limited:format=yuv420p" -c:v hevc_nvenc -map 0:0 -b:v 20M -maxrate 25M -preset slow -rc vbr -spatial_aq 1 -temporal_aq 1 -rc-lookahead 32 -tune hq -b_ref_mode middle -rc vbr -pix_fmt yuv420p -t 00:05:00.000 dune.sdr.mkv
```

It even looks pretty decent too:
{% compare "Basic Tonemapping" before_label:"No Tonemapping" after_label:"Tonemapped"}

But after perusing the [libplacebo documentation](), how do we know which algorithm to use?

Using Dune as a sample file, I ran all of the listed algorithms so we can compare them. Since this file has Dolby Vision metadata in it, the runs were first sent to a raw `.hevc` file and then muxed into an `.mkv` file with `mkvmerge`. A scratch `.hevc` file was used as the Dolby Vision metadata can remain present if the `ffmpeg` output is a container file 


## Mixing Dolby Vision and HDR10+