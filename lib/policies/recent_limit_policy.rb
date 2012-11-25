# Expectations:
#   * Names in the format:
#
#       ignored_path/yyyy-mm-dd-rest_of_name_ignored
#
#   * At most one name per date
#
# Filters the most recent names that have dates on the first of months.
require 'date'

class RecentLimitPolicy
  attr_reader :limit

  def initialize(limit)
    raise ArgumentError.new('limit must be greater than 0') if limit < 1

    self.limit = limit
  end

  def filter(file_names)
    valid_file_names(Array(file_names)).uniq.sort.last(limit)
  end

  private

  attr_writer :limit

  def valid_file_names(file_names)
    raise NoMethodError.new 'Subclass must implement this method'
  end

  def date(name)
    Date.strptime(date_part(name), '%Y-%m-%d')
  end

  def date_part(name)
    File.basename(name)[0,10]
  end
end
