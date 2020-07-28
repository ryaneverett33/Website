class ImageSlider < Liquid::Tag
  def initialize(tagName, content, tokens)
    super
  end

  # Go through plugin request, parse args, and assign values
  def parse_args(context)
    split = @content.split
  end

  def render(context)
    parse_args(context)
  end

  Liquid::Template.register_tag "image-slider", self
end
