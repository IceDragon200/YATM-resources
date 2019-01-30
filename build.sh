#!/usr/bin/env bash
ruby compose.rb -j 8 &&
ruby stitch_textures.rb &&
apngasm -F -d 100 -o "build/anim-texture.apng" $(ls build/anim-texture/frame*.png | sort) &&
apng2gif "build/anim-texture.apng"

