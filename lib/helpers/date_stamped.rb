require 'date'

module DateStamped
  def date(name)
    Date.strptime(date_part(name), '%Y-%m-%d')
  end

  def date_part(name)
    File.basename(name)[0,10]
  end
end
