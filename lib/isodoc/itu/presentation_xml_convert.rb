require_relative "init"
require "isodoc"

module IsoDoc
  module ITU
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def initialize(options)
        @hierarchical_assets = options[:hierarchical_assets]
        super
      end

      def prefix_container(container, linkend, _target)
        l10n("#{linkend} #{@labels["in"]} #{@xrefs.anchor(container, :xref)}")
      end

      def eref(docxml)
        docxml.xpath(ns("//eref")).each do |f|
          eref1(f)
        end
      end

      def origin(docxml)
        docxml.xpath(ns("//origin[not(termref)]")).each do |f|
          eref1(f)
        end
      end

      def quotesource(docxml)
        docxml.xpath(ns("//quote/source")).each do |f|
          eref1(f)
        end
      end

      def eref1(f)
        get_eref_linkend(f)
      end

      def get_eref_linkend(node)
        contents = non_locality_elems(node).select { |c| !c.text? || /\S/.match(c) }
        return unless contents.empty?
        link = anchor_linkend(node, docid_l10n(node["target"] || node["citeas"]))
        link && !/^\[.*\]$/.match(link) and link = "[#{link}]"
        link += eref_localities(node.xpath(ns("./locality | ./localityStack")), link)
        non_locality_elems(node).each { |n| n.remove }
        node.add_child(link)
      end

      include Init
    end
  end
end

