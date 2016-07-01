require "jumpstart_auth"


class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing Microblogger"
    @client = JumpstartAuth.twitter
  end

  def run
    puts "Welcome to the JSL Twitter Client"
    command = ""
    while command != "q"
      printf "Enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when 'q' then puts "Goodbye"
        when 't' then tweet(parts[1..-1].join(" "))
        when 'dm' then dm(parts[1],parts[2..-1].join(" "))
        when "spam" then spam_my_followers(parts[1..-1].join(" "))
        when 'elt' then everyones_last_tweet
        else
          puts "Sorry, I don't know how to #{command}"
      end
    end
  end

  def followers_list
    followers = @client.followers.collect {|follower| @client.user(follower).screen_name}
    return followers
  end

  def tweet(message)
    if message.length > 140
      print "This message exceeds the 140 characters limit."
    else
      @client.update(message)
    end
  end

  def dm(target,message)
    puts "Trying to send #{target} this direct message:"
    puts message
    screen_names = followers_list
    if screen_names.include?(target)
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "You can only send direct messages to your followers"
    end
  end

  def spam_my_followers(message)
    followers = followers_list
    followers.each do |follower|
      dm(follower,message)
    end
  end

  def everyones_last_tweet
    friends = @client.friends.collect {|f| @client.user(f).screen_name}
    friends.each do |friend|
      last_message = @client.user_timeline(friend,count: 1)
      puts "#{friend} said..."
      last_message.each {|tweet| puts tweet.full_text}
    end
  end
end

blogger = MicroBlogger.new
blogger.run
