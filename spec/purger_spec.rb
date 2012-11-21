require 'spec_helper'

describe Purger do
  subject(:purger) { Purger.new 'adirectory' }

  it '#new requires a directory' do
    expect{ Purger.new }.to raise_error
  end

  describe '#purge' do
    it 'returns self' do
      purger.purge.should be purger
    end

    context 'no rules provided' do
      it '#last_purged should be empty' do
        purger.purge.last_purged.should be_empty
      end
    end
  end
end
