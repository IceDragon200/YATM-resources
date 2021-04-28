require 'fileutils'
require 'json'

module Compose
  class Context
    attr_reader :modified

    def initialize(name, root_dir: nil)
      @name = name
      @loaded = {}
      @references = {}
      @loaded_tags = {}
      @tags = {}
      @root_dir = Pathname.new(root_dir || __dir__)
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

      case data
      when Hash
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

        if data["tags"] then
          data["tags"].each do |(key, value)|
            @loaded_tags[key] = value
          end
        end
      else
        warn "possibly bad compose-context file '#{@filename}'"
        @modified = true
      end
    end

    def save_file()
      if is_modified?
        puts "Saving context: #{@filename}"
        FileUtils.mkdir_p(File.dirname(@filename))
        File.write(@filename, JSON.dump({
          "tags" => @tags,
          "loaded" => @loaded,
        }))
      else
        puts "Not Modified: #{@filename}"
      end
    end

    def is_reference?(child)
      !!@loaded[child]
    end


    # Determines if all the loaded files are also referenced
    def all_loaded_references?
      @loaded.all? do |name|
        !!@references[name]
      end
    end

    def tags_diff
      keys = @tags.keys | @loaded_tags.keys

      result = {}

      keys.each do |key|
        unless @tags[key] == @loaded_tags[key]
          if @tags.key?(key) and @loaded_tags.key?(key)
            result[key] = {
              reason: :tag_mismatch,
              current: @tags[key],
              loaded: @loaded_tags[key]
            }
          elsif not @tags.key?(key)
            result[key] = :missing_from_current
          elsif not @loaded_tags.key?(key)
            result[key] = :missing_from_loaded
          end
        end
      end

      result
    end

    def all_tags_referenced?
      keys = @tags.keys | @loaded_tags.keys

      keys.all? do |key|
        @tags[key] == @loaded_tags[key]
      end
    end

    def is_modified?
      @modified or
      #not all_loaded_references? or
      not all_tags_referenced?
    end

    def tag(key, value)
      case value
      when String
        if @loaded_tags[key] == value then
          @tags[key] = @loaded_tags[key]
        else
          @tags[key] = value
          @modified = true
        end
      else
        raise "tag value MUST be a string got #{value.inspect}"
      end
      self
    end

    def add_reference(parent, child)
      case child
      when nil
        :ok
      when String
        if parent
          (@references[parent] ||={})[child] = true
        end
        @references[child] ||= {}
        @loaded[child] ||= begin
          @modified = true
          File.stat(child).mtime.to_i
        end
      else
        raise "unexpected child #{child.inspect}"
      end
      self
    end
  end
end
