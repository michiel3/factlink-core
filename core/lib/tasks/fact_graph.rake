namespace :fact_graph do
  task :recalculate => :environment do

    `echo "#{Process.pid}" > /var/lock/monit/fact_graph/fact_graph_recalculate.pid`
    `echo "#{Process.ppid}" > /var/lock/monit/fact_graph/fact_graph_recalculate.ppid`


    STDOUT.flush
    sleep_time = 59
    puts "now recalculating with interval of #{sleep_time} seconds"
    while true
      #print "(#{Time.now.asctime}) recalculating FactGraph\n"
      FactGraph.recalculate
      #print "(#{Time.now.asctime}) sleeping\n"
      sleep sleep_time
    end
  end
end