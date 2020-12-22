module Jekyll
  class ImageCompare < Liquid::Tag
    def initialize(tagName, content, tokens)
      super
      @content = content
      @imgA = nil
      @imgB = nil
      @name = nil
      @before_label = "Before"
      @after_label = "After"
      @orientation = "horizontal"
      @default_offset_pct = "0.5"
      @no_overlay = true
      @move_slider_on_hover = true
      @move_with_handle_only = true
      @click_to_move = false
    end

    # Go through plugin request, parse args, and assign values
    def parse_args(context)
      split = @content.split
      if split.length < 3
        raise "Invalid arguments"
      end
      @imgA = Helpers.resolve_context(context, split, 0)
      @imgB = Helpers.resolve_context(context, split, 1)
      @name = Helpers.resolve_context(context, split, 2)

      i = 3
      endnum = split.length
      did_set_no_overlay = false
      while i < endnum
        key_value = split[i].split(":")
        tmp = context[key_value[1]]
        if tmp == nil
          tmp = key_value[1]
        end
        case key_value[0]
        when "before_label"
          @before_label = tmp
        when "after_label"
          @after_label = tmp
        when "orientation"
          @orientation = tmp
        when "default_offset_pct"
          @default_offset_pct = tmp
        when "no_overlay"
          @no_overlay = Helpers.parse_bool(tmp)
          did_set_no_overlay = true
        when "move_slider_on_hover"
          @move_slider_on_hover = Helpers.parse_bool(tmp)
        when "move_with_handle_only"
          @move_with_handle_only = Helpers.parse_bool(tmp)
        when "click_to_move"
          @click_to_move = Helpers.parse_bool(tmp)
        end
        # Override no_overlay if users supplies labels
        if !did_set_no_overlay
          if @before_label != "Before" || @after_label != "After"
            @no_overlay = false
          end
        end
        i = i + 1
      end
    end

    def render(context)
      parse_args(context)
      str = <<-js.gsub /^\s+/, "" # remove whitespaces from heredocs
        <script type="text/javascript">
            (function(){
                $(window).on('load', function() {
                    $("\##{@name}-container").twentytwenty({
                        default_offset_pct: #{@default_offset_pct},
                        orientation: '#{@orientation}',
                        before_label: '#{@before_label}',
                        after_label: '#{@after_label}',
                        no_overlay: #{@no_overlay},
                        move_slider_on_hover: #{@move_slider_on_hover},
                        move_with_handle_only: #{@move_with_handle_only},
                        click_to_move: #{@click_to_move}
                    });
                });
            })()
        </script>
      js

      str += <<-HTML.gsub /^\s+/, "" # remove whitespaces from heredocs
      <div id="#{@name}-container">
      
        <img src="#{@imgA}" />
        <img src="#{@imgB}" />
      </div>
      HTML
      str
    end

    Liquid::Template.register_tag("compare", Jekyll::ImageCompare)
  end
end
