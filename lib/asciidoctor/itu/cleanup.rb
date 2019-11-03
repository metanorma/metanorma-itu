module Asciidoctor
  module ITU
    class Converter < Standoc::Converter
      def sections_cleanup(x)
        super
        x.xpath("//*[@inline-header]").each do |h|
          h.delete("inline-header")
        end
      end

      def cleanup(xmldoc)
        symbols_cleanup(xmldoc)
        super
      end

      def smartquotes_cleanup(xmldoc)
        return super if @smartquotes
        xmldoc.traverse do |n|
          next unless n.text?
          n.replace(n.text.gsub(/\u2019|\u2018|\u201a|\u201b/, "'").
                    gsub(/\u201c|\u201d|\u201e|\u201f/, '"'))
        end
        xmldoc
      end

      def termdef_cleanup(xmldoc)
        xmldoc.xpath("//term/preferred").each do |p|
          if ["terms defined elsewhere",
              "terms defined in this recommendation"].include? p.text.downcase
            p.name = "title"
            p.parent.name = "terms"
          end
        end
        super
      end

      def termdef_boilerplate_cleanup(xmldoc)
      end

      def symbols_cleanup(xmldoc)
        sym = xmldoc.at("//definitions/title")
        sym and sym&.next_element&.name == "dl" and
          sym.next = "<p>#{@symbols_boilerplate}</p>"
      end
    end
  end
end
