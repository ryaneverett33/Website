module Jekyll
    class TechLinksEmbed < Liquid::Tag
      def initialize(tagName, content, tokens)
        super
        @content = content
        @raw_names = nil
        @technologies = {
          "angular" => 'https://angular.io/',
          "electron" => 'https://www.electronjs.org/',
          "jquery" => 'https://jquery.com/',
          "bison" => 'https://www.gnu.org/software/bison/',
          "flex" => 'https://github.com/westes/flex/',
          "mssql" => 'https://www.microsoft.com/en-us/sql-server/',
          "mariadb" => 'https://mariadb.org',
          "apache" => 'https://httpd.apache.org/',
          "nginx" => 'https://www.nginx.com/',
          "aws" => 'https://aws.amazon.com/',
          "azure" => 'https://azure.microsoft.com/',
          "chatterbot" => 'https://chatterbot.readthedocs.io/en/stable/',
          "bootstrap" => 'https://getbootstrap.com/',
          "material-design" => 'https://material.io/design/',
          "firebase" => 'https://firebase.google.com/',
          "socket.io" => 'https://socket.io/',
          "node.js" => "https://nodejs.org/",
          "unity3d" => 'https://unity.com/',
          "paramiko" => 'http://www.paramiko.org/',
          "beautifulsoup4" => 'https://www.crummy.com/software/BeautifulSoup/',
          "asp.net" => 'https://dotnet.microsoft.com/apps/aspnet',
          "raspberry pi" => 'https://www.raspberrypi.org/',
          "flask" => 'https://flask.palletsprojects.com/',
          "ffmpeg" => 'https://www.ffmpeg.org/',
          "express" => 'https://expressjs.com/',
          "mysql" => 'https://www.mysql.com/',
          "android" => 'https://www.android.com'
        }
      end
  
      def get_link(name)
        tech = @technologies[name]
        if tech == nil
          return "#"
        end
        return tech
      end

      # Go through plugin request, parse args, and assign values
      def parse_args(context)
        split = @content.split
        if split.length != 1
            raise 'Invalid arguments'
        end
        @raw_names = context[split[0]]
      end
  
      def render(context)
        parse_args(context)
        str = ''
        counter = 0
        for raw_name in @raw_names
            link = get_link(raw_name.downcase)
            str = str + <<-HTML
              <a href="#{link}" target="blank">#{raw_name}</a>#{counter == @raw_names.length - 1 ? '' : ', '}
              HTML
            counter+= 1
        end
        str.gsub /^\s+/, '' # remove whitespaces from heredocs
        str
      end
  
      Liquid::Template.register_tag('tech_links', Jekyll::TechLinksEmbed)
    end
  end