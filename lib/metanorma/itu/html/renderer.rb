# frozen_string_literal: true

module Metanorma
  module Itu
    module Html
      # ITU documents render iso-style; the ITU root uses the shared
      # standoc section classes, which are registered here alongside
      # it (the harness dispatch is exact-class, OGC-style).
      class Renderer < Metanorma::Iso::Html::Renderer
        register_render "Metanorma::Itu::Document::Root", :render_document
        register_render "Metanorma::Standoc::Document::Sections::Preface",
                        :render_preface
        register_render "Metanorma::Standoc::Document::Sections::ClauseSection",
                        :render_clause
        register_render "Metanorma::Standoc::Document::Sections::AnnexSection",
                        :render_annex
        register_render "Metanorma::Standoc::Document::Sections::ContentSection",
                        :render_clause
        register_render "Metanorma::Standoc::Document::Sections::TermsSection",
                        :render_terms_section
        register_render "Metanorma::Standoc::Document::Sections::BibliographySection",
                        :render_clause
        register_render "Metanorma::Standoc::Document::Sections::DefinitionSection",
                        :render_clause
      end
    end
  end
end
