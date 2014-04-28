connection_hash = case Rails.env.to_sym
  when :development
    {host: 'localhost', port: 6381}
  when :test
    {host: 'localhost', port: 6379}
  when :staging
    {host: '172.18.64.14', port: 6379}
  when :production
    {host: '172.18.64.22', port: 6379}
  end

Redis.current = Redis.new(connection_hash)
