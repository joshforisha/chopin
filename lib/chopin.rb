require 'chopin/pygments_renderer'
require 'erb'
require 'fileutils'
require 'redcarpet'
require 'sass'

module Chopin
  def self.convert_sass(source, type)
    puts "#{source} : #{File.dirname(source)}"
    Sass::Engine.new(File.new(source).read,
      load_paths: [File.dirname(source)],
      syntax: type
    ).render
  end

  def self.copy(source, destination, layout = nil)
    if File.directory?(source)
      unless Dir.exists?(destination)
        Dir.mkdir(destination)
        puts " #{GREEN}Create#{WHITE} #{destination}"
      end

      source_directory = Dir.new(source)
      destination_directory = Dir.new(destination)

      layout = "#{source}/layout.erb" if File.exist?("#{source}/layout.erb")

      source_directory.each do |file|
        next if file == '.' || file == '..'

        if file[0] == '.'
          puts " #{RED}Ignore#{WHITE} #{source}/#{file}"
          next
        end

        copy("#{source}/#{file}", "#{destination}/#{file}", layout)
      end
    else
      case File.extname(source)
        when '.erb'
          unless File.basename(source) == 'layout.erb'
            destination_html = destination.sub('.erb', '.html')
            puts " #{PURPLE}Parse#{WHITE} #{source} (into #{layout}) -> #{destination_html}"
            render = Proc.new { ERB.new(File.read(source)).result }
            output = ERB.new(File.read(layout)).result(nil, &render)
            File.new(destination_html, 'w').write(output)
          end

        when '.md'
          destination_html = destination.sub('.md', '.html')
          puts " #{PURPLE}Parse#{WHITE} #{source} (into #{layout}) -> #{destination_html}"
          render = Proc.new { MARKDOWN.render(File.new(source).read) }
          output = ERB.new(File.read(layout)).result(nil, &render)
          File.new(destination_html, 'w').write(output)

        when '.sass'
          unless File.basename(source)[0] == '_'
            destination_css = destination.sub('.sass', '.css')
            puts " #{CYAN}Convert#{WHITE} #{source} -> #{destination_css}"
            File.new(destination_css, 'w').write(convert_sass(source, :sass))
          end

        when '.scss'
          unless File.basename(source)[0] == '_'
            destination_css = destination.sub('.scss', '.css')
            puts " #{CYAN}Convert#{WHITE} #{source} -> #{destination_css}"
            File.new(destination_css, 'w').write(convert_sass(source, :scss))
          end

        else
          puts " #{BLUE}Copy#{WHITE} #{source} -> #{destination}"
          FileUtils.cp(source, destination)
      end
    end
  end

  private

  BLUE = "\033[0;34m"
  GREEN = "\033[0;32m"
  PURPLE = "\033[0;35m"
  RED = "\033[0;31m"
  CYAN = "\033[0;36m"
  WHITE = "\033[0m"

  MARKDOWN = Redcarpet::Markdown.new(PygmentsRenderer,
    disable_indented_code_blocks: true,
    fenced_code_blocks: true,
    footnotes: true,
    no_intra_emphasis: true,
    prettify: true,
    quote: true,
    tables: true
  )
end
