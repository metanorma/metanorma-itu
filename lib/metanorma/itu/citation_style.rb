require "relaton-render"

module Metanorma
  module Itu
    #
    # The ITU flavor's citation renderer: an extension of the
    # relaton-render General facade carrying this gem's CitationStyle
    # instance. Supersedes the 1.x stack this gem carried under
    # lib/metanorma/itu/relaton_render, which subclassed relaton-render
    # 1.x internals that the 3.0.0.pre engine no longer ships.
    #
    class CitationStyle < ::Relaton::Render::General
      STYLE_PATH = File.join(__dir__, "itu-style.yml")

      # The ITU presentation-of-models rules are engine-registered
      # (itu_identifier) and selected as pack data in itu-style.yml

      def initialize(options = {})
        super
        options = deep_symbolize(options)
        @renderer = ::Relaton::Render::Iso690::Renderer.new(
          lang: @lang,
          script: options[:script] || "Latn",
          labels: options[:i18nhash] || {},
          style: options[:style] || STYLE_PATH,
        )
      end
    end
  end
end
