require "metanorma/itu"
require "asciidoctor"
require "isodoc/itu"
require "metanorma"

if defined? Metanorma::Registry
  Metanorma::Registry.instance.register(Metanorma::ITU::Processor)
end
