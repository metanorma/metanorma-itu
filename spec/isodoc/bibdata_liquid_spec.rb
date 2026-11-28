require "spec_helper"

# metanorma-itu#885: the title page and Word header templates read plain
# copies of bibdata values through the bibdata.* Liquid object (isodoc#784),
# not through the flat metadata keys. The flat keys stay in the metadata for
# user templates.
RSpec.describe "bibdata.* Liquid paths in ITU templates" do
  # flat keys whose template uses are replaced by bibdata.* paths
  let(:flat_keys) do
    %i(docnumeric edition meeting meeting_place intended_type source)
  end

  def itu_xml(doctype, stage)
    <<~INPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata type="standard">
      <title language="en" format="text/plain" type="main">Main Title</title>
      <docidentifier type="ITU">ITU-T A.1234</docidentifier>
      <docnumber>1234</docnumber>
      <contributor><role type="author"><description>committee</description></role>
      <organization><name>International Telecommunication Union</name>
      <subdivision type="Bureau"><name>T</name></subdivision>
      <subdivision type="Group"><name>SG 17</name></subdivision>
      </organization></contributor>
      <edition>7</edition>
      <language>en</language><script>Latn</script>
      <status><stage>#{stage}</stage></status>
      <ext><doctype>#{doctype}</doctype><flavor>itu</flavor>
      <meeting acronym="MX">Meeting X</meeting>
      <meeting-place>Geneva</meeting-place>
      <meeting-date><from>2000-01-01</from><to>2000-01-02</to></meeting-date>
      <intended-type>TD</intended-type><source>Source X</source>
      <studyperiod><start>2021</start><end>2024</end></studyperiod>
      <structuredidentifier><bureau>T</bureau><docnumber>1234</docnumber>
      </structuredidentifier>
      </ext></bibdata>
      <metanorma-extension><semantic-metadata>
      <stage-published>#{stage == 'draft' ? 'false' : 'true'}</stage-published>
      </semantic-metadata></metanorma-extension>
      <sections/></itu-standard>
    INPUT
  end

  # the HTML and Word converters read presentation XML, where i18n has added
  # language variants of doctype and edition
  def converter(klass, doctype, stage = "draft")
    pres = IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", itu_xml(doctype, stage), true)
    c = klass.new({})
    c.convert_init(pres, "test", false)
    c.info(Nokogiri::XML(pres), nil)
    c
  end

  def template_path(template)
    File.join(File.dirname(__FILE__), "..", "..", "lib", "isodoc", "itu",
              "html", template)
  end

  def render(conv, template, drop: [])
    drop.each { |k| conv.meta.set(k, nil) }
    conv.populate_template(File.read(template_path(template)), :word)
  end

  # the Word header is rendered through generate_header, not
  # populate_template
  def render_header(conv, drop: [])
    drop.each { |k| conv.meta.set(k, nil) }
    conv.instance_variable_set(:@header, template_path("header.html"))
    f = conv.generate_header("test", nil)
    File.read(f.path, encoding: "UTF-8")
  end

  {
    "html_itu_titlepage.html" =>
      { klass: IsoDoc::Itu::HtmlConvert,
        cases: { "technical-report" =>
                   ["Meeting X, 01 Jan 2000/02 Jan 2000", "<td>TD</td>",
                    "<td colspan=\"7\">Source X</td>", "MEETING X",
                    "Geneva, 01 Jan 2000/02 Jan 2000", "Revision 7",
                    "Technical Report 1234", 'id="draft-band"',
                    %(<span class="doc-identifier">1234</span>)] } },
    "word_itu_titlepage.html" =>
      { klass: IsoDoc::Itu::WordConvert,
        cases: { "technical-report" =>
                   ["Meeting X, 01 Jan 2000/02 Jan 2000", "TD", "Source X",
                    "MEETING X", "Geneva, 01 Jan 2000/02 Jan 2000", "1234"],
                 "resolution" => ["Resolution 1234 &#x2013;"] } },
    "word_itu_titlepage_sp.html" =>
      { klass: IsoDoc::Itu::WordConvert,
        cases: { "service-publication" => ["1234"] } },
  }.each do |template, spec|
    spec[:cases].each do |doctype, fragments|
      it "renders the #{doctype} #{template} from bibdata.* paths" do
        full = render(converter(spec[:klass], doctype), template)
        dropped = render(converter(spec[:klass], doctype), template,
                         drop: flat_keys)
        fragments.each { |f| expect(dropped).to include(f) }
        expect(dropped).to eq full
      end
    end
  end

  it "renders the resolution Word header from bibdata.* paths" do
    full = render_header(converter(IsoDoc::Itu::WordConvert, "resolution"))
    dropped = render_header(converter(IsoDoc::Itu::WordConvert, "resolution"),
                            drop: flat_keys)
    expect(dropped).to include("MX &#x2013; Resolution 1234")
    expect(dropped).to eq full
  end

  it "takes the HTML stage band from bibdata.status.stage" do
    c = converter(IsoDoc::Itu::HtmlConvert, "recommendation", "in-force")
    expect(c.meta.get[:stage]).to eq "In Force"
    c.meta.set(:stage, "Something Else")
    out = render(c, "html_itu_titlepage.html")
    expect(out).to include('id="in-force-band"')
  end

  it "keeps the flat keys in the metadata" do
    meta = converter(IsoDoc::Itu::HtmlConvert, "technical-report").meta.get
    expect(meta.slice(*flat_keys))
      .to eq(docnumeric: "1234", edition: "7", meeting: "Meeting X",
             meeting_place: "Geneva", intended_type: "TD", source: "Source X")
  end
end
