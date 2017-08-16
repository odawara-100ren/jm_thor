# require "active_record"

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: "/Users/mod/ruby/2.3.1/jm_thor/jm.db"
)
