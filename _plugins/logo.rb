class LogoEmbed < Liquid::Tag
  def initialize(tagName, content, tokens)
    super
    @center = false
    @width = nil
    @height = nil
    @url = nil
    @alt = nil
    @content = content
  end

  # Go through plugin request, parse args, and assign values
  def parse_args(context)
    split = @content.split
    if split.length < 1
      raise "Invalid arguments"
    end
    @url = context[split[0]]
    if @url == nil
      @url = split[0]
    end
    i = 1
    endnum = split.length
    while i < endnum
      key_value_split = split[i].split(":")
      key = key_value_split[0]
      value = key_value_split[1]
      if key.casecmp? "width"
        @width = value
      elsif key.casecmp? "height"
        @height = value
      elsif key.casecmp? "center"
        if value.casecmp? "true"
          @center = true
        end
      elsif key.casecmp? "alt"
        @alt = value
      end
      i = i + 1
    end
  end

  def render(context)
    parse_args(context)
    if @url == nil
      return
    end
    if @width == nil
      @width = "auto"
    end
    if @height == nil
      @height = "auto"
    end
    if @alt == nil
      @alt = ""
    end
    str = <<-HTML
        <div class="#{if @center then "text-center" end}">
          <img src="#{@url}" width="#{@width}" height="#{@height}" alt="#{@alt}" />
        </div>
        HTML
    str.gsub /^\s+/, "" # remove whitespaces from heredocs
    str
  end

  Liquid::Template.register_tag "logo", self
end
