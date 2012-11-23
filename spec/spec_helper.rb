require 'fakefs/spec_helpers'
require 'purger'
require 'generic_policy_manager'
require 'policies'

# Include all support files
Dir['./spec/support/**/*.rb'].each {|f| require f}

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
end
