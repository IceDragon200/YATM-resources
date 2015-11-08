#!/usr/bin/env bash
owd=$(pwd)
cd "blocks_tiled"
mkdir -p out
tautotiler *.tiled.png -d out
tautotiler8 *.tiled8.png -d out
#tautotiler_test -v -d ./tests *.tiled.png
#tautotiler8_test -v -d ./tests *.tiled8.png
cd "${owd}"
