require 'fakefs/spec_helpers'
require 'purger'
require 'generic_policy_manager'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
end
