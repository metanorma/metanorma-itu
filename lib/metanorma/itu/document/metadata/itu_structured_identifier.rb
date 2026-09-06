# frozen_string_literal: true

module Metanorma
  module Itu::Document
    module Metadata
      # Structured identifier for ITU documents (bureau + docnumber).
      class ItuStructuredIdentifier < Lutaml::Model::Serializable
        attribute :project_number, Metanorma::IsoDocument::Metadata::ProjectNumber
        attribute :bureau, :string
        attribute :docnumber, :string
        attribute :annexid, :string

        xml do
          element "structuredidentifier"
          map_element "project-number", to: :project_number
          map_element "bureau", to: :bureau
          map_element "docnumber", to: :docnumber
          map_element "annexid", to: :annexid
        end
      end
    end
  end
end
