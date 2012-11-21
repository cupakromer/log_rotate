require 'spec_helper'

describe Purger do
  it '#new requires a directory' do
    expect{ Purger.new }.to raise_error
  end
end
