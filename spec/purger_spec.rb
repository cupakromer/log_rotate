require 'spec_helper'

module Specs
  class TestPurger < Purger
    def set_policy_manager
      policy_manager
    end

    def last_purged=(file_names)
      super file_names
    end
  end
end

describe Purger, fakefs: true do

  let(:delete_all_policy) { stub 'delete_all', filter: [] }
  let(:keep_all_policy) {
    stub('keep_all').tap{ |s| s.stub(:filter){|file_names| file_names} }
  }
  let(:policy_manager) { keep_all_policy }

  subject(:purger) { Purger.new policy_manager }

  it { should respond_to :purge }
  it { should respond_to :last_purged_directory }
  it { should respond_to :last_purged }

  describe '#new' do
    it 'requires a policy manager' do
      expect{ Purger.new }.to raise_error ArgumentError
    end

    it 'will accept a single policy manager' do
      policy_manager = mock 'PolicyManager'
      Specs::TestPurger.new(policy_manager)
                       .set_policy_manager
                       .should be policy_manager
    end

    it 'will not accept multiple policy managers' do
      expect{
        Purger.new(mock('PolicyManager'), mock('PolicyManager'))
      }.to raise_error ArgumentError
    end
  end

  describe '#last_purged' do
    let(:directory) { 'adirectory' }

    before do
      FileUtils.mkdir directory
      FileUtils.touch "#{directory}/file1.log"
      FileUtils.touch "#{directory}/file2.log"
    end

    it 'is empty if #purge is never called' do
      purger.last_purged.should be_empty
    end

    it 'is empty if no files were deleted when purge was called' do
      purger = Specs::TestPurger.new keep_all_policy
      purger.last_purged = ['a file']
      purger.last_purged.should_not be_empty

      purger.purge directory

      purger.last_purged.should be_empty
    end

    it 'contains the names of files that were deleted when purge was called' do
      purger = Purger.new delete_all_policy

      purger.purge directory

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

    context 'given only a directory' do
      let(:policy_manager) { delete_all_policy }

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
      let(:policy_manager) { delete_all_policy }

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

    context 'deletes files based on the policy manager' do
      let(:directory) { 'adirectory' }
      let(:file_names) {
        6.times.each_with_object([]){ |index, names|
          names << "#{directory}/file#{index}.log"
        }
      }

      before do
        FileUtils.mkdir directory
        file_names.each{ |name| FileUtils.touch name }
        file_names.each{ |name| File.exist?(name).should be_true }
      end

      it 'example: policy manager returns all files => nothing is deleted' do
        Purger.new(keep_all_policy).purge directory

        file_names.each{ |name| File.exist?(name).should be_true }
      end

      it 'example: policy manager returns no files => all are deleted' do
        Purger.new(delete_all_policy).purge directory

        file_names.each{ |name| File.exist?(name).should be_false }
      end

      it 'example: policy manager returns a subset of files => converse are deleted' do
        expect_kept = []
        expect_deleted = []
        file_names.each_with_index do |name, index|
          if index.odd?
            expect_kept << name
          else
            expect_deleted << name
          end
        end
        policy_manager = stub('keep_specific', filter: expect_kept)
        purger = Purger.new policy_manager

        purger.purge directory

        expect_kept.each{ |name| File.exist?(name).should be_true }
        expect_deleted.each{ |name| File.exist?(name).should be_false }
      end
    end
  end

end
