# encoding: utf-8

require "cinch"
require "curb"
require "nokogiri"
require "sanitize"

require "./config.rb"

class Socialize

  include Cinch::Plugin

  DEFAULT_MESSAGE = "uh?"

  KNOWDLEGE = {
    names:        RbConfig::CONFIG["nicks"] + RbConfig::CONFIG["names"],
    facebook:     ["http://facebook.com/openfing", "http://www.facebook.com/openfing", "facebook.com/openfing", "www.facebook.com/openfing"],
    email:        ["open@fing.edu.uy"],
    address:      ["Julio Herrera y Reissig 565"],
    postcode:     ["11300"],
    city:         ["Montevideo", "Montevideo, Uruguay"],
    organization: ["OpenFING"],
    ip:           ["localhost", "127.0.0.1", "::1"],
    telephone:    ["doesn't have telephone number, try sending us an e-mail"]
  }

  PATTERNS = {
    /\(?\d{1,}\.\d{1,}\.\d{1,}\.\d{1,}\)?/        => KNOWDLEGE[:ip],
    /https:\/\/www.facebook.com\/elbot.the.robot/ => KNOWDLEGE[:facebook],
    /elbot@elbot.artificial-solutions.com/        => KNOWDLEGE[:email],
    /Poststrasse 33/i                             => KNOWDLEGE[:address],
    /20354/                                       => KNOWDLEGE[:postcode],
    /(Hamburg, Germany|Hamburg|Germany)/i         => KNOWDLEGE[:city],
    /Artificial Solutions( Germany AG)?/i         => KNOWDLEGE[:organization],
    /has all sorts of telephone numbers.*/        => KNOWDLEGE[:telephone],
    /elbot/i                                      => KNOWDLEGE[:names]
  }

  URL_START        = "http://elbot_e.csoica.artificial-solutions.com/cgi-bin/elbot.cgi?START=normal"
  URL_CONVERSATION = "http://elbot_e.csoica.artificial-solutions.com/cgi-bin/elbot.cgi"
  URL_REFERER      = "http://www.elbot.com/"
  USER_AGENT       = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1"

  CONVERSATION_TIMEOUT = 90

  def initialize(*args)
    super
    @users = {}
  end

  listen_to :interact, method: :interact
  listen_to :read, method: :read

  def interact(msg)
    start msg.user.nick

    response = put msg.user.nick, msg.message
    PATTERNS.each do |pattern, replacement|
      @users[msg.user.nick][:last] = Time.now
      response.gsub! pattern, replacement.sample
    end

    if Random.rand < 0.5
      response = response[0].downcase + response[1..-1] unless response[0] == "I"
      if Random.rand < 0.5
        msg.reply "#{msg.user.nick}, #{response}"
      else
        msg.reply "#{msg.user.nick}: #{response}"
      end
    else
      msg.reply response
    end
  end

  def read(msg)
    start msg.user.nick
    timeout = (@users[msg.user.nick][:last]) ? Time.now - @users[msg.user.nick][:last] > CONVERSATION_TIMEOUT : false
    if not timeout and msg.message !~ /^\w+[,:.]/ and Random.rand < RbConfig::CONFIG["implicit_prob"]
      interact(msg)
    else
      put msg.user.nick, msg.message
    end
  end

  def start(nick)
    unless @users[nick]
      @users[nick] = {curl: Curl::Easy.new}
      response = send nick, URL_START
    end
  end

  def put(nick, message)
    response = send nick, URL_CONVERSATION, message
    response = response.match /<!-- Begin Response !--> (.*)? <!-- End Response !-->/
    response = Sanitize.clean((response[1] || DEFAULT_MESSAGE).force_encoding("utf-8"), remove_contents: false).strip
  end

  def send(nick, url, message="")
    params = []

    if @users[nick][:ident] or @users[nick][:userlogid] or @users[nick][:extrainput]
      params.push Curl::PostField.content("IDENT", @users[nick][:ident])
      params.push Curl::PostField.content("USERLOGID", @users[nick][:userlogid])
      params.push Curl::PostField.content("EXTRAINPUT", @users[nick][:extrainput])
    end

    unless message.empty?
      message.gsub! /(#{(RbConfig::CONFIG["nicks"]+RbConfig::CONFIG["names"]).join "|"})/i, "Elbot"
      params.push Curl::PostField.content("ENTRY", message)
    end

    @users[nick][:curl].enable_cookies = true
    @users[nick][:curl].follow_location = true
    @users[nick][:curl].url = url
    @users[nick][:curl].headers = {"Referer" => URL_REFERER, "User-Agent" => USER_AGENT}

    if params.empty?
      @users[nick][:curl].get
    else
      @users[nick][:curl].post params
    end

    response = @users[nick][:curl].body_str

    @users[nick][:ident]      = response.match(/name="IDENT" value="(.*?)"/)[1]
    @users[nick][:userlogid]  = response.match(/name="USERLOGID" value="(.*?)"/)[1]
    @users[nick][:extrainput] = response.match(/name="EXTRAINPUT" value="(.*?)"/)[1]

    response
  end

end