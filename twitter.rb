#!/usr/bin/env ruby
# encoding: utf-8

require "twitter"
require 'tweetstream'
require "em-synchrony"
require "em-synchrony/mysql2"
require 'yaml'

config = YAML.load_file('config/database.yml')


p config


class Twitter_bot  #bot itself, note that it require global variable  $sql (em syncchrony mysql2 implication) for connection to db

 def initialize(city) #each object should be created for each separated city
  @city = city
  @bots = Array.new
   @rest = nil  # for REST API
   @stream = nil # for streaming API
   @listen = false
 end

  def check_self
self.start_watching if @listen == false
 end

 def start_watching  #start watching for nike twitter acc in selected city with currect alive bot
 

  Fiber.new{
      f = Fiber.current
    begin
find_work_bot()

    if @bots.length == 0
      listen = false 
       alert("No active bots available")
     else
if @listen == false  #don't need to have more than 1 listner
tofollow =  $sql.query("SELECT * FROM cities WHERE id = #{@city}")
tofollow = tofollow.to_a[0]['twitter']


connect_rest()
@rest.follow(tofollow)  #make sure we follow city we are watching

user = @rest.user(tofollow)

p user[:id]

#process_rsvp("Air Jordan 3 Retro","#dfsgsdg","33", tofollow)
connect_stream()
@listen = true
        @stream.follow(user[:id]) do |status|
              rsvp = status.text.match(/(?:RSVP.*?for.{0,3}the)(.*?)(?:in sizes)(.*?)(#.*?)(?:Rules)/mi)
              if rsvp != nil  #we have found rsvp twitter
                p "RSVP FOUND!!!!"
                p rsvp
               process_rsvp(rsvp[1].strip,rsvp[3],rsvp[2], tofollow)
              else
                p "there is a tweet but no rsvp found:"
                p status.text
              end
        end
end
end

rescue Exception => e
  p e
  p e.backtrace
  @listen = false
  alert("Unable to start listner for cityid #{@city}")
end


}.resume
 end






 def process_rsvp(what, hash, sizes, tofollow) #things to do with rsvp
product_id = $sql.aquery("SELECT * FROM products WHERE title LIKE '%#{what}%'")
product_id.callback{|c| # finding product ID
if c.to_a.length != 0
product_id = c.to_a[0]['id']  

  p "product id = #{product_id} "
  orders_def = $sql.aquery("SELECT * FROM orders WHERE product_id = #{product_id}")
  orders_def.callback{|orders|
    p "ord is"
    p orders

    bot_id = 0

   orders.to_a.each{|order|
   begin
   @rest.direct_message_create(tofollow, hash + ", " + order['name'] + ", " + order['size'])
   p "send message success"
   bot_id = connect_rest(bot_id)
   
   alert("Not enough bots!") if bot_id == 0 #if it is 0 - no more bots

   rescue
   end
   } 
   
  }
else  # if RSVP found but product not found
  alert("RSVP failed!!!! Product  '%#{what}%' wasn't found :(") 
end
}
 end

 def connect_rest(id = 0)
  bot = @bots[id]
  if bot != nil
  @rest = Twitter::Client.new( 
  :consumer_key => bot['consumer_key'],
  :consumer_secret => bot['consumer_secret'],
  :oauth_token => bot['oauth_token'],
  :oauth_token_secret => bot['oauth_token_secret']
   )
  return id + 1
  else
  return 0
  end
  
  
  
 end

 def connect_stream(id = 0)
  bot = @bots[id]
  if bot != nil
  @stream = TweetStream::Client.new( 
  :consumer_key => bot['consumer_key'],
  :consumer_secret => bot['consumer_secret'],
  :oauth_token => bot['oauth_token'],
  :oauth_token_secret => bot['oauth_token_secret'],
  :auth_method   => :oauth
  )
  
   return id + 1
  else
   return 0
  end
 end

end


def alert(message) #send an alert
  p message

end

 def find_work_bot  #finding working bot in database
  p  "seeking bot"

bot = $sql.query("SELECT * FROM twitter_accounts WHERE works = 1")
@bots = bot.to_a
 
 



 end

 def check_bots  #check if current bot ok
p "checking bots"
Fiber.new{
bot = $sql.query("SELECT * FROM twitter_accounts")

bot.to_a.each{|bot|
  begin

  test  = Twitter::Client.new( 
  :consumer_key => bot['consumer_key'],
  :consumer_secret => bot['consumer_secret'],
  :oauth_token => bot['oauth_token'],
  :oauth_token_secret => bot['oauth_token_secret']
   )
  test.user_timeline("Dvporg").first.text
  $sql.aquery("UPDATE twitter_accounts SET works = 1 WHERE id= #{bot['id']}")  #if no exception than its ok
  p "good bot found"
  rescue
  $sql.aquery("UPDATE twitter_accounts SET works = 0  WHERE id= #{bot['id']}")  #if an exception - something wrong with twitter account
  p "bad bot found"
  end
}

}.resume
 end

def process_cities #creating new and refreshing existing cities
 Fiber.new{
 cities =  $sql.aquery("SELECT * FROM cities")
 cities.callback{|city_obj|
  
city_obj.to_a.each{|city|
  
if $hash_with_cities[city['name']] != nil
$hash_with_cities[city['name']].check_self
else
$hash_with_cities[city['name']] = Twitter_bot.new(city['id'])
$hash_with_cities[city['name']].start_watching
end
 }
}
}.resume
end

EM.synchrony do
sqlconf = { 
    :host => "localhost", 
    :database => config['development']['database'],   
    :reconnect => true,  # make sure you have correct credentials
    :username => config['development']['username'],
    :password => config['development']['password'],
    :size => 30,
}

    $sql = EventMachine::Synchrony::ConnectionPool.new(size: 20) do
        Mysql2::EM::Client.new(sqlconf)
    end

$hash_with_cities = Hash.new  #hash where to put each twitter acc for exact city

process_cities()


EM::PeriodicTimer.new(10) do
 p "work"
  process_cities()
end

end