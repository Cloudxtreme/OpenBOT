# encoding: utf-8

require "cinch"

class Receptionist

  include Cinch::Plugin

  GREETING      = ["Hola", "Hey", "{nick}", "Hola {nick}", "Hey {nick}", "{nick}, hello", "{nick}, hey", "{nick}, welcome", "Bienvenido, {nick}", "{nick}"]

  CONNECTOR     = [".", "..", "...", "!", "!!"]

  CUTENESS      = [":)", ";)", ":]", ":D", "n.n"]

  SEPARATOR     = [" ", "\n"]

  INTRODUCTION  = ["Cómo estás?", "How are you?", "are you ok?", "Cómo va todo?", "Andás bien?"]

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

  listen_to :receive, method: :receptionist

  def receptionist(msg)
    template = TEMPLATES.sample
    template.gsub!("{greeting}", GREETING.sample)
    template.gsub!("{connector}", CONNECTOR.sample)
    template.gsub!("{cuteness}", CUTENESS.sample)
    template.gsub!("{separator}", SEPARATOR.sample)
    template.gsub!("{introduction}", INTRODUCTION.sample)
    template.gsub!("{nick}", msg.user.nick)
    msg.reply template
  end

end