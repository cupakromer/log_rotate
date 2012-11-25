# Expectations:
#   * Names in the format:
#
#       ignored_path/yyyy-mm-dd-rest_of_name_ignored
#
#   * At most one name per date
#
# Filters the most recent names provided.
require 'helpers'
require_relative 'recent_limit_policy'

class RecentDaysPolicy < RecentLimitPolicy
  alias_method :days, :limit

  def initialize(days = 7) super end

  private

  include DateStamped

  def valid_file_names(file_names)
    file_names.select{ |name| date(name) rescue false }
  end
end
