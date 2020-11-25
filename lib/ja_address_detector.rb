require 'ja_address_detector/version'
require 'ja_address_detector/core'
require 'ja_address_detector/address_tree'
require 'ja_address_detector/result'
require 'ja_address_detector/download'

module JaAddressDetector
  class << self
    def detect(text, **options)
      Core.new(options).detect(text)
    end
  end
end
