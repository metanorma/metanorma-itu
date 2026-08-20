# frozen_string_literal: true

module Metanorma
  module Itu::Document
    module Metadata
      class StudyPeriod < Lutaml::Model::Serializable
        attribute :start, :string
        attribute :end_year, :string

        xml do
          element "studyperiod"
          map_element "start", to: :start
          map_element "end", to: :end_year
        end
      end
    end
  end
end
