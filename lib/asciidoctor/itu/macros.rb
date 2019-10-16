require "asciidoctor/extensions"

class PseudocodeBlockMacro < Asciidoctor::Extensions::BlockProcessor
  use_dsl
  named :pseudocode
  on_context :example, :sourcecode

  def init_indent(s)
    /^(?<prefix>[ \t]*)(?<suffix>.*)$/ =~ s
    prefix = prefix.gsub(/\t/, "\u00a0\u00a0\u00a0\u00a0").gsub(/ /, "\u00a0")
    prefix + suffix
  end

  def process parent, reader, attrs
    attrs['role'] = 'pseudocode'
    create_block parent, :example, reader.lines.map { |m| init_indent(m) }, attrs,
      content_model: :compound
  end
end
