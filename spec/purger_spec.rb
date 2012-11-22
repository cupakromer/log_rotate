require 'spec_helper'

class KeepAllFiles
  def filter(file_names)
    file_names
  end
end

class DeleteAllFiles
  def filter(file_names)
    []
  end
end

class KeepSpecificFile
  def initialize(file_to_keep)
    @filename = file_to_keep
  end

  def filter(file_names)
    Array @filename
  end
end

describe Purger, fakefs: true do
  class TestPurger < Purger
    def set_policy_manager
      policy_manager
    end

    def last_purged=(file_names)
      super file_names
    end
  end

  let(:policy_manager) { GenericPolicyManager.new }
  subject(:purger) { Purger.new policy_manager }

  it { should_not respond_to :add_whitelist_policies }
  it { should respond_to :purge }
  it { should respond_to :last_purged_directory }
  it { should respond_to :last_purged }

  describe '#new' do
    it 'requires a policy manager' do
      expect{ Purger.new }.to raise_error ArgumentError
    end

    it 'will accept a single policy' do
      policy_manager = mock GenericPolicyManager
      TestPurger.new(policy_manager)
                .set_policy_manager
                .should be policy_manager
    end
  end

  describe '#last_purged' do
    it 'is empty if #purge is never called' do
      purger.last_purged.should be_empty
    end

    it 'is empty if no files were deleted when purge was called' do
      FileUtils.mkdir 'adirectory'
      purger = TestPurger.new KeepAllFiles.new
      purger.last_purged = ['a file']
      purger.last_purged.should_not be_empty

      purger.purge 'adirectory'

      purger.last_purged.should be_empty
    end

    it 'contains the names of files that were deleted when purge was called' do
      FileUtils.mkdir 'adirectory'
      FileUtils.touch 'adirectory/file1.log'
      FileUtils.touch 'adirectory/file2.log'
      purger = TestPurger.new DeleteAllFiles.new

      purger.purge 'adirectory'

      purger.last_purged.should match_array ['adirectory/file1.log',
                                             'adirectory/file2.log']
    end
  end

  describe '#last_purged_directory' do
    it 'returns `nil` before first purge' do
      purger.last_purged_directory.should be_nil
    end

    it 'returns the full path of the last directory passed to `#purge`' do
      FileUtils.mkdir_p '/tmp/test/adirectory'
      FileUtils.mkdir_p '/tmp/test/bdirectory'
      purger.purge('adirectory', '/tmp/test')

      purger.purge('bdirectory', '/tmp/test')
            .last_purged_directory
            .should eq '/tmp/test/bdirectory'
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

    context 'given only a directory' do
      let(:policy_manager) { DeleteAllFiles.new }

      before do
        FileUtils.mkdir 'adirectory'
        FileUtils.mkdir_p '/tmp/test/adirectory'
        FileUtils.touch 'adirectory/file1.log'
        FileUtils.touch '/tmp/test/adirectory/file1.log'
        File.file?('adirectory/file1.log').should be_true
        File.file?('/tmp/test/adirectory/file1.log').should be_true

        purger.purge 'adirectory'
      end

      it 'deletes relative to the current directory' do
        File.exist?('adirectory/file1.log').should be_false
      end

      it 'does not delete other directory files' do
        File.exist?('/tmp/test/adirectory/file1.log').should be_true
      end
    end

    context 'given a directory and a basepath' do
      let(:policy_manager) { DeleteAllFiles.new }

      before do
        FileUtils.mkdir 'adirectory'
        FileUtils.mkdir_p '/tmp/test/adirectory'
        FileUtils.touch 'adirectory/file1.log'
        FileUtils.touch '/tmp/test/adirectory/file1.log'
        File.file?('adirectory/file1.log').should be_true
        File.file?('/tmp/test/adirectory/file1.log').should be_true

        purger.purge 'adirectory', '/tmp/test'
      end

      it 'deletes relative to the basepath directory' do
        File.exist?('/tmp/test/adirectory/file1.log').should be_false
      end

      it 'does not delete other directory files' do
        File.exist?('adirectory/file1.log').should be_true
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
        purger = TestPurger.new KeepAllFiles.new

        purger.purge 'adirectory'

        File.exist?('adirectory/file1.log').should be_true
        File.exist?('adirectory/file2.log').should be_true
      end

      it 'example: delete all files' do
        purger = TestPurger.new DeleteAllFiles.new

        purger.purge 'adirectory'

        File.exist?('adirectory/file1.log').should be_false
        File.exist?('adirectory/file2.log').should be_false
      end

      it 'example: delete one file' do
        purger = TestPurger.new KeepSpecificFile.new 'adirectory/file2.log'

        purger.purge 'adirectory'

        File.exist?('adirectory/file1.log').should be_false
        File.exist?('adirectory/file2.log').should be_true
      end
    end

    it 'when multiple rules provided, it deletes files that match all rules' do
      FileUtils.mkdir 'adirectory'
      6.times{|index| FileUtils.touch "adirectory/file#{index}.log" }
      6.times{|index| File.file?("adirectory/file#{index}.log").should be_true}

      purger = TestPurger.new GenericPolicyManager.new [
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
