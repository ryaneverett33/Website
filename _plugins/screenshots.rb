require "uri"

module Jekyll
  class ScreenshotsEmbed < Liquid::Tag
    def initialize(tagName, content, tokens)
      super
      @content = content
    end

    def ordinalize(i)
      case i % 10
      when 1
        return "#{i}st"
      when 2
        return "#{i}nd"
      when 3
        return "#{i}rd"
      else
        return "#{i}th"
      end
    end

    # Go through plugin request, parse args, and assign values
    def parse_args(context)
      split = @content.split
      if split.length != 2
        raise "Invalid arguments"
      end
      @screenshots_arr = context[split[0]]
      @project_name = context[split[1]]
    end

    def render(context)
      parse_args(context)
      if @screenshots_arr == "nil"
        return
      end
      str = ""
      i = 0
      # assemble main carousel
      str += <<-HTML
        <div id="#{@project_name.gsub " ", ""}Indicators" class="carousel slide" data-ride="carousel">
          <ol class="carousel-indicators">
        HTML
      while i < @screenshots_arr.length
        str += <<-HTML
            <li data-target="##{@project_name.gsub " ", ""}Indicators" data-slide-to="#{i}" #{if i == 0 then 'class="active"' end}></li>
          HTML
        i += 1
      end
      str += <<-HTML
        </ol>
        <div class="carousel-inner">
        HTML
      i = 0
      for screenshot in @screenshots_arr
        str += <<-HTML
              <div class='carousel-item #{i == 0 ? "active" : ""}'>
              HTML
        if screenshot["external"]
          str += <<-HTML
                    <img class="d-block w-100" src="#{screenshot["img"]}" alt="#{ordinalize(i).capitalize} slide">
                  HTML
        else
          url = "/assets/projects/#{@project_name}/screenshots/#{screenshot["img"]}"
          str += <<-HTML
                    <img class="d-block w-100" src="#{URI::encode(url)}" alt="#{ordinalize(i).capitalize} slide">
                  HTML
        end
        if screenshot["title"]
          str += <<-HTML
                  <div class="carousel caption d-none d-md-block text-center">
                    <h5>#{screenshot["title"]}</h5>
                  </div>
                  HTML
        end
        str += "</div>"
        i += 1
      end
      str += <<-HTML
        </div>
        <a class="carousel-control-prev" href="##{@project_name.gsub " ", ""}Indicators" role="button" data-slide="prev">
          <span class="carousel-control-prev-icon" aria-hidden="true"></span>
          <span class="sr-only">Previous</span>
        </a>
        <a class="carousel-control-next" href="##{@project_name.gsub " ", ""}Indicators" role="button" data-slide="next">
          <span class="carousel-control-next-icon" aria-hidden="true"></span>
          <span class="sr-only">Next</span>
        </a>
        </div>
        HTML
      str.gsub /^\s+/, "" # remove whitespaces from heredocs
      str
    end

    Liquid::Template.register_tag("screenshots", Jekyll::ScreenshotsEmbed)
  end
end
