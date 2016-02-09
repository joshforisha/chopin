Gem::Specification.new do |s|
  s.name = 'chopin'
  s.version = '0.0.5'
  s.license = 'MIT'
  s.summary = 'Chopin'
  s.description = 'An elegant, simple static site generator'
  s.authors = ['Josh Forisha']
  s.email = 'josh@forisha.com'
  s.homepage = 'https://github.com/joshforisha/chopin'
  s.executables = ['chopin']
  s.files = ['lib/chopin.rb', 'lib/chopin/pygments_renderer.rb']

  s.add_runtime_dependency 'pygments.rb', ['= 0.6.3']
  s.add_runtime_dependency 'redcarpet', ['= 3.3.4']
  s.add_runtime_dependency 'sass', ['= 3.4.21']
end
