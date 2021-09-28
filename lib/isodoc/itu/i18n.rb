module IsoDoc
  module ITU
    class I18n < IsoDoc::I18n
      def load_yaml2x(str)
        YAML.load_file(File.join(File.dirname(__FILE__),
                                 "i18n-#{str}.yaml"))
      end

      def load_yaml1(lang, script)
        y = case lang
            when "en", "fr", "ru", "de", "es", "ar"
              load_yaml2x(lang)
            when "zh"
              if script == "Hans" then load_yaml2x("zh-Hans")
              else load_yaml2x("en")
              end
            else load_yaml2x("en")
            end
        super.merge(y)
      end
    end
  end
end
