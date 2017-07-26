module RedisClient
  class << self
    def redis
      @redis ||= Redis.new(host: 'redis', port: 6379)
    end
  end
end
