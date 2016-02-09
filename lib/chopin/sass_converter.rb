require 'sass'

module SassConverter
  def self.convert(source, destination, type)
    engine = Sass::Engine.new(File.new(source).read, syntax: type)
    File.new(destination_css, 'w').write(engine.render)
  end
end
