namespace :errbit do
  namespace :db do

    desc 'Sets priority on problems.'
    task prioritize: :environment do
      problems = Problem.all.where(resolved: false)
      count = problems.count
      found = 0

      puts "Running filters on #{count} problem(s)."
      problems.each do |problem|
        problem.update_attribute :urgent, false
        if problem.app.urgent_notice?(problem)
          problem.update_attribute :urgent, true
          found += 1
        end
      end
      puts "Found a total of #{found} match(es)."
    end
  end
end
