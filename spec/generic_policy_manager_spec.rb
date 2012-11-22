require 'spec_helper'

module Specs
  class TestPolicyManager < GenericPolicyManager
    def policy_count
      whitelist_policies.count
    end
  end
end

describe GenericPolicyManager do

  def new_keep_files_policy(files_to_keep)
    stub('KeepSpecificPolicy', filter: Array(files_to_keep))
  end

  subject(:policy_manager) { Specs::TestPolicyManager.new }

  it { should respond_to :filter }

  describe '#new' do
    it 'allows no policies to be set' do
      policy_manager.policy_count.should eq 0
    end

    it 'allows one policy to be set' do
      policy_manager = Specs::TestPolicyManager.new mock('Policy')

      policy_manager.policy_count.should eq 1
    end

    it 'allows multiple policies to be set' do
      policy_manager = Specs::TestPolicyManager.new [
        mock('Policy'),
        mock('Policy'),
        mock('Policy'),
      ]

      policy_manager.policy_count.should eq 3
    end
  end

  describe '#filter' do
    let(:file_names) { ['file1', 'file2', 'file3'] }

    it 'should require file names to filter on' do
      expect{ policy_manager.filter }.to raise_error ArgumentError
    end

    it 'returns an empty list when no policies are set' do
      policy_manager.filter(['a file', 'another file']).should be_empty
    end

    it 'calls filter on all whitelist policies' do
      policies = [mock('Policy'), mock('Policy'), mock('Policy')]
      policies.each{ |policy| policy.should_receive(:filter).with(file_names) }

      policy_manager = GenericPolicyManager.new policies

      policy_manager.filter file_names
    end

    it 'returns the union of file names returned by all policies' do
      policies = file_names.map{|file_name| new_keep_files_policy file_name }

      policy_manager = GenericPolicyManager.new policies

      policy_manager.filter(file_names)
                    .should match_array file_names
    end

    it 'the union list of file names does not contain duplicates' do
      file_names = ['file1', 'file2', 'file1']

      policies = file_names.map{|file_name| new_keep_files_policy file_name }

      policy_manager = GenericPolicyManager.new policies

      policy_manager.filter(file_names)
                    .should match_array ['file1', 'file2']
    end
  end
end
