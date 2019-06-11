desc "This task is called by the Heroku scheduler add-on to get prices"
task get_price_job: :environment do
  puts "Getting prices..."
  GetPriceJob.perform_now
  puts "done."
end

desc "This task is called by the Heroku scheduler add-on to get positions"
task get_positions_job: :environment do
  puts "Getting positions..."
  GetPositionsJob.perform_now
  puts "done."
end
