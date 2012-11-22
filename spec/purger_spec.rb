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

class KeepSpecificFile
  def initialize(file_to_keep)
    @filename = file_to_keep
  end

  def matches(file_names)
    Array @filename
  end
end

class DeleteFirstFile
  def matches(file_names)
    Array file_names[1..-1]
  end
end

describe Purger, fakefs: true do
  class TestPurger < Purger
    def added_whitelist_policies
      whitelist_policies
    end

    def last_purged=(file_names)
      super file_names
    end
  end

  subject(:purger) { TestPurger.new }

  describe '#new' do
    it 'uses an empty the whitelist policy set by default' do
      TestPurger.new.added_whitelist_policies.should be_empty
    end

    it 'will accept a single policy' do
      TestPurger.new(policy = KeepAllFiles.new)
                .added_whitelist_policies
                .should match_array [policy]
    end

    it 'will accept multiple policies' do
      TestPurger.new(policies = [KeepAllFiles.new, DeleteFirstFile.new])
                .added_whitelist_policies
                .should match_array policies
    end
  end

  describe '#add_whitelist_policies' do
    it 'requires one or more rules' do
      expect{ purger.add_whitelist_policies }.to raise_error ArgumentError
    end

    it 'given one rule it is added to the rules keep set' do
      purger.add_whitelist_policies(policy = KeepAllFiles.new)

      purger.added_whitelist_policies.should match_array Array policy
    end

    it 'given several rules they are all added to the rules to keep set' do
      policies = [KeepAllFiles.new, DeleteFirstFile.new]
      purger.add_whitelist_policies policies

      purger.added_whitelist_policies.should match_array policies
    end
  end

  describe '#last_purged' do
    it 'is empty if #purge is never called' do
      purger.last_purged.should be_empty
    end

    it 'is empty if no files were deleted when purge was called' do
      FileUtils.mkdir 'adirectory'
      purger.add_whitelist_policies KeepAllFiles.new
      purger.last_purged = ['a file']
      purger.last_purged.should_not be_empty

      purger.purge 'adirectory'

      purger.last_purged.should be_empty
    end

    it 'contains the names of files that were deleted when purge was called' do
      FileUtils.mkdir 'adirectory'
      FileUtils.touch 'adirectory/file1.log'
      FileUtils.touch 'adirectory/file2.log'
      purger.add_whitelist_policies DeleteAllFiles.new

      purger.purge 'adirectory'

      purger.last_purged.should match_array ['adirectory/file1.log',
                                             'adirectory/file2.log']
    end
  end

  describe '#purge' do
    it 'returns self' do
      purger.purge('adirectory').should be purger
    end

    context 'when no rules provided' do
      it '#last_purged should be empty' do
        purger.purge('adirectory').last_purged.should be_empty
      end
    end

    context 'when one rule provided it deletes files that match the rule' do
      before do
        FileUtils.mkdir 'adirectory'
        FileUtils.touch 'adirectory/file1.log'
        FileUtils.touch 'adirectory/file2.log'
        File.file?('adirectory/file1.log').should be_true
        File.file?('adirectory/file2.log').should be_true
      end

      it 'example: delete nothing' do
        purger.add_whitelist_policies KeepAllFiles.new

        purger.purge 'adirectory'

        File.exist?('adirectory/file1.log').should be_true
        File.exist?('adirectory/file2.log').should be_true
      end

      it 'example: delete all files' do
        purger.add_whitelist_policies DeleteAllFiles.new

        purger.purge 'adirectory'

        File.exist?('adirectory/file1.log').should be_false
        File.exist?('adirectory/file2.log').should be_false
      end

      it 'example: delete one file' do
        purger.add_whitelist_policies KeepSpecificFile.new 'adirectory/file2.log'

        purger.purge 'adirectory'

        File.exist?('adirectory/file1.log').should be_false
        File.exist?('adirectory/file2.log').should be_true
      end
    end

    it 'when multiple rules provided, it deletes files that match all rules' do
      FileUtils.mkdir 'adirectory'
      6.times{|index| FileUtils.touch "adirectory/file#{index}.log" }
      6.times{|index| File.file?("adirectory/file#{index}.log").should be_true}

      purger.add_whitelist_policies [
        KeepSpecificFile.new('adirectory/file0.log'),
        KeepSpecificFile.new('adirectory/file2.log'),
        KeepSpecificFile.new('adirectory/file5.log'),
      ]

      purger.purge 'adirectory'

      File.exist?('adirectory/file0.log').should be_true
      File.exist?('adirectory/file1.log').should be_false
      File.exist?('adirectory/file2.log').should be_true
      File.exist?('adirectory/file3.log').should be_false
      File.exist?('adirectory/file4.log').should be_false
      File.exist?('adirectory/file5.log').should be_true
    end
  end
end
