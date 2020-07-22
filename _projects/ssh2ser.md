---
title: ssh2ser
layout: project
class_project: no
work_project: no
wip: yes
project_link: https://github.com/Changer098/ssh2ser
demo_link: !!null
languages: [Python]
technologies: [Paramiko]
main_screenshot: !!null
screenshots: !!null
---

# About

ssh2ser is an ssh server for connecting to serial devices. Similar to [RFC2217](https://tools.ietf.org/html/rfc2217) with telnet but designed for use with multiple users and multiple serial devices in mind. The project is also similar to Pearl's console servers ([Link](https://www.perle.com/products/console-server.shtml)) as it is meant to be deployed with something like a Raspberry Pi.

## Current Design

The current design is to have an SSH server that provides a TUI when connected to by a standard SSH client. This TUI allows the user to select the serial device they want to control or wait for a serial device to become available if it's currently in use. The server will be configurable via a configuration file and optionally run as a system daemon (ideally via systemd).

## Current Implementation

Currently this project is still very much a work-in-progress but has demonstrated some working features. Currently the demo server allows a user to connect and authenticate via SSH. USB->RJ45 serial cables and USB->USB serial cables (info [here](https://www.networkworld.com/article/2228744/cisco-subnet-cisco-usb-console-ports.html)) are supported and are automatically detected on server startup.  