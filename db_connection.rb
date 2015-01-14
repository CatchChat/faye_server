ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'rails-staging.cvl5jg6jbzld.rds.cn-north-1.amazonaws.com.cn',
  username: 'catch_dbuser',
  password: 'catch_dbpassword',
  database: 'catchchat_server_staging'
)
