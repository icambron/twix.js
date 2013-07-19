require 'slim'
require 'pygments'

class Syntactical < Redcarpet::Render::HTML
  def block_code(code, language)
    Pygments.highlight(code, lexer: language)
  end
end

class SyntacticalTemplate < Tilt::RedcarpetTemplate::Redcarpet2
  def generate_renderer
    Syntactical
  end
end

Slim::Embedded.set_default_options(
  :markdown => {
    :renderer            => Syntactical,
    :no_intra_emphasis   => true,
    :tables              => true,
    :gh_blockcode        => true,
    :fenced_code_blocks  => true,
    :strikethrough       => true,
    :lax_html_blocks     => true,
    :space_after_headers => false,
    :superscript         => true
  }
)
