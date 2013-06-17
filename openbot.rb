# encoding: utf-8

require "cinch"
require "thread"

require "./config.rb"

Thread.abort_on_exception = true

def delay
  sleep RbConfig::CONFIG["delay"] * Random.rand / 1000
end

@bot = Cinch::Bot.new do

  on :connect do |msg|
    # Connected to server
  end

  on :join do |msg|
    # Joined
    delay
    if msg.user.nick != @bot.nick
      @bot.handlers.dispatch(:receive, msg) if Random.rand < RbConfig::CONFIG["receive_prob"]
    else
      @bot.handlers.dispatch(:advertise, msg) if Random.rand < RbConfig::CONFIG["greet_prob"]
    end
  end

  on :part do |msg|
    # Leaving
  end

  on :channel do |msg|
    # Public message
    @bot.handlers.dispatch(:activity, msg)
    delay
    if msg.message =~ /(^|\W)(#{@bot.nick}|#{RbConfig::CONFIG["names"].join "|"})(\W|$)/i
      @bot.handlers.dispatch(:interact, msg)
    else
      @bot.handlers.dispatch(:read, msg)
    end
  end

  on :private do |msg|
    # Private message
    if msg.user and msg.user.nick != @bot.nick and msg.user.nick != "NickServ"
      delay
      @bot.handlers.dispatch(:interact, msg)
    end
  end

  on :leaving do |msg, user|
    # User leaving
  end

  configure do |c|
    c.server          = RbConfig::CONFIG["server"]
    c.port            = RbConfig::CONFIG["port"]
    c.channels        = RbConfig::CONFIG["channels"]
    c.realname        = RbConfig::CONFIG["names"].sample
    c.nicks           = RbConfig::CONFIG["nicks"]
    c.password        = RbConfig::CONFIG["password"]
    c.plugins.plugins = RbConfig::CONFIG["plugins"]
    c.encoding        = "utf-8"
  end

end

@bot.loggers.level = RbConfig::CONFIG["log"]
@bot.start