require 'eml2html/converter'

RSpec.describe Eml2Html::Converter do
  around(:each) do |example|
    Dir.mktmpdir do |dir|
      FileUtils.cd(dir) do
        example.run
      end
    end
  end

  let(:subject) { Eml2Html::Converter.new fixture_path('test.eml') }

  context "save_txt" do
    it "creates file" do
      subject.save_txt
      expect(File).to exist('test.txt')
    end
  end

  context "save_html" do
    before { subject.save_html }

    it { expect(File).to exist('test.html') }
    it { expect(File).to exist('image.png') }
    it { expect(FileUtils).to satisfy { |f| f.identical?('image.png', fixture_path('image.png')) } }
  end

  context "save_zip" do
    it "creates files" do
      subject.save_zip
      expect(File).to exist('test.zip')
    end
  end
end
