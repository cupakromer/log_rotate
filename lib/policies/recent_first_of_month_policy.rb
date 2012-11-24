# Expectations:
#   * Names in the format:
#
#       ignored_path/yyyy-mm-dd-rest_of_name_ignored
#
#   * At most one name per date
#
# Filters the most recent names that have dates on the first of months.
class RecentFirstOfMonthPolicy
  attr_reader :months

  def initialize(months = 3)
    raise ArgumentError.new('months must be greater than 0') if months < 1

    self.months = months
  end

  def filter(file_names)
    valid_first_of_month_file_names(Array(file_names)).uniq.sort.last(months)
  end

  private

  attr_writer :months

  def valid_first_of_month_file_names(file_names)
    file_names.select{ |name|
      Date.strptime(date_part(name), '%Y-%m-%d').day == 1 rescue false
    }
  end

  def date_part(name)
    File.basename(name)[0,10]
  end
end
