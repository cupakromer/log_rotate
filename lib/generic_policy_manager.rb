class GenericPolicyManager
  def initialize(whitelist_policies = [])
    self.whitelist_policies = Array whitelist_policies
  end

  def filter(file_names)
    whitelist_policies.each_with_object([]){ |policy, whitelist|
      whitelist.concat Array policy.filter file_names
    }.uniq
  end

  private

  attr_accessor :whitelist_policies
end
