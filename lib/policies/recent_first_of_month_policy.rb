# Expectations:
#   * Names in the format:
#
#       ignored_path/yyyy-mm-dd-rest_of_name_ignored
#
#   * At most one name per date
#
# Filters the most recent names that have dates on the first of months.
require_relative 'recent_limit_policy'

class RecentFirstOfMonthPolicy < RecentLimitPolicy
  alias_method :months, :limit

  def initialize(months = 3) super end

  private

  def valid_file_names(file_names)
    file_names.select{ |name| date(name).day == 1 rescue false }
  end
end
