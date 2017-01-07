#!/usr/bin/env bash
stitchFiles()
{
  for f in $@; do
    if [[ -d "${f}" ]]; then
      files=$(echo "${f}"/*.png)
      outfile=$(basename "${f}" | sed "s/anim-//")
      tstitch -c 1 -o "build/${outfile}.png" $(echo ${files} | sort)
    fi
  done
}

owd=$(pwd)

#stitchFiles ./anim-*
list=(
"textures/blocks/common"
"textures/blocks/auto_crafter"
"textures/blocks/auto_grinder"
"textures/blocks/compactor"
"textures/blocks/crusher"
"textures/blocks/electrolyser"
"textures/blocks/energy_cell_basic"
"textures/blocks/energy_cell_dense"
"textures/blocks/energy_cell_normal"
"textures/blocks/flux_furnace"
"textures/blocks/heater"
"textures/blocks/mini_blast_furnace"
"textures/blocks/mixer"
"textures/blocks/mixer_alt"
"textures/blocks/roller"
"textures/blocks/item_replicator"
)

for d in ${list[@]} ; do
  echo "${d}"
  cd "${d}"
  stitchFiles ./anim-*
  cd "${owd}"
done
