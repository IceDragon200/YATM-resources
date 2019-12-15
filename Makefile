.DEFAULT_GOAL : all
.PHONY : all
all: sources

.PHONY : animation
animation: stitch
	echo $$(pwd)
	apngasm -F -d 100 -o "build/atlas_texture.apng" $$(ls build/animations/all/x1/frame*.png | sort)
	apng2gif "build/atlas_texture.apng"

.PHONY : clean
clean:
	rm -rvf build

.PHONY : gui
gui:
	bundle exec ruby build_large_gui.rb

.PHONY : stitch
stitch: sources
	bundle exec ruby stitch_textures.rb :all :blocks :each_block

.PHONY : paintings
paintings: compose
	bundle exec ruby build_paintings.rb

.PHONY : slice
slice: compose
	bash slice_tilemaps.sh

.PHONY : compose
compose: generate_compose_files
	bundle exec ruby compose.rb -j $$(nproc)

.PHONY : generate_compose_files
generate_compose_files:
	cd compose_base && make -j $$(nproc)

.PHONY : sources
sources: slice paintings animation gui

.PHONY : install
install:
	bundle exec ruby install_textures.rb
