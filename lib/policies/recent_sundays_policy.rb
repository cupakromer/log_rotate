# Expectations:
#   * Names in the format:
#
#       ignored_path/yyyy-mm-dd-rest_of_name_ignored
#
#   * At most one name per date
#
# Filters the most recent names that have dates on a Sunday.
require_relative 'recent_limit_policy'

class RecentSundaysPolicy < RecentLimitPolicy
  alias_method :sundays, :limit

  def initialize(sundays = 4) super end

  private

  def valid_file_names(file_names)
    file_names.select{ |name| date(name).sunday? rescue false }
  end
end
