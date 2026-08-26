# frozen_string_literal: true

# ITU Temporary Document (contribution) identifiers render as
# "ITU-<bureau> <series>-C<number>" (e.g. "ITU-R SG17-C1000").
#
# The pubid monogem's ITU flavor does not model TD contributions yet
# (pubid-itu 1.15 had Identifier::Contribution with exactly this
# rendering). Flavor-local subclass carrying the typed rendering until
# the monogem gains the contribution type upstream; delete when it does.
module Pubid
  module Itu
    module Identifiers
      class Contribution < Pubid::Itu::Identifier
        def render_base(**_opts)
          "#{publisher}-#{sector} #{series}-C#{code.number}"
        end
      end
    end
  end
end
