module Jekyll
  class ImgurEmbed < Liquid::Tag
    def initialize(tagName, content, tokens)
      super
      @content = content
      @show_info = true
      @title = ''
      @url = ''
    end

    # Method to convert string to bool (which is dumb ruby doesn't have this in the first place)
    # https://stackoverflow.com/a/36229316
    def true?(obj)
      obj.to_s.downcase == "true"
    end

    # Assign instance variables their values from parsed args
    # If key is invalid, it's ignored
    def assign_key_value(key, value)
      if key == 'show_info'
        @show_info = true?(value)
      elsif key == 'title'
        @title = value
      end
    end

    # Go through plugin request, parse args, and assign values
    def parse_args(context)
      split = @content.split
      @url = context[split[0]]
      if context[split[0]] != nil
        @url = context[split[0]]
      elsif split[0] != nil
        @url = split[0]
      else
        raise "No url given!"
      end
      i = 1
      endnum = split.length
      while i < endnum
        key_value = split[i].split(':')
        if key_value.length == 2
          key = key_value[0]
          value = context[key_value[1]]
          assign_key_value(key, value)
        end
        i = i + 1
      end
    end

    def render(context)
      parse_args(context)
      is_album = false
      id = nil
      # use regexes from https://codereview.stackexchange.com/q/204316
      gallery_regex = @url.scan(/(\/gallery\/)(\w+)/)
      album_regex = @url.scan(/(\/a\/)(\w+)/)
      image_regex = @url.scan(/\/(\w+)/)
      direct_link_regex = @url.scan(/(\w+)(\.\w+)/)
      if gallery_regex and gallery_regex.length != 0
        #puts "gallery"
        is_album = true
        id = gallery_regex[0][1]
      elsif album_regex and album_regex.length != 0
        #puts "album"
        is_album = true
        id = gallery_regex[0][1]
      elsif direct_link_regex and direct_link_regex.length != 0
        #puts "direct"
        is_album = false
        id = image_regex[1][0]
      elsif image_regex and image_regex.length != 0
        #puts "image"
        is_album = false
        id = image_regex[1]
      else
        raise 'Unable to parse imgur link'
      end
      <<-HTML.gsub /^\s+/, '' # remove whitespaces from heredocs
      <blockquote class="imgur-embed-pub" lang="en" data-id="#{if is_album then 'a/' end}#{id}" data-context="#{@show_info}">
      <a href="//imgur.com/#{if is_album then 'a/' end}#{id}">#{@title}</a></blockquote>
      <script async src="//s.imgur.com/min/embed.js" charset="utf-8"></script>
      HTML
    end

    Liquid::Template.register_tag('imgur', Jekyll::ImgurEmbed)
  end
end