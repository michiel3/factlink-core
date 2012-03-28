namespace :fact_graph do
  if defined?(ExceptionNotifier)
    def exception_notify
      yield
    rescue SignalException => exception
      # we were killed (probably by deploy)
      raise exception
    rescue Exception => exception
      ExceptionNotifier::Notifier.background_exception_notification(exception)
      raise exception
    end
  else
    def exception_notify
      yield
    end
  end

  task :recalculate => :environment do

    `echo "#{Process.pid}" > /var/lock/monit/fact_graph/fact_graph_recalculate.pid`
    `echo "#{Process.ppid}" > /var/lock/monit/fact_graph/fact_graph_recalculate.ppid`

    exception_notify do
      STDOUT.flush
      sleep_time = 59
      puts "now recalculating with interval of #{sleep_time} seconds"
      $stdout.flush
      while true
        puts "now recalculating factgraph"
        $stdout.flush
        FactGraph.recalculate
        sleep sleep_time
      end
    end
  end
end