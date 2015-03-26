require 'erb'
require 'fileutils'
require 'redcarpet'

BLUE = "\033[0;34m"
GREEN = "\033[0;32m"
GRAY = "\033[1;30m"
PURPLE = "\033[0;35m"
WHITE = "\033[0m"

class Chopin
  def initialize(src_path = nil, dest_path = nil)
    Dir.mkdir(dest_path) unless Dir.exist?(dest_path) || File.exist?(dest_path)

    @src_path = File.realpath(src_path.nil? ? '.' : src_path)
    @dest_path = File.realpath(dest_path.nil? ? '.dist' : dest_path)
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)

    puts "Source      : #{@src_path}"
    puts "Destination : #{@dest_path}"
    puts
  end

  def build(src_path = @src_path, dest_path = @dest_path, layout = nil)
    puts "File #{dest_path} exists" if File.exist?(dest_path)
    puts "Directory #{dest_path} exists" if Dir.exist?(dest_path)
    Dir.mkdir(dest_path) unless Dir.exist?(dest_path)

    src_dir = Dir.new(src_path)
    dest_dir = Dir.new(dest_path)

    if File.exist?("#{src_path}/layout.erb")
      layout = "#{src_path}/layout.erb"
    end

    sub_directories = []

    src_dir.each do |entry|
      next if entry[0] == '.'

      source = "#{src_path}/#{entry}"
      destination = "#{dest_path}/#{entry}"

      if File.directory?(source)
        sub_directories << [source, destination]
      else
        case File.extname(entry)
        when '.erb'
          unless entry == 'layout.erb'
            process_erb(source, layout, destination.sub('.erb', '.html'))
          end
        when '.md'
          process_markdown(source, layout, destination.sub('.md', '.html'))
        else
          copy_file(source, destination)
        end
      end
    end

    sub_directories.each do |source, destination|
      build(source, destination, layout)
    end
  end

  def copy_file(source, destination)
    print "  #{rel_src_path source} => "
    FileUtils.cp(source, destination)
    puts " #{GREEN}#{rel_dest_path destination}#{WHITE}"
  end

  def process_erb(source, layout, destination)
    print "  #{rel_src_path source} [#{rel_src_path File.realpath(layout)}] => "
    render = Proc.new { ERB.new(File.read(source)).result }
    output = ERB.new(File.read(layout)).result(nil, &render)
    File.new(destination, 'w').write(output)
    puts "#{GREEN}#{rel_dest_path destination}#{WHITE}"
  end

  def process_markdown(source, layout, destination)
    print "  #{rel_src_path source} [#{rel_src_path File.realpath(layout)}] => "
    render = Proc.new { @markdown.render(File.new(source).read) }
    output = ERB.new(File.read(layout)).result(nil, &render)
    File.new(destination, 'w').write(output)
    puts "#{GREEN}#{rel_dest_path destination}#{WHITE}"
  end

  def rel_dest_path(path)
    path.sub("#{@dest_path}/", '')
  end

  def rel_src_path(path)
    path.sub("#{@src_path}/", '')
  end
end
