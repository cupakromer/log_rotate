class Purger
  attr_reader :last_purged_directory, :last_purged

  def initialize(whitelist_policies=[])
    @whitelist_policies = Array(whitelist_policies)
    @last_purged = []
  end

  def purge(directory)
    self.last_purged_directory = File.expand_path directory
    memo_to_delete = files_to_delete

    File.delete *memo_to_delete unless memo_to_delete.empty?

    self.last_purged = memo_to_delete

    self
  end

  def add_whitelist_policies(whitelists)
    whitelist_policies.concat Array(whitelists)
    self
  end

  private

  attr_accessor :whitelist_policies
  attr_writer :last_purged, :last_purged_directory

  def files_to_delete
    all_files = Dir["#{last_purged_directory}/*"]
    whitelist = whitelist_policies.each_with_object([]){ |policy, whitelist|
      whitelist.concat policy.new.matches all_files
    }

    all_files - whitelist
  end
end
