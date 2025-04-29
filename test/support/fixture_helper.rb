require "json"
require "fileutils"

module FixtureHelper
  def self.load_or_build(name = :run, **runner_opts, &block)
    path = fixture_path(name)

    return cached_fixture(path) if File.exist?(path) && !ENV["REGEN_FIXTURES"]

    if block_given?
      data = Tachymeter::Runner.new(**runner_opts).start(&block)
    else
      scenario = Scenario.new
      data = Tachymeter::Runner.new(**runner_opts).start { scenario.run }
    end

    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.pretty_generate(data.map(&:to_h)))

    data
  end

  def self.fixture_path(name)
    File.expand_path("../fixtures/#{name.to_s}.json", __dir__)
  end

  def self.cached_fixture(path)
    JSON.parse(File.read(path), symbolize_names: true)
      .map { |h| Tachymeter::ResultSet.from_h(h) }
  end
end
