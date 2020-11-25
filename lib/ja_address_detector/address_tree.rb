require 'tree'
require 'zip'
require 'csv'
require 'json'

class JaAddressDetector::AddressTree

  DUMP_FILE = File.join(__dir__, '../../data/address_tree.dump').freeze

  class << self

    # @return [Array<Tree::TreeNode>]
    def from_depth(level)
      nodes = [root]
      level.times do
        nodes = nodes.map(&:children).flatten
      end

      nodes
    end

    def from_path(path)
      node = root
      path.each do |segment|
        node = node[segment]
      end

      node
    end

    def build
      root_node    = Tree::TreeNode.new('ROOT')
      download_dir = File.join(__dir__, '../../downloaded/nlftp.mlit.go.jp').freeze
      FileUtils.mkdir_p(download_dir)
      Range.new(1, 47).map do |i|
        "https://nlftp.mlit.go.jp/isj/dls/data/13.0b/#{format('%02d', i)}000-13.0b.zip"
      end.map do |url|
        JaAddressDetector::Download.new(url, download_dir)
      end.map do |download|
        download.download unless download.downloaded?
        Zip::File.open(download.file_path) do |zip|
          zip.glob('**/*.csv').first.get_input_stream.read
        end
      end.each do |text|
        CSV.parse(text.encode(Encoding::UTF_8, Encoding::SJIS, udef: :replace), headers: true) do |row|
          pref_name  = row['都道府県名']
          city_name  = row['市区町村名']
          block_name = row['大字町丁目名']
          # @fixme Can't create relation each same name nodes.
          next if block_name == city_name

          root_node << Tree::TreeNode.new(pref_name, {
              code: row['都道府県コード'].to_i
          }.to_json) unless root_node[pref_name]
          root_node[pref_name] << Tree::TreeNode.new(city_name, {
              code: row['市区町村コード'].to_i
          }.to_json) unless root_node[pref_name][city_name]
          root_node[pref_name][city_name] << Tree::TreeNode.new(block_name, {
              code:      row['大字町丁目コード'].to_i,
              latitude:  row['緯度'].to_f,
              longitude: row['経度'].to_f
          }.to_json) unless root_node[pref_name][city_name][block_name]
        end
      end
      File.open(DUMP_FILE, 'wb') do |f|
        f.write(Marshal.dump(root_node))
      end
    end

    private

    # @return [Tree::TreeNode]
    def root
      @@root ||= Marshal.load(File.binread(DUMP_FILE))
    end
  end
end
