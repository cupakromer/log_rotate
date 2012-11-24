# Expectations:
#   * Names in the format:
#
#       ignored_path/yyyy-mm-dd-rest_of_name_ignored
#
#   * At most one name per date
#
# Filters the most recent names provided.
require 'date'

class RecentDaysPolicy
  attr_reader :days

  def initialize(days=7)
    raise ArgumentError.new("days must be greater than 0") if days < 1

    self.days = days
  end

  def filter(file_names)
    valid_file_names(Array(file_names)).uniq.sort.last(days)
  end

  private

  attr_writer :days

  def valid_file_names(file_names)
    file_names.select{ |name|
      Date.strptime(date_part(name), '%Y-%m-%d') rescue false
    }
  end

  def date_part(name)
    File.basename(name)[0,10]
  end
end
