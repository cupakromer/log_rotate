# Any files that do not start with:
#
#   ####-##-##-
#
# It ignores if the date is actually a valid date.
class NonDateStampedPolicy
  def filter(file_names)
    Array(file_names).reject{ |name|
      File.basename(name) =~ /\A\d{4}-\d{2}-\d{2}-.+\z/
    }
  end
end
