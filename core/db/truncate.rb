def self.truncate(opts)
  # Clear stuff
  if Rails.env.development?
    $redis.FLUSHDB                # Clear the Redis DB
    env = 'development'
    mongoid_conf = YAML::load_file(Rails.root.join('config/mongoid.yml'))[env]

    puts mongoid_conf['database']

    mongo_db = Mongo::Connection.new(mongoid_conf['host'], 
    mongoid_conf['port']).db(mongoid_conf['database'])
    mongo_db.collections.each { |col| col.drop() unless col.name == 'system.indexes' || col.name == "users"}


    if opts[:users] == :truncate
      # HACK; sorry, don't know efficient way, and shouldn't matter to much for development
      mongo_db.collections.each { |col| col.drop() if col.name == "users"}
    else
      User.all.each do |u|
        u.send(:create_graph_user) {}
      end
    end

    Sunspot.remove_all!(FactData) # Remove the indices of all Facts in Solr.

    # Commit the indices to Solr
    Sunspot.commit
  else
    puts "I only truncate in development!!"
  end

end
