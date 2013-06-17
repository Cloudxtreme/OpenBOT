# encoding: utf-8

require "cinch"

class Ping

  include Cinch::Plugin

  SEEDS = [
    "Alguien por acá?",
    "I'm bored!",
    "No puedo dormir..",
    "Tengo hambre :|",
    "Haha..",
    "Jaja!!",
    "Oh! Vieron las noticias!?",
    "Estoy aburrido :/",
    "Alguien con quien hablar?",
    "Hey! What's up?",
    "I can't believe what time it is! I'm off..",
    "I'm cooking.. :)",
    "To be or not to be..",
    "No me puedo dormir...\nIs anybody here?",
    "I can't believe that -.-",
    "Me voy...",
    "Todo está tan en silencio -.-",
    "Estoy escuchando música :)",
    "Cof cof..\nAnybody around?",
    "I'm back\nhola :)"
  ]

  listen_to :activity, method: :update
  timer RbConfig::CONFIG["random_interval"]/1000, method: :ping

  def initialize(*args)
    super
    @last = {}
  end

  def update(msg)
    @last[msg.channel] = Time.now
  end

  def ping
    RbConfig::CONFIG["channels"].each do |channel|
      if not @last[channel] or Time.now - @last[channel] > RbConfig::CONFIG["random_interval"] / 1000
        Channel(channel).send SEEDS.sample if Random.rand < RbConfig::CONFIG["random_prob"]
      end
    end
  end

end