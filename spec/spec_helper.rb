require 'fakefs/spec_helpers'
require 'purger'
require 'generic_policy_manager'
require 'helpers'
require 'policies'

# Include all support files
Dir['./spec/support/**/*.rb'].each {|f| require f}

def precondition(&block)
  assert block.call, 'Pre-condition failed'
end

module Helpers
  module FileSystem
    def fs_create(directory, file_names = [])
      FileUtils.mkdir_p directory
      Array(file_names).each do |name|
        FileUtils.touch "#{directory}/#{name}"
      end
    end
  end
end

RSpec::Matchers.define :have_deleted do |file_names|
  def expected_result(file_names)
    Array(file_names).each_with_object({}){ |file_name, results|
      results[file_name] = false
    }
  end

  def actual_result(file_names)
    Array(file_names).each_with_object({}){ |file_name, results|
      results[file_name] = File.exists? file_name
    }
  end

  match do |action|
    Array(file_names).each do |file_name|
      precondition{ File.exists? file_name }
    end
    expected = expected_result file_names
    action.call
    actual = actual_result file_names
    actual.should eq expected
  end
end

RSpec::Matchers.define :have_kept do |file_names|
  def expected_result(file_names)
    Array(file_names).each_with_object({}){ |file_name, results|
      results[file_name] = true
    }
  end

  def actual_result(file_names)
    Array(file_names).each_with_object({}){ |file_name, results|
      results[file_name] = File.exists? file_name
    }
  end

  match do |action|
    Array(file_names).each do |file_name|
      precondition{ File.exists? file_name }
    end
    expected = expected_result file_names
    action.call
    actual = actual_result file_names
    actual.should eq expected
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.include Helpers::FileSystem
  config.include FakeFS::SpecHelpers, :fakefs
  config.expect_with :rspec, :stdlib
end
