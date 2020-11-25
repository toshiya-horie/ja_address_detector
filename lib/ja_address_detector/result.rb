require 'json'

class JaAddressDetector::Result

  attr_reader :path, :detected_pos

  def initialize(path, detected_pos)
    @path         = path
    @detected_pos = detected_pos
  end

  def detected_level
    path.count
  end

  def name(delim = '')
    path.join(delim)
  end

  def content
    JSON.parse(JaAddressDetector::AddressTree.from_path(path).content)
  end

  def to_s
    name
  end
end
