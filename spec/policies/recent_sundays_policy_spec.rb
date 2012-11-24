require 'spec_helper'

describe RecentSundaysPolicy do

  subject(:policy) { RecentSundaysPolicy.new }

  describe '#new' do
    it 'sets the default number of Sundays to 4' do
      policy.sundays.should eq 4
    end

    it 'allows the number of Sundays to be set' do
      RecentSundaysPolicy.new(5).sundays.should eq 5
    end

    it 'raises an argument error if months is zero' do
      expect{ RecentSundaysPolicy.new(0) }.to raise_error ArgumentError
    end

    it 'raises an argument error if months is negative' do
      expect{ RecentSundaysPolicy.new(-2) }.to raise_error ArgumentError
    end
  end

  it { should_not respond_to :sundays= }

  describe '#sundays' do
    it 'returns the number of Sundays set when created' do
      RecentSundaysPolicy.new(5).sundays.should eq 5
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

      it 'given one file name with a Sunday date it is returned in an array' do
        policy.filter('2012-11-11-db.log').should eq ['2012-11-11-db.log']
      end

      it 'given an array with less, Sunday dated, file names than the number ' \
         'of months set, all names are returned' do
        file_names = [
          '2012-11-04-db.log',
          '2012-11-11-db.log',
          '2012-11-18-db.log',
        ]

        policy.filter(file_names).should match_array file_names
      end

      context 'given an unsorted array with more, Sunday dated, file ' \
              'names than the number of days set, ' do
        let(:file_names) {
          [
            '2011-12-25-db.log',
            '2011-08-21-db.log',
            '2012-11-11-db.log',
            '2010-01-24-db.log',
            '2012-11-18-db.log',
          ]
        }

        it 'the count of the returned array equals the number of days' do
          RecentSundaysPolicy.new(3).filter(file_names).count.should eq 3
        end

        it 'only the files with the most recent dates are selected' do
          RecentSundaysPolicy.new(3).filter(file_names)
            .should match_array [
              '2011-12-25-db.log',
              '2012-11-11-db.log',
              '2012-11-18-db.log',
            ]
        end
      end
    end

    context 'with invalid file names' do
      it 'ignores non-Sunday dates' do
        file_names =  [
          '2011-01-20-db.log',
          'adirectory/2012-11-11-db.log',
          'adirectory/2012-11-21-db.log',
          '2012-01-23-db.log',
          '2012-11-18-db.log',
        ]

        policy.filter(file_names).should match_array [
          '2012-11-18-db.log',
          'adirectory/2012-11-11-db.log',
        ]
      end

      it 'ignores malformed file names' do
        file_names =  [
          '2012-11-18-db.log',
          '-01-23-db.log',
          'adirectory/2012-11-11-db.log',
          'sldakn#41j!@$10j',
          '2012-01-22-db.log',
          'adirectory/2012-11-21-db.log/stuff',
        ]

        policy.filter(file_names).should match_array [
          '2012-11-18-db.log',
          'adirectory/2012-11-11-db.log',
          '2012-01-22-db.log',
        ]
      end

      it 'ignore duplicate names' do
        file_names = ['2012-01-22-db.log','2012-01-22-db.log']

        policy.filter(file_names).should eq ['2012-01-22-db.log']
      end
    end
  end

end
