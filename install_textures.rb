#!/usr/bin/env ruby
#
# This is the texture installation script for YATM
#
require 'fileutils'

@root = __dir__
#@mods_root = File.expand_path('../minetest-mods/', __dir__)
@mods_root = File.expand_path('../minetest-games/HarmoniaScarredWorld/mods', __dir__)

@gui_root = File.expand_path('textures/gui/', @root)
@items_root = File.expand_path('textures/items/', @root)
@fluids_root = File.expand_path('textures/fluids/', @root)
@blocks_root = File.expand_path('textures/blocks/', @root)
@built_paintings_root = File.expand_path('build/paintings/', @root)
@built_blocks_root = File.expand_path('build/blocks/', @root)
@built_tiles_root = File.expand_path('build/tiles/', @root)
@built_items_root = File.expand_path('build/items/', @root)
@built_gui_root = File.expand_path('build/gui/', @root)

def install_tilemap(pattern, target_directory, prefix: 'yatm')
  Dir.glob(File.join(@built_tiles_root, pattern)) do |filename|
    next if filename.include?(".mask.")
    basename = filename.gsub(@built_tiles_root, '').gsub(/\.t(3x3|3x4|4x4|4x3)/, "")
    newname = prefix + basename.gsub('/', '_')
    newname = newname.gsub(/\A_/, '')

    target_filename = File.join(target_directory, newname)
    FileUtils::Verbose.cp filename, target_filename, preserve: true
  end
end

def install_from(root, pattern, target_directory, prefix: 'yatm')
  Dir.glob(File.join(root, pattern)) do |filename|
    basename = filename.gsub(root, '')
    newname = prefix + basename.gsub('/', '_')
    newname = newname.gsub(/\A_/, '')
    target_filename = File.join(target_directory, newname)
    FileUtils::Verbose.cp filename, target_filename, preserve: true
  end
end

def install_built_items(pattern, target_directory, **options)
  install_from(@built_items_root, pattern, target_directory, **options)
end

def install_built_blocks(pattern, target_directory, **options)
  install_from(@built_blocks_root, pattern, target_directory, **options)
end

def install_built_paintings(pattern, target_directory, **options)
  install_from(@built_paintings_root, pattern, target_directory, **options)
end

def install_built_gui(pattern, target_directory, **options)
  install_from(@built_gui_root, pattern, target_directory, **options)
end

def install_fluids(pattern, target_directory, **options)
  install_from(@fluids_root, pattern, target_directory, **options)
end

def install_items(pattern, target_directory, **options)
  install_from(@items_root, pattern, target_directory, **options)
end

def install_blocks(pattern, target_directory, **options)
  install_from(@blocks_root, pattern, target_directory, **options)
end

def install_gui(pattern, target_directory, **options)
  install_from(@gui_root, pattern, target_directory, **options)
end

