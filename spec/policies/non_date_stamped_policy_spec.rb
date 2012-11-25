require 'spec_helper'

describe NonDateStampedPolicy do

  subject(:policy) { NonDateStampedPolicy.new }

  describe '#filter' do
    it 'given `nil` it returns []' do
      policy.filter(nil).should eq []
    end

    it 'given `[]` it returns []' do
      policy.filter([]).should eq []
    end

    it 'given an unsorted array of file names it returns those that do not ' \
       'start with "####-##-##-"' do
      file_names = [
        'filename1',
        'filename2',
        '2012-12-20-test.log',
        'adirectory/filename2',
        'adirectory/2012-12-20-test.log',
        '2020-20-20-bad-date.log',
      ]

      policy.filter(file_names).should match_array [
        'filename1',
        'filename2',
        'adirectory/filename2',
      ]
    end
  end

end
