Dir[File.expand_path('policies/**/*.rb', File.dirname(__FILE__))].each do |f|
  require f
end