def install_harmonia_crystals
  target_directory = File.expand_path('harmonia/harmonia_crystals/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  prefix = 'harmonia'

  install_blocks("crystal/*.png", target_directory, prefix: prefix)
  install_blocks("crystal_holder/*.png", target_directory, prefix: prefix)

  install_items("crystal_shards/*.png", target_directory, prefix: prefix)
  install_items("element_crystal.*.png", target_directory, prefix: prefix)
end

def install_harmonia_element
  target_directory = File.expand_path('harmonia/harmonia_element/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  prefix = 'harmonia'

  install_items("element_blueprint.png", target_directory, prefix: prefix)
  install_items("element_blueprint.*.png", target_directory, prefix: prefix)
end

def install_harmonia_exp
  target_directory = File.expand_path('harmonia/harmonia_exp/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  prefix = 'harmonia'

  install_gui("hudbar_exp.png", target_directory, prefix: prefix)
  install_gui("hudbar_exp_icon.png", target_directory, prefix: prefix)
  install_gui("hudbar_exp_bgicon.png", target_directory, prefix: prefix)
end

def install_harmonia_mana
  target_directory = File.expand_path('harmonia/harmonia_mana/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  prefix = 'harmonia'
  install_gui("hudbar_mana.png", target_directory, prefix: prefix)
  install_gui("hudbar_mana_icon.png", target_directory, prefix: prefix)
  install_gui("hudbar_mana_bgicon.png", target_directory, prefix: prefix)
  install_gui("mana_*.png", target_directory, prefix: prefix)
end

def install_harmonia_mycology
  target_directory = File.expand_path('harmonia/harmonia_mycology/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  prefix = 'harmonia'
  install_blocks("chubby_green_mushroom/*.png", target_directory, prefix: prefix)
end

def install_harmonia_pottery
  target_directory = File.expand_path('harmonia/harmonia_pottery/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  prefix = 'harmonia'
  install_blocks("clay_pot/*.png", target_directory, prefix: prefix)
end

def install_harmonia_spirits
  target_directory = File.expand_path('harmonia/harmonia_spirits/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  prefix = 'harmonia'
  install_built_blocks("spirit_lantern/*.png", target_directory, prefix: prefix)
  install_built_blocks("mana_heater/*.png", target_directory, prefix: prefix)
  install_items("spirits/*.png", target_directory, prefix: prefix)
  install_items("infused_coal_lump.*.png", target_directory, prefix: prefix)
end

def install_harmonia_totems
  target_directory = File.expand_path('harmonia/harmonia_totems/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  prefix = 'harmonia'

  install_blocks("animal_pillars/*.png", target_directory, prefix: prefix)
end

def install_harmonia_treasure
  target_directory = File.expand_path('harmonia/harmonia_treasure/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  prefix = 'harmonia'
  install_items("treasure_bags/*.png", target_directory, prefix: prefix)
end

def install_hsw_hud
  target_directory = File.expand_path('hsw_hud/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  prefix = 'hsw'
  install_gui("hints/equipment.*.png", target_directory, prefix: prefix)
end

def install_hsw_materials
  target_directory = File.expand_path('hsw_materials/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  prefix = 'hsw'
  install_items("wme_material.png", target_directory, prefix: prefix)
end

def install_hsw_tools
  target_directory = File.expand_path('hsw_tools/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  prefix = 'hsw'
  install_items("tools/**.png", target_directory, prefix: prefix)
end

def install_hsw_workbench
  target_directory = File.expand_path('hsw_workbench/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  prefix = 'hsw'
  install_blocks("workbench/**/*.png", target_directory, prefix: prefix)
end

def install_yatm_armoury
  target_directory = File.expand_path('yatm/yatm_armoury/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("ammo_can/*.png", target_directory)
  install_built_blocks("chemical_injector/*.png", target_directory)
  install_blocks("target.png", target_directory)

  install_items("ammo/*.png", target_directory)
  install_items("magazines/*.png", target_directory)
  install_items("firearms/*.png", target_directory)
  install_items("grenades/*.png", target_directory)
  install_items("grenades/{chemical,fire,frost,nuclear}/0.png", target_directory)
end

def install_yatm_armoury_c4
  target_directory = File.expand_path('yatm/yatm_armoury_c4/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("c4/*.png", target_directory)
  install_items("c4_detonator.png", target_directory)
end

def install_yatm_armoury_icbm
  target_directory = File.expand_path('yatm/yatm_armoury_icbm/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("icbm/*.png", target_directory)

  install_items("icbm/*.png", target_directory)
  install_items("icbm_warheads/*.png", target_directory)
  install_items("icbm_shell.png", target_directory)
end

def install_yatm_bees
  target_directory = File.expand_path('yatm/yatm_bees/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("bee_box_wood/*.png", target_directory)
  install_built_blocks("bee_box_metal/*.png", target_directory)
  install_built_blocks("bait_box_wood/*.png", target_directory)
  install_built_blocks("bait_box_metal/*.png", target_directory)

  install_blocks("bee_hive/*.png", target_directory)

  install_fluids("honey/*.png", target_directory)
  install_fluids("synthetic_honey/*.png", target_directory)

  install_items("bees/*.png", target_directory)
  install_items("honey_combs/*.png", target_directory)
  install_items("honey_drop.png", target_directory)
  install_items("bee_box_frame.png", target_directory)
end

def install_yatm_brewery
  target_directory = File.expand_path('yatm/yatm_brewery/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("barrel_wood/*.png", target_directory)
  install_built_blocks("barrel_metal/*.png", target_directory)
  install_built_blocks("kettle/*.png", target_directory)

  install_items("yeast/*.png", target_directory)
end

def install_yatm_cables
  target_directory = File.expand_path('yatm/yatm_cables/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_tilemap("small_cable.*/15.png", target_directory)
  install_tilemap("medium_cable.*/15.png", target_directory)
  install_tilemap("dense_cable.*/15.png", target_directory)

  install_built_blocks("copper_cable/*.png", target_directory)
  install_built_blocks("copper_cables/*.png", target_directory)

  install_tilemap("pipe.glass.*/15.png", target_directory)
  install_tilemap("pipe.red.black.*/15.png", target_directory)
  install_tilemap("pipe.yellow.black.*/15.png", target_directory)
  install_tilemap("pipe.t4x4/15.png", target_directory)
end

def install_yatm_culinary
  target_directory = File.expand_path('yatm/yatm_culinary/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("pie_dish/*.png", target_directory)
  install_blocks("pie/*.png", target_directory)
  install_blocks("oven/*.png", target_directory)
end

def install_yatm_data_card_readers
  target_directory = File.expand_path('yatm/yatm_data_card_readers/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("card_reader/*.png", target_directory)
end

def install_yatm_data_console_monitor
  target_directory = File.expand_path('yatm/yatm_data_console_monitor/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  prefix = 'yatm_console'

  install_built_blocks("monitor/back.data.png", target_directory, prefix: prefix)
  install_built_blocks("monitor/bottom.data.flat.png", target_directory, prefix: prefix)
  install_built_blocks("monitor/bottom.data.png", target_directory, prefix: prefix)
  install_built_blocks("monitor/front.console.*.png", target_directory, prefix: prefix)
  install_built_blocks("monitor/side.flat.png", target_directory, prefix: prefix)
  install_built_blocks("monitor/side.png", target_directory, prefix: prefix)
  install_built_blocks("monitor/top.flat.png", target_directory, prefix: prefix)
  install_built_blocks("monitor/top.png", target_directory, prefix: prefix)
end

def install_yatm_data_control
  target_directory = File.expand_path('yatm/yatm_data_control/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("data_control_plane/*.png", target_directory)

  install_built_gui("colored_buttons/*.png", target_directory)
  install_built_gui("colored_switches/*.png", target_directory)
  install_built_gui("colored_rotary_buttons/*.png", target_directory)
  install_gui("button.*.png", target_directory)
end

def install_yatm_cluster_thermal
  target_directory = File.expand_path('yatm/yatm_cluster_thermal/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory
end

def install_yatm_clusters
  target_directory = File.expand_path('yatm/yatm_clusters/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

end

def install_yatm_core
  target_directory = File.expand_path('yatm/yatm_core/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_items("hammer.*.png", target_directory)
  install_items("keycard.*.png", target_directory)

  install_items("materials/capacitor.*.png", target_directory)
  install_items("materials/circuit_board.*.png", target_directory)
  install_items("materials/dust.*.png", target_directory)
  install_items("materials/gear.*.png", target_directory)
  install_items("materials/ic.png", target_directory)
  install_items("materials/ingot.*.png", target_directory)
  install_items("materials/plate.*.png", target_directory)
  install_items("materials/spool.*.png", target_directory)
  install_items("materials/transformer.*.png", target_directory)
  install_items("materials/vacuum_tube.*.png", target_directory)
  install_items("bucket/empty.png",   target_directory)
  install_items("bucket/fluid.mask.png",   target_directory)

  install_items("wrench.png",   target_directory)

  install_blocks("face_debug/*.png", target_directory)
  install_blocks("grid.png", target_directory)

  install_gui("gui_formbg_*.png", target_directory)
  install_gui("item_border/*.png", target_directory)
  install_built_gui("gui_formbg_*.png", target_directory)

  install_gui("small_colored_button/*.png", target_directory)
  install_gui("small_switch/*.png", target_directory)
  install_gui("wide_switch/*.png", target_directory)
end

def install_yatm_codex
  target_directory = File.expand_path('yatm/yatm_codex/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_items("codex.png",   target_directory)
  install_items("codex_deploy.png",   target_directory)
end

def install_yatm_data_cables
  target_directory = File.expand_path('yatm/yatm_data_cables/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("data_cable/*.png", target_directory)
  install_blocks("data_cable/bracket.*.png", target_directory)
end

def install_yatm_data_display
  target_directory = File.expand_path('yatm/yatm_data_display/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("data_char_display/*.png", target_directory)
  install_blocks("yatm_blocky_font/*.png", target_directory)
end

def install_yatm_data_fluid_sensor
  target_directory = File.expand_path('yatm/yatm_data_fluid_sensor/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("fluid_sensor/*.png", target_directory)
end

def install_yatm_data_logic
  target_directory = File.expand_path('yatm/yatm_data_logic/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  # installs the arithmetic node textures along with the stamps
  install_blocks("data_arith/**/*.png", target_directory)

  install_blocks("data_buffer/*.png", target_directory)
  install_blocks("data_clock/*.png", target_directory)
  install_blocks("data_comparator/*.png", target_directory)
  install_blocks("data_decoder/*.png", target_directory)
  install_blocks("data_lamp/**/*.png", target_directory)
  install_blocks("data_light_sensor/*.png", target_directory)
  install_blocks("data_memory/*.png", target_directory)
  install_blocks("data_momentary_button/*.png", target_directory)
  install_blocks("data_node_sensor/*.png", target_directory)
  install_blocks("data_proximity_sensor/*.png", target_directory)
  install_blocks("data_pulser/*.png", target_directory)
  install_blocks("data_router/*.png", target_directory)
  install_blocks("data_sequencer/*.png", target_directory)
  install_blocks("data_server/*.png", target_directory)
  install_blocks("data_thermal_sensor/*.png", target_directory)
  install_blocks("data_toggle_button/*.png", target_directory)
  install_blocks("data_wave_generator/*.png", target_directory)
  install_blocks("data_level_display/liquid/{cooling,heating,nuclear}.png", target_directory)
  install_blocks("data_level_display/*.png", target_directory)

  install_items("data_programmer.png", target_directory)
  install_built_items("tokens/*.png", target_directory)
end

def install_yatm_data_network
  target_directory = File.expand_path('yatm/yatm_data_network/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory
end

def install_yatm_data_noteblock
  target_directory = File.expand_path('yatm/yatm_data_noteblock/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("data_noteblock/*.png", target_directory)
end

def install_yatm_data_to_mesecon
  target_directory = File.expand_path('yatm/yatm_data_to_mesecon/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("data_mesecon/*.png", target_directory)
end

def install_yatm_decor
  target_directory = File.expand_path('yatm/yatm_decor/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_tilemap("warning_cells_16x_red.t3x3/15.png", target_directory)
  install_tilemap("warning_cells_16x_white.t3x3/15.png", target_directory)
  install_tilemap("warning_cells_16x_yellow.t3x3/15.png", target_directory)
  install_tilemap("warning_checkers_8x_red.t3x3/15.png", target_directory)
  install_tilemap("warning_checkers_8x_white.t3x3/15.png", target_directory)
  install_tilemap("warning_checkers_8x_yellow.t3x3/15.png", target_directory)
  install_tilemap("warning_stripes_2x_fiber.t3x3/15.png", target_directory)
  install_tilemap("warning_stripes_2x_red.t3x3/15.png", target_directory)
  install_tilemap("warning_stripes_2x_white.t3x3/15.png", target_directory)
  install_tilemap("warning_stripes_2x_yellow.t3x3/15.png", target_directory)
  install_tilemap("warning_stripes_4x_red.t3x3/15.png", target_directory)
  install_tilemap("warning_stripes_4x_white.t3x3/15.png", target_directory)
  install_tilemap("warning_stripes_4x_yellow.t3x3/15.png", target_directory)
  install_tilemap("warning_stripes_8x_red.t3x3/15.png", target_directory)
  install_tilemap("warning_stripes_8x_white.t3x3/15.png", target_directory)
  install_tilemap("warning_stripes_8x_yellow.t3x3/15.png", target_directory)

  install_built_blocks("lamp/*.png", target_directory)

  install_built_blocks("jukebox/*.png", target_directory)

  install_blocks("meshes/*.png", target_directory)
  install_blocks("vents/*.png", target_directory)
end

def install_yatm_device_hubs
  target_directory = File.expand_path('yatm/yatm_device_hubs/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("hub/*.png", target_directory)
  install_blocks("card_hub/*.png", target_directory)
end

def install_yatm_debug
  target_directory = File.expand_path('yatm/yatm_debug/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_items("transport_network_debug_tool.png", target_directory)
  install_items("cluster_tool.png", target_directory)
  install_items("debug_tool.png", target_directory)
end

def install_yatm_drones
  target_directory = File.expand_path('yatm/yatm_drones/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("scavenger_docking_station/*.png", target_directory)

  install_items("scavenger_drone_case.png", target_directory)
  install_items("drone_upgrade/*.png", target_directory)
end

def install_yatm_dscs
  target_directory = File.expand_path('yatm/yatm_dscs/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("drive_case/*.png", target_directory)
  install_built_blocks("assembler/*.png", target_directory)
  install_built_blocks("compute_module/*.png", target_directory)
  install_built_blocks("inventory_controller/*.png", target_directory)

  install_built_blocks("monitor/front.crafting.*.png", target_directory)
  install_built_blocks("monitor/front.ele.*.png", target_directory)
  install_built_blocks("monitor/front.inventory.*.png", target_directory)
  install_built_blocks("monitor/bottom.flat.png", target_directory)
  install_built_blocks("monitor/bottom.png", target_directory)
  install_built_blocks("monitor/back.png", target_directory)
  install_built_blocks("monitor/side.*.png", target_directory)
  install_built_blocks("monitor/side.png", target_directory)
  install_built_blocks("monitor/top.*.png", target_directory)
  install_built_blocks("monitor/top.png", target_directory)

  install_built_blocks("void_chest/*.png", target_directory)
  install_built_blocks("void_crate/*.png", target_directory)

  install_built_blocks("digitizer/*.png", target_directory)
  install_built_blocks("materializer/*.png", target_directory)

  install_built_items("inventory_drives/*.png", target_directory)
end

def install_yatm_energy_storage
  target_directory = File.expand_path('yatm/yatm_energy_storage/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_items("materials/battery.*.png", target_directory)

  install_built_blocks("energy_cell_basic/*.png", target_directory)
  install_built_blocks("energy_cell_dense/*.png", target_directory)
  install_built_blocks("energy_cell_normal/*.png", target_directory)

  install_built_blocks("battery_bank/*.png", target_directory)
end

def install_yatm_energy_storage_array
  target_directory = File.expand_path('yatm/yatm_energy_storage_array/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("array_energy_cell/*.png", target_directory)
  install_built_blocks("array_energy_controller/*.png", target_directory)
end

def install_yatm_fluid_pipes
  target_directory = File.expand_path('yatm/yatm_fluid_pipes/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("fluid_pipe/*.png", target_directory)
end

def install_yatm_fluid_pipe_valves
  target_directory = File.expand_path('yatm/yatm_fluid_pipe_valves/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("fluid_pipe_valve/*.png", target_directory)
end

def install_yatm_fluid_teleporters
  target_directory = File.expand_path('yatm/yatm_fluid_teleporters/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("fluid_teleporter/*.png", target_directory)
end

def install_yatm_fluids
  target_directory = File.expand_path('yatm/yatm_fluids/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_fluids("corium/*.png", target_directory)
  install_fluids("crude_oil/*.png", target_directory)
  install_fluids("garfielium/*.png", target_directory)
  install_fluids("heavy_oil/*.png", target_directory)
  install_fluids("petroleum_gas/*.png", target_directory)
  install_fluids("ice_slurry/*.png", target_directory)
  install_fluids("light_oil/*.png", target_directory)
  install_fluids("nitrogen/*.png", target_directory)
  install_fluids("steam/*.png", target_directory)

  install_blocks("steel_fluid_tank/*.png", target_directory)

  install_built_blocks("fluid_tank/*.png", target_directory)
  install_built_blocks("fluid_replicator/*.png", target_directory)
  install_built_blocks("fluid_nullifier/*.png", target_directory)
end

def install_yatm_foundry
  target_directory = File.expand_path('yatm/yatm_foundry/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("concrete/*.png", target_directory)
  install_built_blocks("concrete_wall/*.png", target_directory)
  install_built_blocks("retaining_wall/*.png", target_directory)
  install_built_blocks("mini_blast_furnace/*.png", target_directory)

  # the electric blocks are powered via the yatm energy network
  install_built_blocks("electric_furnace/*.png", target_directory)
  install_built_blocks("electric_smelter/*.png", target_directory)
  install_built_blocks("electric_molder/*.png", target_directory)
  install_built_blocks("electric_kiln/*.png", target_directory)
  install_built_blocks("heater/*.png", target_directory) # should be electric heater, but meh

  install_built_blocks("solid_fuel_heater/*.png", target_directory)
  # the manual versions are fueled via a solid fuel heater
  install_built_blocks("furnace/*.png", target_directory)
  install_built_blocks("smelter/*.png", target_directory)
  install_built_blocks("molder/*.png", target_directory)
  install_built_blocks("kiln/*.png", target_directory)

  install_built_blocks("stonecutters_table_wood/*.png", target_directory)
  install_built_blocks("stonecutters_table_stone/*.png", target_directory)
  install_built_blocks("stonecutters_table_metal/*.png", target_directory)

  install_built_blocks("metalcutters_table_wood/*.png", target_directory)
  install_built_blocks("metalcutters_table_stone/*.png", target_directory)
  install_built_blocks("metalcutters_table_metal/*.png", target_directory)

  install_blocks("carbon_steel_block/*.png", target_directory)

  install_blocks("carbon_steel_chest/inside.png", target_directory)
  install_built_blocks("carbon_steel_chests/*.png", target_directory)
  install_built_blocks("carbon_steel_lanterns/*.png", target_directory)

  install_fluids("molten_iron/*.png", target_directory)
  install_fluids("molten_carbon_steel/*.png", target_directory)
  install_fluids("molten_copper/*.png", target_directory)
  install_fluids("molten_bronze/*.png", target_directory)
  install_fluids("molten_gold/*.png", target_directory)
  install_fluids("molten_silver/*.png", target_directory)
  install_fluids("molten_tin/*.png", target_directory)
  install_fluids("molten_aluminum/*.png", target_directory)
  install_fluids("molten_glass/*.png", target_directory)

  install_items("mold/*.png", target_directory)
end

def install_yatm_frames
  target_directory = File.expand_path('yatm/yatm_frames/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("frame/*.png", target_directory)
  install_built_blocks("frame_motor/*.png", target_directory)
end

def install_yatm_item_ducts
  target_directory = File.expand_path('yatm/yatm_item_ducts/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("item_duct/*.png", target_directory)
end

def install_yatm_item_hoppers
  target_directory = File.expand_path('yatm/yatm_item_hoppers/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("hopper/*.png", target_directory)
end

def install_yatm_item_shelves
  target_directory = File.expand_path('yatm/yatm_item_shelves/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("shelf_wood/*.png", target_directory)
  install_blocks("shelf_metal/*.png", target_directory)
end

def install_yatm_item_storage
  target_directory = File.expand_path('yatm/yatm_item_storage/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("cardboard_box/*.png", target_directory)
  install_blocks("super_cardboard_box/*.png", target_directory)
  install_blocks("filter_box/item.*.png", target_directory)
end

def install_yatm_item_teleporters
  target_directory = File.expand_path('yatm/yatm_item_teleporters/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("item_teleporter/*.png", target_directory)
end

def install_yatm_machines
  target_directory = File.expand_path('yatm/yatm_machines/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("wireless_emitter/*.png", target_directory)
  install_built_blocks("wireless_receiver/*.png", target_directory)

  install_built_blocks("network_controller/*.png", target_directory)
  #install_built_blocks("network_controller_alt/*.png", target_directory)

  install_built_blocks("server_controller/*.png", target_directory)
  install_built_blocks("server_rack/*.png", target_directory)
  install_built_blocks("server/*.png", target_directory)

  install_built_blocks("auto_crafter/*.png", target_directory)

  install_built_blocks("crystal_cauldron/*.png", target_directory)

  install_built_blocks("crusher/*.png", target_directory)
  install_built_blocks("grinder/*.png", target_directory)
  install_built_blocks("auto_grinder/*.png", target_directory)
  install_built_blocks("compactor/*.png", target_directory)
  install_built_blocks("mixer/*.png", target_directory)
  install_built_blocks("electrolyser/*.png", target_directory)

  install_built_blocks("pylon/*.png", target_directory)

  install_built_blocks("roller/*.png", target_directory)

  install_built_blocks("thermal_plate/*.png", target_directory)

  install_built_blocks("item_replicator/*.png", target_directory)

  install_built_blocks("freezer/*.png", target_directory)
  install_built_blocks("condenser/*.png", target_directory)

  install_built_blocks("steam_turbine/*.png", target_directory)
  install_built_blocks("coal_generator/*.png", target_directory)
  install_built_blocks("combustion_engine/*.png", target_directory)
  install_built_blocks("creative_engine/*.png", target_directory)
end

def install_yatm_mail
  target_directory = File.expand_path('yatm/yatm_mail/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("mailbox_wood/*.png", target_directory)
  install_built_blocks("mailbox_metal/*.png", target_directory)

  install_built_blocks("package/*.png", target_directory)
end

def install_yatm_mesecon_buttons
  target_directory = File.expand_path('yatm/yatm_mesecon_buttons/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("mesecon_button/*.png", target_directory)
end

def install_yatm_mesecon_hubs
  target_directory = File.expand_path('yatm/yatm_mesecon_hubs/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("mesecon_hub/*.png", target_directory)

  install_items("hub_address_tool.png", target_directory)
  install_items("hub_remote_control.png", target_directory)
end

def install_yatm_mesecon_sequencer
  target_directory = File.expand_path('yatm/yatm_mesecon_sequencer/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("mesecon_sequencer/*.png", target_directory)
end

def install_yatm_mesecon_locks
  target_directory = File.expand_path('yatm/yatm_mesecon_locks/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("mesecon_lock/*.png", target_directory)
end

def install_yatm_mesecon_card_readers
  target_directory = File.expand_path('yatm/yatm_mesecon_card_readers/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("card_reader/*.png", target_directory)
end

def install_yatm_mining
  target_directory = File.expand_path('yatm/yatm_mining/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("quarry/*.png", target_directory)
  install_built_blocks("surface_drill/*.png", target_directory)
  install_built_blocks("mining_drone/*.png", target_directory)

  install_blocks("quarry_wall/*.png", target_directory)
end

def install_yatm_oku
  target_directory = File.expand_path('yatm/yatm_oku/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("floppy_disk_drive/*.png", target_directory)
  install_built_blocks("computer/*.png", target_directory)
  install_built_blocks("oku_micro_controller/*.png", target_directory)

  install_built_items("floppy_disks/*.png", target_directory)
end

def install_yatm_overhead_rails
  target_directory = File.expand_path('yatm/yatm_overhead_rails/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("overhead_rails/*.png", target_directory)
  install_blocks("overhead_docking_station/**/*.png", target_directory)
  install_blocks("docking_crate/*.png", target_directory)
end

def install_yatm_packs
  target_directory = File.expand_path('yatm/yatm_packs/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("ammo_pack/*.png", target_directory)
  install_blocks("health_pack/*.png", target_directory)
  install_blocks("mana_pack/*.png", target_directory)

  install_items("ammo_pack_pouch.png", target_directory)
  install_items("health_pack_pouch.png", target_directory)
  install_items("mana_pack_pouch.png", target_directory)
end

def install_yatm_papercraft
  target_directory = File.expand_path('yatm/yatm_papercraft/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("painting_canvas/*.png", target_directory)
  install_built_blocks("shoji_lamp/*.png", target_directory)
  install_blocks("shoji_door/*.png", target_directory)
  install_blocks("shoji_panel/*.png", target_directory)

  install_items("cardboard/*.png", target_directory)
  install_items("fluid_box/*.png", target_directory)
  install_items("paper/*.png", target_directory)
  install_items("waxed_cardboard/*.png", target_directory)
  install_items("painting_brush/*.png", target_directory)
  install_items("fluid_box.png", target_directory)

  install_built_paintings("*.png", target_directory, prefix: "yatm_painting")
end

def install_yatm_plastics
  target_directory = File.expand_path('yatm/yatm_plastics/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("plastic_panel/*.png", target_directory)
end

def install_yatm_rails
  target_directory = File.expand_path('yatm/yatm_rails/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory
end

def install_yatm_reactions
  target_directory = File.expand_path('yatm/yatm_reactions/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory
end

def install_yatm_reactors
  target_directory = File.expand_path('yatm/yatm_reactors/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("reactor/**/*.png", target_directory)
  install_items("nuclear_pellets/*.png", target_directory)
end

def install_yatm_refinery
  target_directory = File.expand_path('yatm/yatm_refinery/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("boiler/*.png", target_directory)
  install_blocks("thermal_boiler/*.png", target_directory)
  install_built_blocks("vapourizer/*.png", target_directory)
  install_built_blocks("distillation_unit/*.png", target_directory)
  install_built_blocks("pump/*.png", target_directory)

  install_fluids("vapourized_crude_oil/*.png", target_directory)
  install_fluids("vapourized_heavy_oil/*.png", target_directory)
  install_fluids("vapourized_light_oil/*.png", target_directory)
end

def install_yatm_security
  target_directory = File.expand_path('yatm/yatm_security/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("locksmiths_table_wood/*.png", target_directory)
  install_built_blocks("locksmiths_table_metal/*.png", target_directory)
  install_built_blocks("programmers_table/*.png", target_directory)

  install_items("lock.png", target_directory)
  install_built_items("key/*.png", target_directory)
  install_built_items("access_cards/*.png", target_directory)
  install_built_items("access_chips/*.png", target_directory)

  install_gui("pattern_bits/*.png", target_directory)
end

def install_yatm_solar_energy
  target_directory = File.expand_path('yatm/yatm_solar_energy/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("solar_panel/*.png", target_directory)
  install_items("photovoltaic_cell.png", target_directory)
end

def install_yatm_spacetime
  target_directory = File.expand_path('yatm/yatm_spacetime/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_items("address_tool.png", target_directory)

  install_built_blocks("teleporter/*.png", target_directory)
  install_built_blocks("teleporter_port/*.png", target_directory)
  install_built_blocks("teleporter_relay/*.png", target_directory)
  install_built_blocks("teleporter_gate_controller/*.png", target_directory)
  install_blocks("teleporter_gate/part/*.png", target_directory)
end

def install_yatm_thermal_ducts
  target_directory = File.expand_path('yatm/yatm_thermal_ducts/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_built_blocks("thermal_duct/*.png", target_directory)
  install_built_blocks("thermal_node/*.png", target_directory)
end

def install_yatm_woodcraft
  target_directory = File.expand_path('yatm/yatm_woodcraft/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("dust_bin/*.png", target_directory)
  install_blocks("sawdust/*.png", target_directory)
  install_blocks("crafting_table/*.png", target_directory)
  install_built_blocks("wood_sawmill/*.png", target_directory)

  install_items("sawdust.png", target_directory)
end

def install_yatm_woodcraft_default
  target_directory = File.expand_path('yatm/yatm_woodcraft_default/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("wood_core_default/*.png", target_directory)
end

def install_yatm_woodcraft_nokore
  target_directory = File.expand_path('yatm/yatm_woodcraft_nokore/textures', @mods_root)

  FileUtils.rm_rf target_directory
  FileUtils.mkdir target_directory

  install_blocks("wood_core_nokore/*.png", target_directory)
end

install_harmonia_crystals
install_harmonia_element
install_harmonia_exp
install_harmonia_mana
install_harmonia_mycology
install_harmonia_pottery
install_harmonia_spirits
install_harmonia_totems
install_harmonia_treasure
install_hsw_hud
install_hsw_materials
install_hsw_tools
install_hsw_workbench
install_yatm_armoury
install_yatm_armoury_c4
install_yatm_armoury_icbm
install_yatm_bees
install_yatm_brewery
install_yatm_cables
install_yatm_cluster_thermal
install_yatm_clusters
install_yatm_codex
install_yatm_core
install_yatm_culinary
install_yatm_data_cables
install_yatm_data_card_readers
install_yatm_data_console_monitor
install_yatm_data_control
install_yatm_data_display
install_yatm_data_fluid_sensor
install_yatm_data_logic
install_yatm_data_network
install_yatm_data_noteblock
install_yatm_data_to_mesecon
install_yatm_debug
install_yatm_decor
install_yatm_device_hubs
install_yatm_drones
install_yatm_dscs
install_yatm_energy_storage
install_yatm_energy_storage_array
install_yatm_fluid_pipe_valves
install_yatm_fluid_pipes
install_yatm_fluid_teleporters
install_yatm_fluids
install_yatm_foundry
install_yatm_frames
install_yatm_item_ducts
install_yatm_item_hoppers
install_yatm_item_shelves
install_yatm_item_storage
install_yatm_item_teleporters
install_yatm_machines
install_yatm_mail
install_yatm_mesecon_buttons
install_yatm_mesecon_hubs
install_yatm_mesecon_sequencer
install_yatm_mesecon_locks
install_yatm_mining
install_yatm_oku
install_yatm_overhead_rails
install_yatm_packs
install_yatm_papercraft
install_yatm_plastics
install_yatm_rails
install_yatm_reactions
install_yatm_reactors
install_yatm_refinery
install_yatm_security
install_yatm_solar_energy
install_yatm_spacetime
install_yatm_thermal_ducts
install_yatm_woodcraft
install_yatm_woodcraft_default
install_yatm_woodcraft_nokore
