# frozen_string_literal: true

module Metanorma
  module Itu::Document
    module Metadata
      # Series classification for ITU documents.
      class ItuSeries < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :title, Metanorma::Document::Components::DataTypes::LocalizedString,
                  collection: true
        attribute :number, :string

        xml do
          element "series"
          map_attribute "type", to: :type
          map_element "title", to: :title
          map_element "number", to: :number
        end
      end
    end
  end
end
