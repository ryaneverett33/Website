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
      @screenshots_arr = Helpers.resolve_context(context, split, 0)
      @project_name = Helpers.resolve_context(context, split, 1)
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
        <div id="#{@project_name.gsub " ", ""}Indicators" class="carousel carousel-dark slide" style="padding-bottom: 15px;" data-bs-ride="carousel">
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
                    <img class="d-block w-100" src="#{url}" alt="#{ordinalize(i).capitalize} slide">
                  HTML
        end
        if screenshot["title"]
          str += <<-HTML
                  <div class="carousel-caption d-none d-md-block">
                    <h5>#{screenshot["title"]}</h5>
                  </div>
                  HTML
        end
        str += "</div>"
        i += 1
      end
      str += <<-HTML
        </div>
        <button class="carousel-control-prev" type="button" data-bs-target="##{@project_name.gsub " ", ""}Indicators" data-bs-slide="prev">
          <span class="btn-dark carousel-btn" aria-hidden="true">
            <i class="fas fa-chevron-left" style="padding-top: 12px"></i>
          </span>
          <span class="visually-hidden">Previous</span>
        </button>
        <button class="carousel-control-next" type="button" data-bs-target="##{@project_name.gsub " ", ""}Indicators" data-bs-slide="next">
          <span class="btn-dark carousel-btn" aria-hidden="true">
            <i class="fas fa-chevron-right" style="padding-top: 12px"></i>
          </span>
          <span class="visually-hidden">Next</span>
        </button>
        </div>
        HTML
      i = 0
      str += "<div class=\"carousel-indicators\" style=\"position: relative; height: 25px;\">"
      while i < @screenshots_arr.length
        str += <<-HTML
            <button type="button" data-bs-target="##{@project_name.gsub " ", ""}Indicators" data-bs-slide-to="#{i}" #{if i == 0 then 'class="active" aria-current="true"' end} aria-label="Slide #{i + 1}" style="background-color: #000;"></button>
          HTML
        i += 1
        end
        str += <<-HTML
          </div>
        HTML
      str.gsub /^\s+/, "" # remove whitespaces from heredocs
      str
    end

    Liquid::Template.register_tag("screenshots", Jekyll::ScreenshotsEmbed)
  end
end
