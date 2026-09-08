# frozen_string_literal: true

# Self-contained: avoids pulling in the gem's full spec_helper (which
# may load unrelated code with pre-existing pubid-* dependency issues).
require "bundler/setup"
require "metanorma/itu/document"
require "metanorma/itu/html"
require "metanorma/html/generator"

# The renderer registration contract: the ITU root and the standoc
# sections it uses must dispatch — an unregistered root renders an
# empty shell (reader chrome with no document body).
RSpec.describe "Metanorma::Itu::Html::Renderer" do
  let(:fixture) do
    Dir[File.expand_path("fixtures/itu/**/*presentation*.xml", __dir__)].first
  end

  it "renders the ITU root to a document body, not an empty shell" do
    skip "no presentation fixture" unless fixture

    model = Metanorma::Itu::Document::Root.from_xml(
      File.read(fixture, encoding: "utf-8"),
    )
    html = Metanorma::Html::Generator.generate(model)
    page = Nokogiri::HTML(html)
    page.css("header, nav, .header-actions, button, kbd").remove

    paragraphs = page.css("p").size
    expect(paragraphs).to be > 5,
                          "document body rendered no content (root dispatch missing)"
    expect(page.at("body").text).to include("ITU-T")
  end

  it "is the renderer the flavor registry resolves" do
    require "metanorma-core"
    entry = Metanorma::Core::Flavors.find(:itu)
    renderer = entry.renderers[:html].call(nil)
    expect(renderer).to eq(Metanorma::Itu::Html::Renderer)
  end
end
