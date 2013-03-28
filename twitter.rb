#!/usr/bin/env ruby
# encoding: utf-8

require "twitter"
require 'tweetstream'
#require "em-synchrony"
#require "em-synchrony/mysql2"
require 'eventmachine'
require 'yaml'
require "em_mysql2_connection_pool"
require "mysql2"
require 'levenshtein'
require 'em-http'
require 'oj'


$env = 'production'

config = YAML.load_file('config/database.yml')
$timestamp = Time.now.to_i  #used to find if twitter acc was used after app launched or not. Global because of the same for every object.

p config

$listenarr = Hash.new() #where to keep city info

class Twitter_bot  #bot itself, note that it require global variable  $sql (em syncchrony mysql2 implication) for connection to db

  def initialize(city,create_id = 0) #each object should be created for each separated city
    @city = city
    @create_id = create_id
    @bots = Array.new
    @rest = nil  # for REST API
    @stream = nil # for streaming API
    @listen = false
    @user = ""
  end

  def status
    if @listen == true
      return @user
    else
      return false
    end
  end

  def close
    begin
      if @stream != nil
        EventMachine.stop_server($session[:em_server_id]) if $session[:em_server_id]
        @stream.stop
      end
    rescue Exception => e
      p e
      p e.backtrace
    end
  end

  def check_self
    self.start_watching if @listen == false
  end

  def find_work_bot(id = 0, id_match = false, city_id = 0)  #finding working bot in database
    p "Bot id is = #{id}"
    begin
      if id_match == false
        if city_id != 0
          bot = $sqlsync.query("SELECT * FROM twitter_accounts WHERE works = 1 AND city_id = #{city_id} ORDER BY last_checked ASC LIMIT 1 OFFSET #{id}")
        else
          bot = $sqlsync.query("SELECT * FROM twitter_accounts WHERE works = 1 ORDER BY last_checked ASC LIMIT 1 OFFSET #{id}")
        end
      else
        bot = $sqlsync.query("SELECT * FROM twitter_accounts WHERE id = #{id}")
      end
      p bot.to_a
      bot = bot.to_a[0]
      #f.resume bot
      return bot
    rescue Exception => e
      p e
      sleep(0.1)
      retry
    end

  end

  def start_watching  #start watching for nike twitter acc in selected city with currect alive bot

    begin
      bot = self.find_work_bot
      p "bot found"
      if bot.length == 0
        alert("No active bots available")
      else
        if @listen == false  #don't need to have more than 1 listner
          tofollow =  $sqlsync.query("SELECT * FROM cities WHERE id = #{@city}")

          tofollow = tofollow.to_a[0]['twitter']
          p "To follow is #{tofollow}"
          p "conntecting rest"
          @rest = connect_rest(bot)
          p "Rest connected"
          begin
            user = @rest.user(tofollow)
          rescue
            alert("USER #{tofollow} NOT FOUND!!!! Check twitter name!")
            return false
          end
          p "User found: #{user[:id]}, connecting stream with options:"
          p "@create_id - #{@create_id},tofollow - #{tofollow}, city - #{@city}, user - #{user}"
          #process_rsvp("Air Jordan 3 Retro","#dfsgsdg","33", tofollow)
          connect_stream(@create_id,tofollow, @city, user)
          @listen = true
          p "Stream connected"

          p "connecting stream to #{tofollow} ( #{user[:id]} )"


          @stream.on_error do |message|
            p "FAULT LISTENER"
            @listen = false
            self.alert("FAULT LISTENER")
            self.alert(message)
            p message
            # No need to worry here. It might be an issue with Twitter.
            # Log message for future reference. JSONStream will try to reconnect after a timeout.
          end



          @stream.follow(user[:id]) do |status|
            if status[:user][:id] == user[:id]

              rsvp = find_rsvp(status.text)#.match(/(?:RSVP.*?for.{0,3}the)(.*?)(?:in sizes)(.*?)(#\w*)/im)
              if rsvp != false  #we have found rsvp twitter
                p "RSVP FOUND!!!!"#, pausing"
                p rsvp
                p status.text
                #EM::Synchrony.sleep(6)  #pause to not looks like bot
                process_rsvp(rsvp['str'],rsvp['keyword'],rsvp['sizes'], tofollow, @city, user[:id])

              else
                p "there is a tweet but no rsvp found:"
                p status.text
              end
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



  end


  def follow(who_to_follow, user_id, bot_id)  #we just here test and form array if we are following one specific shop

    p  "trying to process following"
    botsfollowings = $sqlsync.query("SELECT following FROM twitter_accounts WHERE id = #{bot_id}")
    botsfollowings = botsfollowings.to_a[0]['following']
    botsfollowings = "" if botsfollowings == nil
    p user_id.to_s
    p bot_id
    if botsfollowings.index(user_id.to_s) == nil
      p "We have found that bot_id #{bot_id} doesnt followed #{$who_to_follow}, trying to fix that"
      begin
        p "bot id is"
        p bot_id
        bot = self.find_work_bot(bot_id, true)
        @follow_rest = connect_rest(bot)
        @follow_rest.follow(who_to_follow)  #make sure we follow city we are watching
        sleep(1)
      rescue Exception => e
        p e
        p e.backtrace
        p "Error during to follow"
      end
      p "followed"
    end

    p "all ok with follow"
  end



  def process_rsvp(what, hash, sizes, tofollow,city_id, user_id) #things to do with rsvp

    product_id = $sql.query("SELECT * FROM products")
    product_id.callback{|c| # finding product ID
      c = c.to_a
      what = what.gsub(/[^a-zA-Z0-9]/mi,"").downcase

      if c.length != 0
        product_id = 0
        # begin
        product_distances = Hash.new
        c.each{|product_object|
          if product_id == 0

            product_title = product_object['title'].gsub(/[^a-zA-Z0-9]/mi,"").downcase

            p product_title
            p what
            product_distances[product_object['id']] = Array.new
            product_distances[product_object['id']][0] = Levenshtein.distance(what,product_title)
            product_distances[product_object['id']][1] = product_object['id']
            product_distances[product_object['id']][2] = product_title.length

          end
        }
        if product_id == 0  #if nothing found then finding the closest match
          p "No strict match, implementing tricky algorythm"
          product_distances = product_distances.values.min
          max_distance = (what.length - product_distances[2]).abs + 20
          p product_distances
          p max_distance
          p what.length
          product_id = product_distances[1].to_i if product_distances[0] < max_distance

        end
        #  product_id = -1 if product_id == 0  #if we didn't find anything, to go out of the loop
        #end while product_id == 0

        p "product id = #{product_id} "
        if product_id > 0
          orders_def = $sql.query("SELECT * FROM orders WHERE product_id = #{product_id} AND city_id = #{city_id} AND sent = false")
          orders_def.callback{|orders|
            p "ord is"
            orders = orders.to_a

            i = 0
            if orders.length > 0
              p "Order dump is:"
              p orders
              orders.each{|order|


                begin
                  p "rest is #{i}"
                  p order
                  if check_if_size_is_in_range(sizes,order['size'])
                    process_orders(i,order,tofollow,user_id,hash)
                    i += 1

                    #alert("Not enough bots!") if bot_id == 0 #if it is 0 - no more bots

                  else
                    $sql.query("UPDATE orders SET sent = false, message = 'Message WAS NOT send for #{@city} behalf of #{order['name']}!!!! Beacuse of: #{e.to_s}' WHERE id = #{order['id']}")
                    p "send message UNSUCCESSS for #{@city} behalf of #{order['name']}"
                  end

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


  end # end of class, common functions bellow

  def process_orders(i,order,tofollow,user_id,hash)
    EM.defer do #do sending via thread pool because of it's blocking

      @start = Time.now
      p "Connecting to #{i}"
      bot = self.find_work_bot(i, false, order['city_id'])
      if bot != nil
        rest = connect_rest(bot)
        i += 1

        p "rest connected, now follow"
        @rest = rest
        self.follow(tofollow, user_id,bot['id'])

        p "sending message..."
        what_to_send = hash + ", " + order['name'] + ", " + order['size']

        begin
          if bot['pause'] != nil
            sleep(bot['pause']) if bot['pause'] != 0
          end
          rest.direct_message_create(tofollow, what_to_send)
        rescue Exception => e
          alert("Message WAS NOT send for #{@city} behalf of #{order['name']}!!!! Beacuse of: #{e.to_s}" )
          $sqlsync.query("UPDATE orders SET sent = 0, message = 'Message WAS NOT send for #{@city} behalf of #{order['name']}!!!! Beacuse of: #{e.to_s}' WHERE id = #{order['id']}")
          $sqlsync.query("UPDATE twitter_accounts SET last_checked = 0 WHERE id = #{bot['id']}")
        end
        p "Comunication with twitter takes #{Time.now - @start} seconds"

        $sql.query("UPDATE orders SET sent = true, message = '#{Time.now} message was sent from #{bot['name']} to #{tofollow} - #{what_to_send}' WHERE id = #{order['id']}")
        $sqlsync.query("UPDATE twitter_accounts SET last_checked = #{Time.now.to_i} WHERE id = #{bot['id']}")
        p "send message success for #{@city} behalf of #{order['name']}"
        #  EM::Synchrony.sleep(Random.rand(0.0..3.0)) #make pause on succesfull sending to not looks like bots
      else
        alert("No bot found!")
      end
    end
  end

  def check_if_size_is_in_range(range, size) #cheks, if specific size in range that looks loke 7-10, 11, 12, 13
    in_range = false
    size.strip!
    sizes = range.scan(/[\d-]{1,99}/mi)
    sizes.each do |size_in_stock|
      size_to_compare = size_in_stock.split("-")
      if size_to_compare.length == 1
        in_range = true if size_to_compare[0].strip.index(size)
      else
        if size_to_compare[0].to_i <= size.to_f
          if size_to_compare[1].to_i >= size.to_f
            in_range = true
          end
        end
      end
    end

    return in_range
  end



  def connect_rest(bot)

    if bot.length != 0
      p bot
      @conn = Twitter::Client.new(
      :consumer_key => bot['consumer_key'],
      :consumer_secret => bot['consumer_secret'],
      :oauth_token => bot['oauth_token'],
      :oauth_token_secret => bot['oauth_token_secret']
      )
      p @conn
      return @conn
    else
      return 0
    end



  end

  def connect_stream(id = 0,who_to_follow, user_id, bot_id)
    bot = find_work_stream_bot()
    p bot
    if bot != nil
      self.follow(who_to_follow, user_id,bot['id'])
      @user = bot["name"]
      p "user is #{@user}"
      p "UPDATE twitter_accounts SET last_used = #{Time.now.to_i + 1 } WHERE id = #{bot['id']} "
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



def find_work_stream_bot  #finding working bot for streaming, that never have been used in database
  p  "seeking stream bot"
  p $timestamp
  bot = $sqlsync.query("SELECT * FROM twitter_accounts WHERE works = 1 AND last_used < #{$timestamp} LIMIT 1")  #ofset is needed to not allow several cities to use one acc during startup
  p bot.to_a
  return bot.to_a[0]

end



def check_bots  #check if current bot ok
  p "checking bots"
  bots = $sqlsync.query("SELECT * FROM twitter_accounts")

  bots.to_a.each{|bot|
    begin

      test  = Twitter::Client.new(
      :consumer_key => bot['consumer_key'],
      :consumer_secret => bot['consumer_secret'],
      :oauth_token => bot['oauth_token'],
      :oauth_token_secret => bot['oauth_token_secret']
      )
      bot_uid = bot['oauth_token'].gsub(/-.*/,"").to_i

      dms = test.direct_messages

      dms.each do |dm|
        if dm[:recipient][:id] == bot_uid
          #   p dm[:text]
          #   p dm[:created_at]
          e = $sqlsync.query("SELECT * FROM dms WHERE text = '#{$sqlsync.escape(dm[:text])}' AND received = '#{dm[:created_at]}' AND twitter_account_id = #{bot['id']} ")  #if no exception than its ok
          #res.callback{|e|
          if e.to_a.length == 0
            $sql.query("INSERT INTO dms( text, received, twitter_account_id ,sender) VALUES ('#{$sqlsync.escape(dm[:text])}', '#{dm[:created_at]}', #{bot['id']}, '#{dm[:sender][:screen_name]}') ")
          end
          #}
        end

      end

      $sql.query("UPDATE twitter_accounts SET works = 1 WHERE id= #{bot['id']}")  #if no exception than its ok
      p "good bot found"
    rescue Exception => e
      p e
      $sql.query("UPDATE twitter_accounts SET works = 0  WHERE id= #{bot['id']}")  #if an exception - something wrong with twitter account
      p "bad bot found"
    end
  }


end

def new_listeners()
  EM.fork_reactor do
    $session = Hash.new
    EM.run do
      $session[:em_server_id] =  EventMachine::start_server "0.0.0.0", 8000, CheckerHandler
      config = YAML.load_file('config/database.yml')
      sqlconf = {
        :host => "localhost",
        :database => config[$env]['database'],
        :reconnect => true,  # make sure you have correct credentials
        :username => config[$env]['username'],
        :password => config[$env]['password'],
        :size => 30,
        :reconnect => true,
        :connections => 50
      }

      $sql = EmMysql2ConnectionPool.new(sqlconf)
      $sqlsync = Mysql2::Client.new(sqlconf)

      process_cities_inside()
      EM::PeriodicTimer.new(15) do
        process_cities_inside()
      end
    end
  end
end


def process_cities_inside #stoppiing and refreshing existing cities inside worker forked EM reactor

  cities =  $sql.query("SELECT * FROM cities")

  cities.callback{|city_obj|
    city_obj = city_obj.to_a
    if city_obj != $listenarr
      p "cities are being reinitialized"
      p $hash_with_cities.length
      if $hash_with_cities.length != 0
        $hash_with_cities.each do |city|
          p city
          city[1].close
          $hash_with_cities.delete(city[0])
        end
        p "listners killed"
      else
        create_id = 0
        $hash_with_cities = Hash.new()
        $timestamp = Time.now.to_i
        p "ok1"
        p city_obj
        city_obj.each{|city|
          p city
          $hash_with_cities[city['twitter']] = Twitter_bot.new(city['id'],create_id)
          p "Listner launched for #{city['twitter']}"
          create_id += 1
          $hash_with_cities[city['twitter']].start_watching
          sleep(0.5)  #pause to not looks like bot
        }
      end
    else
      city_obj.each{|city|
        $hash_with_cities[city['twitter']].check_self
      }
    end
    $listenarr = city_obj

  }

end


def process_cities_outside #monitoring and starting new working reactors
  cities =  $sql.query("SELECT * FROM cities")
  cities.callback{|city_obj|
    city_obj = city_obj.to_a
    if city_obj != $listenarr
      p "starting new listeners"
      $hash_with_cities = Hash.new()
      new_listeners()
    end
    $listenarr = city_obj
  }



end

def find_rsvp(str)
  begin
    sizes = str.match(/\d{1,2}[^#0-9]{1,7}\d{1,2}[^#0-9]{0,7}\d{0,2}[^#0-9]{0,7}\d{0,2}[^#0-9]{0,7}\d{0,2}[^#0-9]{0,7}\d{0,2}[^#0-9]{0,7}\d{0,2}[^#0-9]{0,7}\d{0,2}[^#0-9]{0,7}\d{0,2}/im)[0]
    str = str.sub(sizes,"")
    keyword = str.scan(/#[\_\w\-]*/im)
    keyword = keyword[keyword.size - 1 ]
    p keyword
    str = str.sub(keyword,"")
    str = str.gsub(/(RSVP|is|open|for|the|in|sizes|Rules|http:\/\/[0-9a-z\.\:\/]*)/im,"")
    retarr = Hash.new
    retarr['sizes'] = sizes
    retarr['keyword'] = keyword
    retarr['str'] = str
    return retarr
  rescue
    return false
  end
end


def form_bots_following_list

  bots =  $sql.query("SELECT * FROM twitter_accounts")
  bots.callback{|bots_obj|
    bots_obj.to_a.each{|bot|

      bot_to_process  = Twitter::Client.new(
      :consumer_key => bot['consumer_key'],
      :consumer_secret => bot['consumer_secret'],
      :oauth_token => bot['oauth_token'],
      :oauth_token_secret => bot['oauth_token_secret']
      )
      begin
        p "bots are"
        cursor = 0
        next_cursor = -1
        following = ""
        while cursor != next_cursor do
          cursor = next_cursor
          followings = bot_to_process.friend_ids({:cursor=>cursor})
          next_cursor =  followings.next_cursor
          p followings.ids
          following += followings.ids.join(";")
        end
        $sql.query("UPDATE twitter_accounts SET following = '#{following}' WHERE id = #{bot['id']}")
      rescue Exception => e
        p e
        p e.backtrace
      end

    }

  }

end



module CheckerHandler
  def post_init
    @data_received = ""
    @line_count = 0
  end
  def receive_data data
    allok = true
    @data_received << data
    send_data "HTTP/1.1 200 OK\r\nServer: Dvporg\r\nContent-type: text/html\r\n\r\n"
    $hash_with_cities.each{|city,bot|

      if bot.status != false
        send_data "#{city} is listned by #{bot.status}\r\n<br>"
      else
        send_data "#{city} IS NOT LISTENING!!!!\r\n<br>"
        allok = false
      end
    }
    send_data "ERROR!!!!!!\r\n<br>" if allok == false
    close_connection_after_writing
    # end
  end
end

EM.run do
  p "Application start to initialize"
  sqlconf = {
    :host => "localhost",
    :database => config[$env]['database'],
    :reconnect => true,  # make sure you have correct credentials
    :username => config[$env]['username'],
    :password => config[$env]['password'],
    :size => 30,
    :connections => 50
  }

  $sql = EmMysql2ConnectionPool.new(sqlconf)
  $sqlsync = Mysql2::Client.new(sqlconf)

  check_bots



  p "Database successfully initialized"
  p "Starting to form following lists for bots accounts..."
  form_bots_following_list()  #getting a list of followers for each bot to not to follow shop we are already following
  p "Lists were formed!"
  $hash_with_cities = Hash.new  #hash where to put each twitter acc for exact city
  p "Launching listiners for each city"
  process_cities_outside()


  p "Checker started"

  EM::PeriodicTimer.new(300) do
    check_bots
  end
  EM::PeriodicTimer.new(30) do
    process_cities_outside()
  end

  EM::PeriodicTimer.new(60) do

    http = EventMachine::HttpRequest.new('http://sneakergrab.com:8000/').get
    http.errback{|e|
      p e
      p "Working EM seems failed, restarting"
      $hash_with_cities = Hash.new()
      $timestamp = Time.now.to_i
      new_listeners()
    }
  end


end

