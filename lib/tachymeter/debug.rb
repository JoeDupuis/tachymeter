# frozen_string_literal: true

module Tachymeter
  module Debug
    attr_reader :response

    def save_and_open_page(body, path = html_dump_default_path)
      save_page(body, path).tap { |s_path| open_file(s_path) }
    end

    private
    def save_page(body, path = html_dump_default_path)
      path = Pathname.new(path)
      path.dirname.mkpath
      File.write(path, body)
      path
    end

    def open_file(path)
      require "launchy"
      Launchy.open(path)
    rescue LoadError
      warn "File saved to #{path}.\nPlease install the launchy gem to open the file automatically."
    end

    def html_dump_default_path
      File.join("/tmp/html_dump", "#{DateTime.current.to_i}.html").to_s
    end
  end
end
