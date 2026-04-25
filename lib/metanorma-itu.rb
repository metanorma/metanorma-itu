require "metanorma/itu"
require "asciidoctor"
require "isodoc/itu"
require "metanorma-core"

if defined? Metanorma::Registry
  Metanorma::Registry.instance.register(Metanorma::Itu::Processor)
end
