require 'acceptance_helper'
require 'capybara-screenshot'

RSpec.configure do |config|
  config.fail_fast = false
  config.include ScreenshotTest
end
Capybara::Screenshot.autosave_on_failure = false
