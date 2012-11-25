require 'spec_helper'

module Specs
  class TestRecentLimitPolicy < RecentLimitPolicy
    def valid_file_names(file_names)
      file_names
    end
  end
end

describe RecentLimitPolicy do

  subject(:policy) { RecentLimitPolicy.new(5) }

  describe '#new' do
    it 'raises ArgumentError if no limit is provided' do
      expect{ RecentLimitPolicy.new }.to raise_error ArgumentError
    end
  end

  it { should_not respond_to :limit= }

  describe '#limit' do
    it 'returns the number of limit set when created' do
      RecentLimitPolicy.new(3).limit.should eq 3
    end
  end

  describe '#filter' do
    it 'raises NoMethodError when `valid_file_names` is not implemented' do
      expect{ policy.filter([]) }.to raise_error NoMethodError
    end

    context 'method `valid_file_names` is implemented in subclass' do
      subject(:policy) { Specs::TestRecentLimitPolicy.new(3) }

      it 'given `nil` it returns []' do
        policy.filter(nil).should eq []
      end

      it 'given `[]` it returns []' do
        policy.filter([]).should eq []
      end

      it 'given one first of month file name is returned in an array' do
        policy.filter('filename').should eq ['filename']
      end

      it 'given an array with less valid file names than the limit set, ' \
         'all names are returned' do
        file_names = ['filename1', 'filename2', 'filename3']

        policy.filter(file_names).should match_array file_names
      end

      context 'given an unsorted array with more file names than the set limit' do
        let(:file_names) {
          [
            'filename4',
            'filename2',
            'filename1',
            'filename5',
            'filename3',
          ]
        }

        it 'the count of the returned array equals the limit' do
          policy.filter(file_names).count.should eq 3
        end

        it 'only the files with the most recent names are selected' do
          policy.filter(file_names)
            .should match_array [
              'filename3',
              'filename4',
              'filename5',
            ]
        end
      end
    end
  end

end
