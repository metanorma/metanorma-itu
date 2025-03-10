module IsoDoc
  module Itu
    class I18n < IsoDoc::I18n
      def load_file(fname)
        f = File.join(File.dirname(__FILE__), fname)
        File.exist?(f) ? YAML.load_file(f) : {}
      end

      def load_yaml1(lang, script)
        y = load_file("i18n-#{yaml_lang(lang, script)}.yaml")
        y.empty? ? load_file("i18n-en.yaml").merge(super) : super.deep_merge(y)
      end
    end
  end
end
