module Metanorma
  module Itu
    class Converter
      ITU_LOG_MESSAGES = {
        # rubocop:disable Naming/VariableNumber
        "ITU_1": { category: "Document Attributes",
                   error: "%s is not a recognised document type",
                   severity: 2 },
        "ITU_2": { category: "Document Attributes",
                   error: "%s is not a recognised status",
                   severity: 2 },
        "ITU_3": { category: "Document Attributes",
                   error: "Title includes series name %s",
                   severity: 2 },
        "ITU_4": { category: "Style",
                   error: "Requirement possibly in preface: %s",
                   severity: 2 },
        "ITU_6": { category: "Document Attributes",
                   error: "Recommendation Status %s inconsistent with AAP",
                   severity: 2 },
        "ITU_7": { category: "Document Attributes",
                   error: "Recommendation Status %s inconsistent with TAP",
                   severity: 2 },
        "ITU_8": { category: "Style",
                   error: "%s does not match ITU document identifier conventions",
                   severity: 2 },
        "ITU_9": { category: "Style",
                   error: "Unnumbered clause out of place",
                   severity: 2 },
        "ITU_10": { category: "Style",
                    error: "No Summary has been provided",
                    severity: 2 },
        "ITU_11": { category: "Style",
                    error: "No Keywords have been provided",
                    severity: 2 },
        "ITU_12": { category: "Style",
                    error: "(terms) %s: %s",
                    severity: 2 },
      }.freeze
      # rubocop:enable Naming/VariableNumber

      def log_messages
        super.merge(ITU_LOG_MESSAGES)
      end
    end
  end
end
