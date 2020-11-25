require 'download'

class JaAddressDetector::Download
  attr_accessor :url, :path

  def initialize(url, path)
    @url  = url
    @path = path
  end

  def uri_file_name
    @uri_file_name ||= URI.parse(url).path.to_s.split('/').last
  end

  def file_path
    File.directory?(path) ? File.join(path, uri_file_name) : path
  end

  def remove
    FileUtils.remove_file file_path if File.exist? file_path
  end

  def downloaded?
    File.exist? file_path
  end

  def download
    FileUtils.mkdir_p(File.dirname(file_path))
    Download.file(url, file_path)
  end
end
