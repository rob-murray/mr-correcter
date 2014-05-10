require 'rspec/core'
require 'rspec/core/rake_task'

task default: :spec

desc 'Run all specs in spec directory (excluding plugin specs)'
RSpec::Core::RakeTask.new(:spec)

desc 'Run MrCorrecter'
task :run do
  require_relative 'lib/mr_correcter'

  # MrCorrecter.configure do |config|
  #   config.post_tweets = false
  #   config.search_period_hours = 2
  # end

  MrCorrecter.load_config 'config.yml'

  # examples
  MrCorrecter.add_correction('accomodate', 'accommodate')
  MrCorrecter.add_correction('beleive', 'believe')
  MrCorrecter.add_correction('curiousity', 'curiosity')

  MrCorrecter.correct!
end
