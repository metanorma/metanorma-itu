module Metanorma
  module Itu
    class Converter < Standoc::Converter
      def default_publisher
        @i18n.get["ITU"] || @i18n.international_telecommunication_union
      end

      def org_abbrev
        if @i18n.get["ITU"]
          { @i18n.international_telecommunication_union => @i18n.get["ITU"] }
        else {} end
      end

      def committee_contributors(node, xml, agency, opt)
        metadata_committee_prep(node) or return
        super
      end

      def metadata_committee_types(_node)
        %w(bureau sector group subgroup workgroup)
      end

      def extract_org_attrs_complex(node, opts, source, suffix)
        super.merge(ident: node.attr("#{source}-acronym#{suffix}")).compact
      end

      def full_committee_id(contrib); end

      def metadata_committee_prep(node)
        a = node.attributes.dup
        a.each do |k, v|
          /group(type|acronym)/.match?(k) and
            node.set_attr(k.sub(/group(type|acronym)/, "group-\\1"), v)
          /group(yearstart|yearend)/.match?(k) and
            node.set_attr(k.sub(/groupyear(start|end)/, "group-year-\\1"), v)
        end
      end

      def org_attrs_add_committees(node, ret, opts, opts_orig)
        opts_orig[:groups]&.each_with_index do |g, i|
          i.zero? and next
          contributors_committees_pad_multiples(ret.first, node, g)
          opts = committee_contrib_org_prep(node, g, nil, opts_orig)
          ret << org_attrs_parse_core(node, opts).map do |x|
            x.merge(subdivtype: opts[:subdivtype])
          end
        end
        contributors_committees_nest1(ret)
      end

      def metadata_ext(node, xml)
        super
        metadata_question(node, xml)
        metadata_recommendationstatus(node, xml)
        metadata_ip_notice(node, xml)
        metadata_studyperiod(node, xml)
        metadata_techreport(node, xml)
        metadata_contribution(node, xml)
      end
    end
  end
end
