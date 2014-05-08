namespace :errbit do
  namespace :db do

    desc 'Sets priority on problems.'
    task :prioritize => :environment do
      notices = Notice.all
      count = notices.count
      found = 0

      puts "Running filters on #{count} notice(s)."
      notices.each do |notice|
        if notice.app.urgent_notice? notice
          notice.problem.update_attribute :urgent, true
          found += 1
        else
          notice.problem.update_attribute :urgent, false
        end
      end
      puts "Found a total of #{found} match(es)."
    end
  end
end
