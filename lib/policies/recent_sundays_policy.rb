# Expectations:
#   * Names in the format:
#
#       ignored_path/yyyy-mm-dd-rest_of_name_ignored
#
#   * At most one name per date
#
# Filters the most recent names that have dates on a Sunday.
require 'date'

class RecentSundaysPolicy
  attr_reader :sundays

  def initialize(sundays = 4)
    raise ArgumentError.new('number of Sundays must be great than 0') if sundays < 1

    self.sundays = sundays
  end

  def filter(file_names)
    valid_sunday_file_names(Array(file_names)).uniq.sort.last(sundays)
  end

  private

  attr_writer :sundays

  def valid_sunday_file_names(file_names)
    file_names.select{ |name|
      Date.strptime(date_part(name), '%Y-%m-%d').sunday? rescue false
    }
  end

  def date_part(name)
    File.basename(name)[0,10]
  end
end
