# frozen_string_literal: true

module Metanorma
  module Itu
    # ITU-specific data elements extending the engine's ISO 690
    # vocabulary, passed to the renderer as its element map
    module ItuElements
      # ITU prefixes the ISBN and ISSN kinds it cites with the kind
      # label ("ISBN: X" over the engine's "ISBN X")
      class ItuIdentifier < ::Relaton::Render::Iso690::Elements::Identifier
        private

        def render_id(docidentifier)
          return "#{docidentifier.type}: #{docidentifier.content}" if
            %w[ISBN ISSN].include?(docidentifier.type)

          super
        end
      end
    end
  end
end
