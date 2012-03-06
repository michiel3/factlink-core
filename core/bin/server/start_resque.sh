count=`ps x | grep -v grep | grep -c "resque-"`

if [ "$count" -lt "1" ]; then
    . /home/deploy/.bash_profile

    cd /applications/factlink-core/current

    export PIDFILE=/home/deploy/resque.pid
    export QUEUE=*

    nohup bundle exec rake environment resque:work PIDFILE=$PIDFILE > /applications/factlink-core/current/log/resque.log 2>&1
fi