# frozen_string_literal: true

module Metanorma
  module Itu::Document
    module Metadata
      class MeetingElement < Lutaml::Model::Serializable
        attribute :acronym, :string
        attribute :text, :string

        xml do
          element "meeting"
          map_attribute "acronym", to: :acronym
          map_content to: :text
        end
      end
    end
  end
end
