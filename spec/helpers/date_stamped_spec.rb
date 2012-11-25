require 'spec_helper'

module Specs
  class TestDateStamped
    include DateStamped
  end
end

describe DateStamped do

  subject(:instance) { Specs::TestDateStamped.new }

  context 'when included in a class' do
    it { should respond_to :date }
    it { should respond_to :date_part }
  end

  describe '#date' do
    it 'returns a date object if the given name starts with a date in the ' \
       'format of YYYY-MM-DD that is zero padded' do
      instance.date('adirectory/2012-11-20-otherstuff.ext')
              .should eq Date.new(2012, 11, 20)
    end

    it 'raises ArgumentError otherwise' do
      expect{ instance.date('adirectory/2012-14-33-otherstuff.ext') }
        .to raise_error ArgumentError
    end
  end

  describe '#date_part' do
    it 'returns the first 10 characters of the given file name' do
      instance.date_part('adirectory/2012-11-20-otherstuff.ext')
              .should eq '2012-11-20'
    end
  end

end
