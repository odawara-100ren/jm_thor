require "bundler/setup"
require "jm_thor"
require "pry"

# DBの切り分け
# JiraManpower::DatabaseUtil.class_eval{ remove_const(:DATABASE) }
JiraManpower::DatabaseUtil.const_set(:DATABASE, "jm_test.db")

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.append_after(:each) do
    # 手書きのDatabaseCleaner
    db = SQLite3::Database.new JiraManpower::DatabaseUtil.const_get(:DATABASE)
    db.execute "delete from manpowers"
  end
end
