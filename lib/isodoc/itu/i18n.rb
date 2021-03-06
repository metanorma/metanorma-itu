module IsoDoc
  module ITU
    class I18n < IsoDoc::I18n
       def load_yaml1(lang, script)
        y = if lang == "en"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            else
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            end
        super.merge(y)
      end
    end
  end
end
