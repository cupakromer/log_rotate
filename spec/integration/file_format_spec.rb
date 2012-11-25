require 'spec_helper'

describe 'Scrappy Academy retention policy',
         'using file format "yyyy-mm-dd-name.ext' do

  context 'valid command line arguments provided' do
    let(:file_names) {
      %w[
        adirectory/2010-04-19-dashboard.sql.gz
        adirectory/2011-05-13-dashboard.sql.gz
        adirectory/2012-09-01-dashboard.sql.gz
        adirectory/2012-10-01-dashboard.sql.gz
        adirectory/2012-10-13-dashboard.sql.gz
        adirectory/2012-10-14-dashboard.sql.gz
        adirectory/2012-10-21-dashboard.sql.gz
        adirectory/2012-10-28-dashboard.sql.gz
        adirectory/2012-10-30-dashboard.sql.gz
        adirectory/2012-10-31-dashboard.sql.gz
        adirectory/2012-11-01-dashboard.sql.gz
        adirectory/2012-11-02-dashboard.sql.gz
        adirectory/2012-11-03-dashboard.sql.gz
        adirectory/2012-11-04-dashboard.sql.gz
        adirectory/2012-11-05-dashboard.sql.gz
        adirectory/2012-11-06-dashboard.sql.gz
        adirectory/2012-11-07-dashboard.sql.gz
        adirectory/2012-11-08-dashboard.sql.gz
        adirectory/2012-11-09-dashboard.sql.gz
        adirectory/2012-11-10-dashboard.sql.gz
        adirectory/2012-11-11-dashboard.sql.gz
        adirectory/2012-11-12-dashboard.sql.gz
        adirectory/2012-11-13-dashboard.sql.gz
        adirectory/2012-11-14-dashboard.sql.gz
        adirectory/2012-11-15-dashboard.sql.gz
        adirectory/2012-11-16-dashboard.sql.gz
        adirectory/2012-11-17-dashboard.sql.gz
        adirectory/2012-11-18-dashboard.sql.gz
        adirectory/2012-11-19-dashboard.sql.gz
        adirectory/innodb-dashboard.sql.gz
      ]
    }

    subject(:state) {
      file_names.each_with_object({}) { |name, new_state|
        new_state[name] = File.exist? name
      }
    }

    before do
      @pre_condition = !File.directory?('adirectory')
      @pre_condition.should be_true

      FileUtils.mkdir_p 'adirectory'
      file_names.each{ |name| FileUtils.touch name }

      @output = `bin/purge_logs adirectory`
    end

    after do
      FileUtils.rm_rf 'adirectory' if @pre_condition
    end

    it 'retains the 7 most recent daily logs' do
      expected_state = {
        "adirectory/2012-11-13-dashboard.sql.gz" => true,
        "adirectory/2012-11-14-dashboard.sql.gz" => true,
        "adirectory/2012-11-15-dashboard.sql.gz" => true,
        "adirectory/2012-11-16-dashboard.sql.gz" => true,
        "adirectory/2012-11-17-dashboard.sql.gz" => true,
        "adirectory/2012-11-18-dashboard.sql.gz" => true,
        "adirectory/2012-11-19-dashboard.sql.gz" => true,
      }

      state.select{|k,v| expected_state.include? k}.should eq expected_state
    end

    it 'retains the 4 most recent Sundays logs' do
      expected_state = {
        "adirectory/2012-10-28-dashboard.sql.gz" => true,
        "adirectory/2012-11-04-dashboard.sql.gz" => true,
        "adirectory/2012-11-11-dashboard.sql.gz" => true,
        "adirectory/2012-11-18-dashboard.sql.gz" => true,
      }

      state.select{|k,v| expected_state.include? k}.should eq expected_state
    end

    it 'reatins the 3 most recent first of month logs' do
      expected_state = {
        "adirectory/2012-09-01-dashboard.sql.gz" => true,
        "adirectory/2012-10-01-dashboard.sql.gz" => true,
        "adirectory/2012-11-01-dashboard.sql.gz" => true,
      }

      state.select{|k,v| expected_state.include? k}.should eq expected_state
    end

    it 'retains any files that do not have a date in the name' do
      expected_state = {
        "adirectory/innodb-dashboard.sql.gz" => true,
      }

      state.select{|k,v| expected_state.include? k}.should eq expected_state
    end

    it 'it deletes all other files' do
      expected_state = {
        "adirectory/2010-04-19-dashboard.sql.gz" => false,
        "adirectory/2011-05-13-dashboard.sql.gz" => false,
        "adirectory/2012-10-13-dashboard.sql.gz" => false,
        "adirectory/2012-10-14-dashboard.sql.gz" => false,
        "adirectory/2012-10-21-dashboard.sql.gz" => false,
        "adirectory/2012-10-30-dashboard.sql.gz" => false,
        "adirectory/2012-10-31-dashboard.sql.gz" => false,
        "adirectory/2012-11-02-dashboard.sql.gz" => false,
        "adirectory/2012-11-03-dashboard.sql.gz" => false,
        "adirectory/2012-11-05-dashboard.sql.gz" => false,
        "adirectory/2012-11-06-dashboard.sql.gz" => false,
        "adirectory/2012-11-07-dashboard.sql.gz" => false,
        "adirectory/2012-11-08-dashboard.sql.gz" => false,
        "adirectory/2012-11-09-dashboard.sql.gz" => false,
        "adirectory/2012-11-10-dashboard.sql.gz" => false,
        "adirectory/2012-11-12-dashboard.sql.gz" => false,
      }

      state.select{|k,v| expected_state.include? k}.should eq expected_state
    end

    it 'outputs the number of files deleted as "# logs purged"' do
      @output.should eq "16 logs purged\n"
    end
  end

  context 'given no command line arguments' do
    before { File.directory?('this_should_never_exist').should be_false }

    it 'states "Must provide a valid directory"' do
      `bin/purge_logs adirectory`.should =~ /^Must provide a valid directory.$/
    end

    it 'displays the usage terms' do
      usage_directions = %r(Usage:\n  purge_logs DIRECTORY\n)

      `bin/purge_logs adirectory`.should =~ usage_directions
    end
  end

end
