require "isodoc"
require_relative "metadata"
require_relative "xref"
require_relative "i18n"

module IsoDoc
  module ITU
    module Init
      def metadata_init(lang, script, i18n)
        @meta = Metadata.new(lang, script, i18n)
      end

      def xref_init(lang, script, _klass, i18n, options)
        html = HtmlConvert.new(language: lang, script: script)
        options = options.merge(hierarchical_assets: @hierarchical_assets)
        @xrefs = Xref.new(lang, script, html, i18n, options)
      end

      def i18n_init(lang, script, i18nyaml = nil)
        @i18n = I18n.new(lang, script, i18nyaml || @i18nyaml)
      end

      def fileloc(loc)
        File.join(File.dirname(__FILE__), loc)
      end
    end
  end
end
