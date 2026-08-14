# frozen_string_literal: true

module Metanorma
  module Itu::Document
    module Metadata
      class ItuBibDataExtensionType < Metanorma::IsoDocument::Metadata::IsoBibDataExtensionType
        attribute :structuredidentifier, ItuStructuredIdentifier
        attribute :ip_notice_received, :string
        attribute :studyperiod, StudyPeriod
        attribute :meeting, MeetingElement
        attribute :meeting_date, MeetingDate
        attribute :meeting_place, :string

        xml do
          element "ext"
          map_element "structuredidentifier", to: :structuredidentifier
          map_element "ip-notice-received", to: :ip_notice_received
          map_element "studyperiod", to: :studyperiod
          map_element "meeting", to: :meeting
          map_element "meeting-date", to: :meeting_date
          map_element "meeting-place", to: :meeting_place
        end
      end
    end
  end
end
