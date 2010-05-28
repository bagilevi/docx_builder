class SliceTemplate

  attr_reader :content
  attr_accessor :slices


  def initialize(filename)
    @content = File.read(filename)
    @slices = {}
    parse
  end

  def initialize_copy(other)
    @content = other.content.clone
    @slices = other.slices.clone
  end

  def [](slice_name)
    @slices[slice_name] = Slice.new(@slices[slice_name]) unless @slices[slice_name].instance_of?(Slice)
    @slices[slice_name]
  end

  def []=(slice_name, value)
    if value.instance_of?(Array)
      @slices[slice_name] = value.map do |item|
        item.instance_of?(Slice) ? item.render : item
      end
    else
      @slices[slice_name] = value
    end
  end

  def render
    render_string(@content)
  end

  alias_method :to_s, :render


  private


  def parse
    parse_string(@content)
  end

  def parse_string(s)
    s.gsub!(/<\!-- BEGIN ([^>]+) -->(.+)<\!-- END \1 -->/m).each do |match|
      slice_name, content = [$1.downcase, $2]
      parse_string(content)
      @slices[slice_name] = content
      "(#{slice_name})"
    end
  end

  def render_string(s)
    return if s.nil?
    s.gsub(/\(([\w\d _]+)\)/) do |match|
      slot_name = $1
      slice = @slices[slot_name]
      slice.nil? ? match : render_string(slice.to_s)
    end
  end


  class Slice
    attr_reader :slots

    def initialize(content)
      @content = content
      parse
    end

    def parse
      @slots = Hash[@content.scan(/\(([\w\d _]+)\)/).map{|slot_name| [slot_name, "(#{slot_name})"] }]
    end

    def [](slot_name)
      @slots[slot_name]
    end

    def []=(slot_name, value)
      @slots[slot_name] = value
    end

    def set(slot_name, value)
      @slots[slot_name] = value
      self
    end

    def render
      @content.gsub(/\(([\w\d _]+)\)/) do |match|
        slot_name = $1
        @slots[slot_name]
      end
    end

    alias_method :to_s, :render

    def initialize_copy(other)
      @slots = other.slots.clone
    end
  end

end