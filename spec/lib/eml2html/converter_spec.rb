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
  let(:other_subject) { Eml2Html::Converter.new fixture_path('other_format.eml') }

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

  context "other_eml_file" do
    it "doesn't crash" do
      body = other_subject.html_body
      expect(body).to_not be(nil)
    end

    it "loads gets attachment independently" do
      a = other_subject.attachment('image009.png')
      expect(a).to_not be(nil)  
      expect(a.length).to be > 0
    end

    context "attachments" do
      it "loads_an_array_of_other_attachments" do
        attachments = other_subject.attachments(true)
        expect(attachments.length).to be(1)
      end

      it "doesn't load attachments that are pics in the body" do
        attachments = other_subject.attachments
        expect(attachments.length).to be(0)
      end
    end
  end
end
