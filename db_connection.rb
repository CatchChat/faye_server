ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     ENV['DB_HOST'],
  username: ENV['DB_USERNAME'],
  password: ENV['DB_PASSWORD'],
  database: ENV['DB_NAME']
)
