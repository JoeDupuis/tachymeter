# frozen_string_literal: true

require "json"
require "fileutils"
require "tachymeter"

module FixtureHelper
  def runs(name = :run, **runner_opts, &block)
    fixture_dir = File.expand_path("../fixtures/runs", __dir__)
    fixture_file = File.join(fixture_dir, "#{name}.json")

    if File.exist?(fixture_file) && !ENV["REGEN_FIXTURE"]
      return JSON.parse(File.read(fixture_file), symbolize_names: true)
                 .map { |h| Tachymeter::ResultSet.from_h(h) }
    end

    data = if block_given?
      Tachymeter::Runner.new(**runner_opts).start(&block)
    else
      scenario = Tachymeter::Scenario.new
      Tachymeter::Runner.new(**runner_opts).start { scenario.run }
    end

    FileUtils.mkdir_p(fixture_dir)
    File.write(fixture_file, JSON.pretty_generate(data.map(&:to_h)))

    data
  end
end
