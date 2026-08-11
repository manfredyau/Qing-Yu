ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # 并行 worker 数：本机（Windows）线程并行共享 PG 连接池会触发外键校验死锁与连接池耗尽，
    # 默认单线程；CI 等环境可用 PARALLEL_WORKERS 环境变量覆盖
    parallelize(workers: ENV.fetch("PARALLEL_WORKERS", 1).to_i, with: :threads)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
