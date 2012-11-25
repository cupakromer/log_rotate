Dir[File.expand_path('helpers/**/*.rb', File.dirname(__FILE__))].each do |f|
  require f
end
