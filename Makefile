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
compose: generate_lamps generate_mailboxes generate_thermal_plates generate_concrete generate_barrels generate_keys generate_item_ducts generate_fluid_pipes
	bundle exec ruby compose.rb -j 8

.PHONY : generate_lamps
generate_lamps:
	bundle exec ruby compose_base/blocks/gen_lamps.rb

.PHONY : generate_mailboxes
generate_mailboxes:
	bundle exec ruby compose_base/blocks/gen_mailboxes.rb

.PHONY : generate_thermal_plates
generate_thermal_plates:
	bundle exec ruby compose_base/blocks/gen_thermal_plates.rb

.PHONY : generate_concrete
generate_concrete:
	bundle exec ruby compose_base/blocks/gen_concrete.rb

.PHONY : generate_barrels
generate_barrels:
	bundle exec ruby compose_base/blocks/gen_barrels.rb

.PHONY : generate_fluid_pipes
generate_fluid_pipes:
	bundle exec ruby compose_base/blocks/gen_fluid_pipes.rb

.PHONY : generate_item_ducts
generate_item_ducts:
	bundle exec ruby compose_base/blocks/gen_item_ducts.rb

.PHONY : generate_keys
generate_keys:
	bundle exec ruby compose_base/items/gen_keys.rb
