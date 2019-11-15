.DEFAULT_GOAL : all
.PHONY : all
all: generate_mesecon_locks generate_mesecon_buttons generate_lamps generate_mailboxes generate_thermal_plates generate_concrete generate_packages generate_barrels generate_fluid_pipes generate_item_ducts generate_access_cards generate_inventory_drives generate_keys generate_copper_cable generate_data_cable

.PHONY : generate_mesecon_locks
generate_mesecon_locks:
	bundle exec ruby blocks/gen_mesecon_locks.rb

.PHONY : generate_mesecon_buttons
generate_mesecon_buttons:
	bundle exec ruby blocks/gen_mesecon_buttons.rb

.PHONY : generate_lamps
generate_lamps:
	bundle exec ruby blocks/gen_lamps.rb

.PHONY : generate_mailboxes
generate_mailboxes:
	bundle exec ruby blocks/gen_mailboxes.rb

.PHONY : generate_thermal_plates
generate_thermal_plates:
	bundle exec ruby blocks/gen_thermal_plates.rb

.PHONY : generate_concrete
generate_concrete:
	bundle exec ruby blocks/gen_concrete.rb

.PHONY : generate_packages
generate_packages:
	bundle exec ruby blocks/gen_packages.rb

.PHONY : generate_barrels
generate_barrels:
	bundle exec ruby blocks/gen_barrels.rb

.PHONY : generate_fluid_pipes
generate_fluid_pipes:
	bundle exec ruby blocks/gen_fluid_pipes.rb

.PHONY : generate_item_ducts
generate_item_ducts:
	bundle exec ruby blocks/gen_item_ducts.rb

.PHONY : generate_access_cards
generate_access_cards:
	bundle exec ruby items/gen_access_cards.rb

.PHONY : generate_inventory_drives
generate_inventory_drives:
	bundle exec ruby items/gen_inventory_drives.rb

.PHONY : generate_keys
generate_keys:
	bundle exec ruby items/gen_keys.rb

.PHONY : generate_copper_cable
generate_copper_cable:
	bundle exec ruby blocks/gen_copper_cable.rb

.PHONY : generate_data_cable
generate_data_cable:
	bundle exec ruby blocks/gen_data_cable.rb
