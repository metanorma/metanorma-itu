require "isodoc"
require_relative "metadata"
require_relative "xref"

module IsoDoc
  module ITU
    module Init
      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def xref_init(lang, script, klass, labels, options)
        html = HtmlConvert.new(language: lang, script: script)
        options = options.merge(hierarchical_assets: @hierarchical_assets)
        @xrefs = Xref.new(lang, script, html, labels, options)
      end

      def load_yaml(lang, script)
        y = if @i18nyaml then YAML.load_file(@i18nyaml)
            elsif lang == "en"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            else
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            end
        super.merge(y)
      end

    end
  end
end

