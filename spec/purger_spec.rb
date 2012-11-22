require 'spec_helper'

class KeepAllFiles
  def matches(file_names)
    file_names
  end
end

class DeleteAllFiles
  def matches(file_names)
    []
  end
end

describe Purger, fakefs: true do
  class TestPurger < Purger
    def added_keep_rules
      keep_rules
    end

    def last_purged=(file_names)
      super file_names
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
      purger.add_keep_rules KeepAllFiles

      purger.added_keep_rules.should match_array [KeepAllFiles]
    end

    it 'given several rules they are all added to the rules to keep set' do
      purger.add_keep_rules [KeepAllFiles, DeleteAllFiles]

      purger.added_keep_rules.should match_array [KeepAllFiles, DeleteAllFiles]
    end
  end

  describe '#last_purged' do
    it 'is empty if #purge is never called' do
      purger.last_purged.should be_empty
    end

    it 'is empty if no files were deleted when purge was called' do
      FileUtils.mkdir 'adirectory'
      purger.add_keep_rules KeepAllFiles
      purger.last_purged = ['a file']
      purger.last_purged.should_not be_empty

      purger.purge

      purger.last_purged.should be_empty
    end

    it 'contains the names of files that were deleted when purge was called' do
      FileUtils.mkdir 'adirectory'
      FileUtils.touch 'adirectory/file1.log'
      FileUtils.touch 'adirectory/file2.log'
      purger.add_keep_rules DeleteAllFiles

      purger.purge

      purger.last_purged.should match_array ['adirectory/file1.log',
                                             'adirectory/file2.log']
    end
  end

  describe '#purge' do
    it 'returns self' do
      purger.purge.should be purger
    end

    context 'when no rules provided' do
      it '#last_purged should be empty' do
        purger.purge.last_purged.should be_empty
      end
    end

    it 'when one rule provided it deletes files that match the rule' do
      FileUtils.mkdir 'adirectory'
      FileUtils.touch 'adirectory/file1.log'
      FileUtils.touch 'adirectory/file2.log'
      File.file?('adirectory/file1.log').should be_true
      File.file?('adirectory/file2.log').should be_true
      purger.add_keep_rules DeleteAllFiles

      purger.purge

      File.exist?('adirectory/file1.log').should be_false
      File.exist?('adirectory/file2.log').should be_false
    end
  end
end
