require 'benchmark'

namespace :errbit do
  namespace :db do

    desc 'Runs the defined filters through all notices and if found sets the problem to resolved.'
    task run_filters: :environment do
      problems = Problem.all.where(resolved: false)
      count = problems.size
      found = 0

      puts "Running filters on #{count} problem(s)."
      problems.each do |problem|
        unless problem.app.keep_notice? problem
          problem.update_attribute :resolved, true
          found += 1
        end
      end
      puts "Found a total of #{found} match(es)."
    end
  end
end
