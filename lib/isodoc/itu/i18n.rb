module IsoDoc
  module ITU
    class I18n < IsoDoc::I18n
       def load_yaml(lang, script, i18nyaml = nil)
        y = if i18nyaml then YAML.load_file(i18nyaml)
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
