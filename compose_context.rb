require 'fileutils'
require 'json'

module Compose
  class Context
    attr_reader :modified

    def initialize(name)
      @name = name
      @loaded = {}
      @references = {}
      @root_dir = Pathname.new(__dir__)
      @tmp_dir = @root_dir.join('build/tmp/graphs')

      @modified = false
      @filename = File.join(@tmp_dir.to_s, name + '.refs')
      if File.exist?(@filename)
        load_file()
      else
        @modified = true
      end
    end

    protected def load_file()
      data = JSON.load(File.read(@filename))

      data["loaded"].each do |(filename, mtime)|
        if File.exist?(filename)
          if File.stat(filename).mtime.to_i != mtime
            puts "File: #{filename} was modified"
            @modified = true
          else
            @loaded[filename] = mtime
          end
        else
          @modified = true
        end
      end

    end

    def save_file()
      puts "Saving context: #{@filename}"
      FileUtils.mkdir_p(File.dirname(@filename))

      File.write(@filename, JSON.dump({
        loaded: @loaded,
      }))
    end

    def is_reference?(child)
      !!@loaded[child]
    end

    def add_reference(parent, child)
      if child
        if parent
          (@references[parent] ||={})[child] = true
        end
        @references[child] ||= {}
        @loaded[child] ||= begin
          @modified = true
          File.stat(child).mtime.to_i
        end
      end
      self
    end
  end
end
