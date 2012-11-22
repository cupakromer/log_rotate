require 'spec_helper'

class MatchAllRule
end

class DenyAllRule
end

describe Purger, fakefs: true do
  class TestPurger < Purger
    def added_keep_rules
      keep_rules
    end
  end

  subject(:purger) { TestPurger.new 'adirectory' }

  it '#new requires a directory' do
    expect{ Purger.new }.to raise_error ArgumentError
  end

  describe '#add_keep_rules' do
    it 'requires one or more rules' do
      expect{ purger.add_keep_rules }.to raise_error ArgumentError
    end

    it 'given one rule it is added to the rules keep set' do
      purger.add_keep_rules MatchAllRule

      purger.added_keep_rules.should match_array [MatchAllRule]
    end

    it 'given several rules they are all added to the rules to keep set' do
      purger.add_keep_rules [MatchAllRule, DenyAllRule]

      purger.added_keep_rules.should match_array [MatchAllRule, DenyAllRule]
    end
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

    context 'one rule provided' do
      it 'deletes files that match the rule' do
        FileUtils.mkdir 'adirectory'
        FileUtils.touch 'adirectory/file1.log'
        File.file?('adirectory/file1.log').should be_true
        purger.add_keep_rules MatchAllRule

        purger.purge

        File.exist?('adirectory/file1.log').should be_false
      end
    end
  end
end
