---
title: ChristmasPi
layout: project
class_project: no
work_project: no
wip: yes
project_link: https://github.com/Changer098/christmaspi
demo_link: !!null
category: !!null
languages: [C#, C, HTML, CSS, JS]
technologies: [ASP.Net, Raspberry Pi]
main_screenshot: /assets/projects/ChristmasPi/screenshots/setup_main.png
screenshots: 
    - img: setup_hardware.png
      title: Setting up hardware
      external: false
    - img: solid_color_mode.png
      title: Setting a color in SolidColorMode
      external: false
    - img: play_animation.png
      title: Selecting an animation to play
      external: false
    - img: schedule_add_rule.png
      title: Adding a rule to the schedule
      external: false
---

# About

ChristmasPi is a webapp that powers animated Christmas Trees. It's built with dotnet core and runs on a Raspberry Pi. The webapp is mobile optimized so you can control your Christmas Tree for your pocket or from your computer. ChristmasPi also includes a REST API allowing you to control everything about your tree.


### Previous Versions

ChristmasPi has undergone multiple iterations over the years, and this list is a brief attempt at sumarizing them.

1. Command Line tool written in C ([Link](https://github.com/Changer098/ChristmasPi/tree/master/old/firstAttempt))
    - Controlled by running the `Animations` program on the Raspberry Pi itself
    - Used a relay board to control strands of lights (branches)
    - Included 8 animations
2. 1st Attempt rewrite in C# Mono ([Link](https://github.com/Changer098/ChristmasPi/tree/master/old/oldMono/Server/Server))
    - An attempt to write a HTTP Server from scratch, succeeded in creating an echo server
    - Rewrote `Animations.c` into `Animations.cs`
    - Included an interop library for [wiringPi](http://wiringpi.com/).
3. Working C# Mono version ([Link](https://github.com/Changer098/ChristmasPi/tree/master/old/JSONRPC%20Server))
    - Includes a functioning JSON-RPC Server (from scratch)
    - A viable replacement for the CLI tool
4. ASP.NET webapp (this version)

### Features

ChristmasPi is a work-in-progress and, as such, many features are still incomplete or may be removed/reworked.

- Supports WS2811/12 RGB LED strips for individually adressable lights
- Supports a Solid Color mode or an Animation mode
- Lights can be grouped into levels (or branches) allowing for more animations
- Includes an interactive Setup mode to make configuring your tree much easier
- Includes a scheduler to automatically turn on and off your tree at certain times based on days of the week
- Supports a JSON based REST API for integrating your tree with other projects
- Allows the user to select a default color or animation to play when the tree is turned on