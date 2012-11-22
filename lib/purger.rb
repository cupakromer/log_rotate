class Purger
  attr_reader :directory, :last_purged

  def initialize(directory)
    @whitelist_policies = []
    @last_purged = []
    @directory = File.expand_path directory
  end

  def purge
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
  attr_writer :last_purged

  def files_to_delete
    all_files = Dir["#{directory}/*"]
    whitelist = whitelist_policies.each_with_object([]){ |policy, whitelist|
      whitelist.concat policy.new.matches all_files
    }

    all_files - whitelist
  end
end
