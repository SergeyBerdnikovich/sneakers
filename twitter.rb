#!/usr/bin/env ruby
# encoding: utf-8

require "twitter"
require 'tweetstream'
require "em-synchrony"
require "em-synchrony/mysql2"
require 'yaml'
config = YAML.load_file('config/database.yml')
$timestamp = Time.now.to_i  #used to find if twitter acc was used after app launched or not. Global because of the same for every object.

p config


class Twitter_bot  #bot itself, note that it require global variable  $sql (em syncchrony mysql2 implication) for connection to db

 def initialize(city,create_id = 0) #each object should be created for each separated city
  @city = city
  @create_id = create_id 
  @bots = Array.new
   @rest = nil  # for REST API
   @stream = nil # for streaming API
   @listen = false
 end

  def check_self
self.start_watching if @listen == false
p "checking self"
 end

 def start_watching  #start watching for nike twitter acc in selected city with currect alive bot
 

  Fiber.new{
      f = Fiber.current
    begin
bot_id = find_work_bot()
p "bot found"
    if @bots.length == 0
      listen = false 
       alert("No active bots available")
     else
if @listen == false  #don't need to have more than 1 listner
tofollow =  $sql.query("SELECT * FROM cities WHERE id = #{@city}")

tofollow = tofollow.to_a[0]['twitter']

p "conntecting rest"
connect_rest()
p "rest connected"
p "trying to follow"
begin
@rest.follow(tofollow)  #make sure we follow city we are watching
rescue
p "Error during to follow"
end
p "followed"

user = @rest.user(tofollow)

p user[:id]

#process_rsvp("Air Jordan 3 Retro","#dfsgsdg","33", tofollow)
connect_stream()
@listen = true
p "connecting stream to #{user[:id]} "
        @stream.follow(user[:id]) do |status|
              rsvp = status.text.match(/(?:RSVP.*?for.{0,3}the)(.*?)(?:in sizes)(.*?)(#.*?)(?:Rules)/mi)
              if rsvp != nil  #we have found rsvp twitter
                p "RSVP FOUND!!!!"
                p rsvp
               process_rsvp(rsvp[1].strip,rsvp[3],rsvp[2], tofollow, @city)
              else
                p "there is a tweet but no rsvp found:"
                p status.text
              end
        end
p "end stream block"
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






 def process_rsvp(what, hash, sizes, tofollow,city_id) #things to do with rsvp
product_id = $sql.aquery("SELECT * FROM products")
product_id.callback{|c| # finding product ID

if c.to_a.length != 0
product_id = 0
begin 
c.to_a.each{|product_object|
p product_object
if product_object['title'].strip.index(what) != nil
product_id = product_object['id']  
end

if what.strip.index(product_object['title']) != nil
product_id = product_object['id']  
end
}
product_id = -1 if product_id == 0  #if we didn't find anything, to go out of the loop
end while product_id == 0

  p "product id = #{product_id} "
if product_id > 0 
  orders_def = $sql.aquery("SELECT * FROM orders WHERE product_id = #{product_id} AND city_id = #{city_id}")
  orders_def.callback{|orders|
    p "ord is"
    p orders

    bot_id = 0
   if orders.to_a.length > 0
     orders.to_a.each{|order|
   begin
    p "rest is"
    @rest = connect_rest(bot_id)
   
    p @rest

   @rest.direct_message_create(tofollow, hash + ", " + order['name'] + ", " + order['size'])
   p "send message success for #{@city} behalf of #{order['name']}"
   bot_id += 1
   alert("Not enough bots!") if bot_id == 0 #if it is 0 - no more bots

   rescue
   end
   } 
  else
    alert("RSVP was found, product was recognized but no order found. Product_id is #{product_id}")
  end
   
  }
else
alert("Product wasn't recognized in the DB - #{what}")
end
else  # if RSVP found but product not found
  alert("RSVP failed!!!! Product  '%#{what}%' wasn't found :(") 
end
}
 end

 def connect_rest(id = 0)
  bot = @bots[id]
  if bot != nil
    p bot
  @rest = Twitter::Client.new( 
  :consumer_key => bot['consumer_key'],
  :consumer_secret => bot['consumer_secret'],
  :oauth_token => bot['oauth_token'],
  :oauth_token_secret => bot['oauth_token_secret']
   )
  return @rest
  else
  return 0
  end
  
  
  
 end

 def connect_stream(id = 0)
  bot = find_work_stream_bot()
  p bot
  if bot != nil
  $sql.query("UPDATE twitter_accounts SET last_used = #{Time.now.to_i + 1 } WHERE id = #{bot['id']} ")
  p  Time.now.to_i + 10 
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

def release_bot(id)  #reset timestamp to bot be able to used for streaming
  $sql.query("UPDATE twitter_accounts SET last_used = 0 WHERE id = #{id}")
end

def alert(message) #send an alert
  p message
end

 def find_work_bot  #finding working bot in database
p  "seeking bot"  
bot = $sql.query("SELECT * FROM twitter_accounts WHERE works = 1")
@bots = bot.to_a
 p "bot array formed"
 end

  def find_work_stream_bot  #finding working bot for streaming, that never have been used in database
p  "seeking stream bot"  
 p $timestamp
bot = $sql.query("SELECT * FROM twitter_accounts WHERE works = 1 AND last_used < #{$timestamp} LIMIT 1 OFFSET #{@create_id}")  #ofset is needed to not allow several cities to use one acc during startup 

return bot.to_a[0]
 
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
  create_id = 0
city_obj.to_a.each{|city|
  
if $hash_with_cities[city['name']] != nil
$hash_with_cities[city['name']].check_self
else

$hash_with_cities[city['name']] = Twitter_bot.new(city['id'],create_id)
create_id += 1
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