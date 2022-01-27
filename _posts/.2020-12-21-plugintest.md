---
layout: post
title: Plugin Test
categories: [general, setup, demo]
tags: [demo]
fullview: true
technologies: [Android, Electron, Firebase, Angular]
screenshots:
    - img: /assets/projects/dinodash/screenshots/main.jpg
      title: Dino Dash
      external: true
    - img: /assets/projects/ChristmasPi/screenshots/setup_main.png
      title: ChristmasPi
      external: true
    - img: /assets/projects/larry/screenshots/main.PNG
      title: larry
      external: true
---
## Gists

{% gist 41f6bceddee56e85a090fd2e94d1a844 %}

## Imgur

{% imgur https://i.imgur.com/38bB9P4.png %}

## tech-links

<div>{% tech_links {{page.technologies}} %}</div>

## compare

{% assign before_label = "My Before Label" %}
{% assign after_label = "My After Label" %}
{% compare https://d33wubrfki0l68.cloudfront.net/ca762d4c19d7c5edfa8d38c37f8722de27eb7612/0803b/playground/uploads/upload/upload/210/hero-before.jpg https://d33wubrfki0l68.cloudfront.net/7e261b73b18e62fe4c50a7383ca31b943f048625/95d29/playground/uploads/upload/upload/265/hero-after.jpg "compare-test" before_label:{{before_label}} after_label:{{after_label}} move_slider_on_hover:false default_offset_pct:0.1 %}

## Youtube

{% youtube DW2far3z_Qs %}

## Logo

<div>{% logo /assets/projects/mappy/images/mappy.png width:77 height:112 %}</div>

## Screenshots

<div>{% screenshots {{page.screenshots}} "Blog" %}</div>