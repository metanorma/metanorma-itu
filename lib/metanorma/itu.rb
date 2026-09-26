require "metanorma/itu/version"
require "metanorma/itu/document"
require "metanorma/itu/processor"
require "metanorma/itu/converter"
require "metanorma/itu/cleanup"
require "metanorma/itu/validate"

module Metanorma
  module Itu
    ORGANIZATION_NAME_SHORT = "ITU"
    ORGANIZATION_NAME_LONG = "International Telecommunication Union"
  end
end

# Registry styling: the flavor owns its index theme, registered
# programmatically with the metanorma-document theme system.
begin
  require "metanorma/html"
  Metanorma::Html::Theme.register_themes_dir(
    File.expand_path("itu/themes", __dir__),
  )
rescue LoadError
  # metanorma-document unavailable; registry styling inert
end
