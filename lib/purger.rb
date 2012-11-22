class Purger
  attr_reader :directory, :last_purged

  def initialize(directory)
    @keep_rules = []
    @last_purged = []
    @directory = File.expand_path directory
  end

  def purge
    memo_to_delete = files_to_delete

    File.delete *memo_to_delete unless memo_to_delete.empty?

    self.last_purged = memo_to_delete

    self
  end

  def add_keep_rules(rules)
    keep_rules.concat Array(rules)
    self
  end

  private

  attr_accessor :keep_rules
  attr_writer :last_purged

  def files_to_delete
    all_files = Dir["#{directory}/*"]
    files_to_keep = keep_rules.each_with_object([]){ |rule, files_to_keep|
      files_to_keep.concat rule.new.matches all_files
    }

    all_files - files_to_keep
  end
end
