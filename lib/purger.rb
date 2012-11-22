class Purger
  attr_reader :last_purged_directory, :last_purged

  def initialize(policy_manager)
    self.policy_manager = policy_manager
    self.last_purged = []
  end

  def purge(directory, basepath=nil)
    self.last_purged_directory = File.expand_path directory, basepath
    memo_to_delete = files_to_delete

    File.delete *memo_to_delete unless memo_to_delete.empty?

    self.last_purged = memo_to_delete

    self
  end

  private

  attr_accessor :policy_manager
  attr_writer :last_purged, :last_purged_directory

  def files_to_delete
    all_files = Dir["#{last_purged_directory}/*"]

    all_files - policy_manager.filter(all_files)
  end
end
