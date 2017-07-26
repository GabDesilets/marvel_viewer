# Lol rails
require 'ostruct'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_marverlite_service

  def index
    heroes = @ms.get_all_heroes
    locals heroes: heroes
  end

  def show
    hero = @ms.get_by_name(params[:name])
    wiki_url = hero["urls"].detect{|hash| hash["type"] == "wiki" }

    if wiki_url
      raw_wiki = Nokogiri::HTML(open(wiki_url["url"]), nil, Encoding::UTF_8.to_s)
      powergrid = raw_wiki.at_css('[id="powergrid-holder"]')
    else
      powergrid = nil
    end

    locals hero: hero, bio: get_hero_bio(hero), wiki_url: wiki_url, powergrid: powergrid
  end


  private

  def locals(values)
    render locals: values
  end

  def set_marverlite_service
    @ms = MarveliteService.new
  end

  def get_hero_bio(hero)
    bio = RedisClient.redis.get("get:#{hero["name"]}:bio")
    if bio.nil?
      begin
        raw_html = Nokogiri::HTML(open("https://marvel.com/characters/bio/#{hero["id"]}/#{hero["name"]}"), nil, Encoding::UTF_8.to_s)
        raw_bio = raw_html.css(".featured-item-meta").css("p")
        raw_show_more_span = raw_html.css(".featured-item-meta").css("p").css("span")
        bio = CharacterBio.new(
          raw_bio[0].text, # real_name
          raw_bio[1].text, # height
          raw_bio[2].text, # weight
          raw_show_more_span[1].text, # powers
          raw_show_more_span[3].text, # abilities
          raw_show_more_span[5].text, # groups_aff
          raw_bio[9].text, # first_app
          raw_show_more_span[7].text # origin
        )
      rescue
        bio = CharacterBio.new(
          "N/A",
          "N/A",
          "N/A",
          "N/A",
          "N/A",
          "N/A",
          "N/A",
          "N/A"
        )
      end
      RedisClient.redis.set("get:#{hero["name"]}:bio", bio.to_json)
      RedisClient.redis.expire("get:#{hero["name"]}:bio", 2.days.to_i)
      bio = bio.to_json
    end
    JSON.parse(bio, object_class: OpenStruct)
  end
end
