.DEFAULT_GOAL : all
.PHONY : all
all: stitch

#.PHONY : animation
#animation: stitch
#	echo $$(pwd)
#	apngasm -F -d 100 -o "build/atlas_texture.apng" $$(ls build/atlas_texture/frame*.png | sort)
#	apng2gif "build/atlas_texture.apng"

.PHONY : stitch
stitch: slice
	bundle exec ruby stitch_textures.rb

.PHONY : slice
slice: compose
	bash slice_tilemaps.sh

.PHONY : compose
compose: generate
	bundle exec ruby compose.rb -j 8

.PHONY : generate
generate:
	bundle exec ruby compose_base/gen_lamps.rb
