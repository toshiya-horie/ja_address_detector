class JaAddressDetector::Core

  DETECT_DEPTH = [
      :root,
      :prefecture,
      :city,
      :block
  ]

  # @option [String] allow_whitespace 空白を許容して抽出する
  # @option [String] start_depth      都道府県、市区町村、街区、どのレベルから探索を開始するか
  def initialize(allow_whitespace: true, start_depth: :prefecture)
    @allow_whitespace = allow_whitespace
    @start_depth      = DETECT_DEPTH.index(start_depth)
  end

  # 文中に含まれる地名を最大で街区レベルまで抽出する
  #
  # @param [String]
  # @param [Array<Tree::NodeTree>]
  # @param [Integer]
  # @param [Integer]
  # @return [Array<JaAddressDetector::Result>]
  def detect(text, address_nodes = JaAddressDetector::AddressTree.from_depth(@start_depth), seek_pos = 0, seek_length = -1)
    result_array = address_nodes.map do |address_node|
      detected_pos_array = match(text, address_node, seek_pos, seek_length)
      detected_pos_array.map do |detected_pos|
        JaAddressDetector::Result.new(address_node.path_as_array.slice(1..-1), detected_pos)
      end
    end.compact.flatten

    result_array.map.with_index do |result, idx|
      current_node = JaAddressDetector::AddressTree.from_path(result.path)
      next result if current_node.is_leaf?
      next_result_array = detect(
        text,
        current_node.children,
        result.detected_pos.last,
        result_array[idx+1]&.detected_pos&.first || -1
      )
      next_result_array.empty? ? result : next_result_array
    end.flatten
  end

  private

  # 入力文字列に地名が含まれる場合, マッチした開始位置と終了位置を返却する
  #
  # @param [String]
  # @param [Node::NodeTree]
  # @param [Integer]
  # @param [Integer]
  # @return [Array<Range>]
  def match(text, node, seek_pos, seek_length)
    regexp = Regexp.new([
                            "(#{seek_pos.zero? ? '.*' : '^'})",
                            "(#{@allow_whitespace ? '[[:blank:]]*' : ''})",
                            "(#{node.name})",
                        ].join)

    text.slice(seek_pos..seek_length).enum_for(:match, regexp).map do |m|
      first_pos = seek_pos + m[1].length + m[2].length
      last_pos  = first_pos + m[3].length
      Range.new(first_pos, last_pos)
    end
  end
end
