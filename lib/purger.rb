class Purger
  def initialize(directory)
    @keep_rules = []
  end

  def purge
    self
  end

  def last_purged
    []
  end

  def add_keep_rules(rules)
    keep_rules.concat Array(rules)
    self
  end

  private

  attr_accessor :keep_rules
end
