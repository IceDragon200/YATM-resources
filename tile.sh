#!/usr/bin/env bash
owd=$(pwd)
cd "blocks_tiled"
mkdir -p "build/tiled"
tautotiler *.tiled.png -d "build/tiled"
tautotiler8 *.tiled8.png -d "build/tiled"
tautotiler_test -v -d ./tests build/tiled/*.tiled
#tautotiler8_test -v -d ./tests build/tiled/*.tiled8
cd "${owd}"
