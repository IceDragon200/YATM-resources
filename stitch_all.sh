#!/usr/bin/env bash
stitchFiles()
{
  for f in $@; do
    if [[ -d "${f}" ]]; then
      files=$(echo "${f}"/*.png)
      outfile=$(basename "${f}" | sed "s/anim-//")
      tstitch "${outfile}.png" 1 $(echo ${files} | sort)
    fi
  done
}

owd=$(pwd)

#stitchFiles ./anim-*
list=(
"BlockAutoCrafter"
"BlockAutoGrinder"
"BlockCompactor"
"BlockCrusher"
"BlockElectrolyser"
"BlockEnergyCell.Basic"
"BlockEnergyCell.Dense"
"BlockEnergyCell.Normal"
"BlockFluxFurnace"
"BlockHeater"
"BlockMiniBlastFurnace"
"BlockMixer"
"BlockMixerALT"
"BlockRoller"
)

for d in ${list[@]} ; do
  echo "${d}"
  cd "${d}"
  stitchFiles ./anim-*
  cd "${owd}"
done
