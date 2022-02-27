require "rspec/core"
require "rspec/matchers"
require "rspec/expectations"
require "spy"
require "pry"
require "pry-nav"

RSpec::Matchers.define :include_method do |expected|
  match do |actual|
    actual.map { |m| m.to_s }.include?(expected.to_s)
  end
end

RSpec.configure do |config|
  config.color_enabled = true
  config.order = :random
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run_including :focus
  config.filter_run_excluding :broken => true
  config.mock_with :absolutely_nothing

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  old_verbose = nil
  config.before(:each, :silence_warnings) do
    old_verbose = $VERBOSE
    $VERBOSE = nil
  end

  config.after(:each, :silence_warnings) do
    $VERBOSE = old_verbose
  end

  config.after(:each) do
    Spy.teardown
  end
end

