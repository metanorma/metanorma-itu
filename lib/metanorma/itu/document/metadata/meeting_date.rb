# frozen_string_literal: true

module Metanorma
  module Itu::Document
    module Metadata
      class MeetingDate < Lutaml::Model::Serializable
        attribute :from, :string
        attribute :to, :string

        xml do
          element "meeting-date"
          map_element "from", to: :from
          map_element "to", to: :to
        end
      end
    end
  end
end
