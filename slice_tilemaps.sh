#!/usr/bin/env bash
owd=$(pwd)
mkdir -p "${owd}/build/tiles"
mkdir -p "${owd}/build/tilemaps"
cp -u "${owd}/textures/tilemaps/"*.png "${owd}/build/tilemaps/"
cd "${owd}/build/tilemaps"
#if [[ -f *.t3x3.png ]]; then
	tautotile_slice --format 3x3 *.t3x3.png -d "${owd}/build/tiles"
#fi
#if [[ -f *.t4x3.png ]]; then
	tautotile_slice --format 4x3 *.t4x3.png -d "${owd}/build/tiles"
#fi
#if [[ -f *.t4x4.png ]]; then
	tautotile_slice --format 4x4 *.t4x4.png -d "${owd}/build/tiles"
#fi
cd "${owd}"
tautotiler_test -v -d "${owd}/build/tests" "${owd}/build/tiles/"*.t3x3
tautotiler_test -v -d "${owd}/build/tests" "${owd}/build/tiles/"*.t4x3
tautotiler_test -v -d "${owd}/build/tests" "${owd}/build/tiles/"*.t4x4
