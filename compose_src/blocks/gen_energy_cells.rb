#!/usr/bin/env ruby
require 'json'
require 'fileutils'

cells = %w[energy_cell_basic energy_cell_normal energy_cell_dense]
stages = %w[Creative Stage0 Stage1 Stage2 Stage3 Stage4 Stage5 Stage6 Stage7]

cells.each do |cell_type|
  FileUtils.mkdir_p cell_type

  stages.each do |stage|
    stage_name = stage.downcase

    filename = File.join(cell_type, stage_name + '.json')

    payload = {
      "$includes" => ["blocks/_energy_cell_common/animation"],
      "output" => "blocks/#{cell_type}/#{stage_name}",
      "layers" => Hash[4.times.map do |i|
        ["anim.#{i}", {
          "texture" => "blocks/#{cell_type}/anim-#{stage}/frame_%04d.png" % i
        }]
      end]
    }

    File.write(filename, JSON.pretty_generate(payload))
  end
end
