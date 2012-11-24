require 'spec_helper'

describe RecentFirstOfMonthPolicy do

  subject(:policy) { RecentFirstOfMonthPolicy.new }

  describe '#new' do
    it 'sets the default months to 3' do
      policy.months.should eq 3
    end

    it 'allows the number of months to be set' do
      RecentFirstOfMonthPolicy.new(5).months.should eq 5
    end

    it 'raises an argument error if months is zero' do
      expect{ RecentFirstOfMonthPolicy.new(0) }.to raise_error ArgumentError
    end

    it 'raises an argument error if months is negative' do
      expect{ RecentFirstOfMonthPolicy.new(-2) }.to raise_error ArgumentError
    end
  end

  it { should_not respond_to :months= }

  describe '#months' do
    it 'returns the number of months set when created' do
      RecentFirstOfMonthPolicy.new(5).months.should eq 5
    end
  end

  describe '#filter' do
    context 'with valid file names' do
      it 'given `nil` it returns []' do
        policy.filter(nil).should eq []
      end

      it 'given `[]` it returns []' do
        policy.filter([]).should eq []
      end

      it 'given one first of month file name is returned in an array' do
        policy.filter('2012-11-01-db.log').should eq ['2012-11-01-db.log']
      end

      it 'given an array with less, first of month, file names than the ' \
         'number of months set, all names are returned' do
        file_names = [
          '2012-11-01-db.log',
          '2012-10-01-db.log',
          '2012-09-01-db.log',
        ]

        policy.filter(file_names).should match_array file_names
      end

      context 'given an unsorted array with more, first of month, file ' \
              'names than the number of days set, ' do
        let(:file_names) {
          [
            '2011-01-01-db.log',
            '2012-11-01-db.log',
            '2011-05-01-db.log',
            '2012-10-01-db.log',
            '2010-01-01-db.log',
          ]
        }

        it 'the count of the returned array equals the number of days' do
          RecentFirstOfMonthPolicy.new(3).filter(file_names).count.should eq 3
        end

        it 'only the files with the most recent first of month are selected' do
          RecentFirstOfMonthPolicy.new(3).filter(file_names)
            .should match_array [
              '2011-05-01-db.log',
              '2012-10-01-db.log',
              '2012-11-01-db.log',
            ]
        end
      end
    end

    context 'with invalid file names' do
      it 'ignores non-first of month dated file names' do
        file_names = [
          '2011-01-20-db.log',
          'adirectory/2012-10-01-db.log',
          '2012-01-22-db.log',
          '2012-11-01-db.lgo',
        ]

        policy.filter(file_names).should match_array [
          'adirectory/2012-10-01-db.log',
          '2012-11-01-db.lgo',
        ]
      end

      it 'ignores malformed file names' do
        file_names =  [
          '2011-01-01-db.log',
          '-01-01-db.log',
          'adirectory/2012-11-01-db.log',
          'sldakn#41j!@$10j',
          '2012-01-22-db.log',
          'adirectory/2012-11-01-db.log/stuff',
        ]

        policy.filter(file_names).should match_array [
          '2011-01-01-db.log',
          'adirectory/2012-11-01-db.log',
        ]
      end

      it 'ignore duplicate names' do
        file_names = ['2011-01-01-db.log','2011-01-01-db.log']

        policy.filter(file_names).should eq ['2011-01-01-db.log']
      end
    end
  end

end
