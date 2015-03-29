module FileHelper
  def fixture_path(file)
    File.join(File.dirname(__FILE__), 'fixtures', file)
  end
end
