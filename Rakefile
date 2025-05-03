# frozen_string_literal: true

require "bundler/gem_tasks"
require "json"
require "fileutils"
require "pathname"

task :test do
  sh("bin/rails test")
end

namespace :template do
  desc "Preview the HTML template with sample data"
  task :preview do
      require "launchy"
      require_relative "test/support/fixture_helper"

      include FixtureHelper

      runs = runs("template_preview", full_run: true)

      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      random_suffix = rand(1000).to_s.rjust(3, '0')
      temp_file = File.join(Dir.tmpdir, "preview_#{timestamp}_#{random_suffix}.html")
      output_path = Tachymeter::HtmlExport.write(runs, temp_file)
      puts "Opening preview in your browser..."
      Launchy.open(output_path)
      puts "Preview opened at: #{output_path}"
  end
end
