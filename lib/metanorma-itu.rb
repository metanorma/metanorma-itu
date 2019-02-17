require "metanorma/itu"
require "asciidoctor"
require "asciidoctor/itu"
require "isodoc/itu"

if defined? Metanorma
  Metanorma::Registry.instance.register(Metanorma::ITU::Processor)
end
