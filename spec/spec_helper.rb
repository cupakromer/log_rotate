require 'fakefs/spec_helpers'
require 'purger'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
end
