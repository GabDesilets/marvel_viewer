require 'json'

class MarveliteService
  def initialize
    # TODO CHANGE THIS SHIT
    @m_client = Marvelite::API::Client.new( :public_key => "c47e13428c71a854d64a520bd6f914e5", :private_key => "c76dddef87a93c24c651e5aa31ac24befba17f67")

  end

  def get_all_heroes
    heroes = RedisClient.redis.get("get_all_heroes")
    if heroes.nil?
      heroes = @m_client.characters(:limit => 100, :orderBy => 'name')
      heroes.data[:results].each do |hero|
        RedisClient.redis.set("get:#{hero[:name]}", hero.to_json)
        RedisClient.redis.expire("get:#{hero[:name]}", 350.days.to_i)
      end
      RedisClient.redis.set("get_all_heroes", heroes.data[:results].to_json)
      RedisClient.redis.expire("get_all_heroes", 350.days.to_i)
      heroes = heroes.data[:results].to_json
    end
    JSON.parse(heroes)
  end

  def get_by_name(name)
    hero = RedisClient.redis.get("get:#{name}")
    if hero.nil?
      hero = @m_client.character(name)
      RedisClient.redis.set("get:#{name}", hero.data[:results][0].to_json)
      RedisClient.redis.expire("get:#{name}", 350.days.to_i)
      hero = hero.data[:results][0].to_json
    end
    JSON.parse(hero)
  end
end
