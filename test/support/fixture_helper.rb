# frozen_string_literal: true

require "json"
require "fileutils"
require "tachymeter"

module FixtureHelper
  def runs(name = :run, **runner_opts, &block)
    fixture_dir = File.expand_path("../fixtures/runs", __dir__)
    fixture_file = File.join(fixture_dir, "#{name}.json")
    reuse_fixtures = !ENV["REGEN_FIXTURE"] && File.exist?(fixture_file)

    if reuse_fixtures
      return JSON.parse(File.read(fixture_file), symbolize_names: true)
        .map { |h| Tachymeter::Result.from_h(h) }
    end

    temp_db_path = Tachymeter.application.setup_default_db
    Tachymeter.application.create_db
    Tachymeter.application.load_schema
    Tachymeter.application.seed

    data = if block_given?
             Tachymeter::Runner.new(**runner_opts).start(&block)
           else
             scenario = Tachymeter::Scenario.new
             Tachymeter::Runner.new(**runner_opts).start { scenario.run }
           end

    FileUtils.mkdir_p(fixture_dir)
    File.write(fixture_file, JSON.pretty_generate(data.map(&:to_h)))
    File.delete(temp_db_path) if temp_db_path && File.exist?(temp_db_path)

    data
  end
end
