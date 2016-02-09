require 'pygments'
require 'redcarpet'

class PygmentsRenderer < Redcarpet::Render::SmartyHTML
  def block_code(code, language)
    Pygments.highlight(code, lexer: language)
  end
end
