# frozen_string_literal: true

require "metanorma/standoc"
# Forward-declare parent namespace so this file is safe to require
# directly (without first requiring metanorma/itu.rb).
module Metanorma
  module Itu
  end
end


module Metanorma
  module Itu::Document
    autoload :Metadata, "metanorma/itu/document/metadata"
    autoload :Root, "metanorma/itu/document/root"
  end
end

# Backwards-compat alias so external consumers that reference
# Metanorma::ItuDocument keep resolving during the transition.
module Metanorma
  existing = defined?(Metanorma::ItuDocument) && Metanorma::ItuDocument
  if !existing.equal?(Metanorma::Itu::Document)
    Metanorma.send(:remove_const, :ItuDocument) if existing
    ItuDocument = Metanorma::Itu::Document
  end
end

if defined?(Metanorma::Registers::Setup.setup_itu_register)
  Metanorma::Registers::Setup.setup_itu_register
end

module Metanorma
  deprecate_constant :ItuDocument
end

# OCP adoption: register the flavor with the metanorma-document harness.
# The html renderer resolves lazily (require at first render), keeping
# the load graph clean. Re-basing to the Standoc renderer or an own
# renderer later is a change to this registration only.
Metanorma.register_flavor(Metanorma::Flavor.new(
                            name: :itu,
                            model_class: Metanorma::Itu::Document::Root,
                            pubid_module: :"Pubid::Itu",
                            renderers: {
                              html: lambda do |_document, **_options|
                                require "metanorma/iso/html"
                                Metanorma::Iso::Html::Renderer
                              end,
                            },
                          ))
