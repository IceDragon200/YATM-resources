.DEFAULT_GOAL : all
.PHONY : all
all: stitch

#.PHONY : animation
#animation: stitch
#	echo $$(pwd)
#	apngasm -F -d 100 -o "build/atlas_texture.apng" $$(ls build/atlas_texture/frame*.png | sort)
#	apng2gif "build/atlas_texture.apng"

.PHONY : clean
clean:
	rm -rvf build

.PHONY : stitch
stitch: slice
	bundle exec ruby stitch_textures.rb :all :blocks :each_block

.PHONY : slice
slice: compose
	bash slice_tilemaps.sh

.PHONY : compose
compose: generate_compose_files
	bundle exec ruby compose.rb -j 8

.PHONY : generate_compose_files
generate_compose_files:
	cd compose_base && make -j 8
