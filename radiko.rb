#!/usr/bin/env ruby
# coding: utf-8
require "./lib/radiko"

channel, min, filename, outdir = ARGV
min ||= 30
sec = min.to_f*60
outdir = "."


radio = Radiko.new
radio.open
radio.tune channel
radio.play wait: 5, sec: 60, filename: filename, quiet: false, outdir: outdir
