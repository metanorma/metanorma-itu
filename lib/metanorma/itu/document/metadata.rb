# frozen_string_literal: true

module Metanorma
  module Itu::Document
    module Metadata
      autoload :ItuBibDataExtensionType,
               "#{__dir__}/metadata/itu_bib_data_extension_type"
      autoload :ItuBibliographicItem,
               "#{__dir__}/metadata/itu_bibliographic_item"
      autoload :ItuSeries, "#{__dir__}/metadata/itu_series"
      autoload :ItuStructuredIdentifier,
               "#{__dir__}/metadata/itu_structured_identifier"
      autoload :StudyPeriod, "#{__dir__}/metadata/study_period"
      autoload :MeetingDate, "#{__dir__}/metadata/meeting_date"
      autoload :MeetingElement, "#{__dir__}/metadata/meeting_element"
    end
  end
end
