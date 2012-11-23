# Expectations:
#   * Names in the format:
#
#       ignored_path/yyyy-mm-dd-rest_of_name_ignored
#
#   * At most one name per date
#
# Filters the most recent names provided.
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
    file_names.select{|name| name =~ valid_file_name_format}
  end

  def valid_date_format
    "\\d{4}-\\d{2}-\\d{2}"
  end

  def valid_file_name_format
    @valid_format ||= /\A#{valid_prefix}#{valid_date_format}#{valid_postfix}\z/
  end

  def valid_prefix
    "(.*#{File::SEPARATOR})?"
  end

  def valid_postfix
    "-[^#{File::SEPARATOR}]*"
  end
end
