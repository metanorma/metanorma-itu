# frozen_string_literal: true

require "metanorma/iso/html"

module Metanorma
  module Itu
    # HTML format slice for the flavor: the renderer, registered with
    # the harness from itu/document.rb. Renders iso-style; the renderer
    # registers the ITU root (and the shared standoc sections it uses)
    # so the harness dispatch reaches them.
    module Html
      autoload :Renderer, "#{__dir__}/html/renderer"
    end
  end
end
