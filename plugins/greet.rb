# encoding: utf-8

require "cinch"

class Greet

  include Cinch::Plugin

  GREETING      = ["Hola", "Hey", "I'm back", "Regresé", "I'm here"]

  CONNECTOR     = [".", "..", "...", "!", "!!"]

  CUTENESS      = [":)", ";)", ":]", ":D", "n.n"]

  SEPARATOR     = [" ", "\n"]

  INTRODUCTION  = ["Cómo están?", "Cómo andán?", "Alguien aquí?", "Anybody is here?", "How are you doing?"]

  TEMPLATES = [
    "{greeting}{connector} {cuteness}{separator}{introduction}",
    "{greeting}{connector}{separator}{introduction} {cuteness}",
    "{greeting}{connector}{separator}{introduction}",
    "{greeting}{connector} {introduction} {cuteness}",
    "{greeting}{separator}{introduction} {cuteness}",
    "{greeting} {cuteness}{separator}{introduction}",
    "{greeting}{connector} {cuteness}{separator}",
    "{greeting}{separator}{introduction}",
    "{greeting}{connector}{separator}",
    "{greeting}{connector} {cuteness}",
    "{greeting} {cuteness}{separator}",
    "{introduction} {cuteness}",
    "{greeting}{connector}",
    "{greeting}{separator}",
    "{greeting} {cuteness}",
    "{introduction}",
    "{greeting}",
    "{cuteness}"
  ]

  listen_to :advertise, method: :greet

  def greet(msg)
    template = TEMPLATES.sample
    template.gsub!("{greeting}", GREETING.sample)
    template.gsub!("{connector}", CONNECTOR.sample)
    template.gsub!("{cuteness}", CUTENESS.sample)
    template.gsub!("{separator}", SEPARATOR.sample)
    template.gsub!("{introduction}", INTRODUCTION.sample)
    msg.reply template
  end

end