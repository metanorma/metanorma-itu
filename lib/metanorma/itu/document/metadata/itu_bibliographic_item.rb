# frozen_string_literal: true

module Metanorma
  module Itu::Document
    module Metadata
      # The bibliographical description of an ITU document.
      # Adds keyword, series, and ITU-specific extension elements.
      class ItuBibliographicItem < Metanorma::IsoDocument::Metadata::IsoBibliographicItem
        attribute :keyword, :string, collection: true
        attribute :series, ItuSeries, collection: true
        attribute :ext, ItuBibDataExtensionType

        xml do
          element "bibdata"
          map_element "keyword", to: :keyword
          map_element "series", to: :series
        end
      end
    end
  end
end
