# encoding: utf-8

require "rbconfig"

# General

RbConfig::CONFIG["log"]      = :info # :debug, :log, :info, :warn, :error and :fatal
RbConfig::CONFIG["delay"]    = 10000 # Max delay to respond

# Server

RbConfig::CONFIG["server"]   = "irc.freenode.org"
RbConfig::CONFIG["port"]     = 6667

# Channels

RbConfig::CONFIG["channels"] = ["#fing", "#openfing"]

# Username

RbConfig::CONFIG["names"]    = ["OpenBOT"]
RbConfig::CONFIG["nicks"]    = ["Wixy", "Trixy", "Pixy"]
RbConfig::CONFIG["password"] = ""

# Plugins

RbConfig::CONFIG["receive_prob"]    = 0.5

RbConfig::CONFIG["greet_prob"]      = 1

RbConfig::CONFIG["implicit_prob"]   = 0.7

RbConfig::CONFIG["random_prob"]     = 0.7
RbConfig::CONFIG["random_interval"] = 600000

require "./plugins/receptionist.rb"
require "./plugins/greet.rb"
require "./plugins/socialize.rb"
require "./plugins/ping.rb"

RbConfig::CONFIG["plugins"]         = [Receptionist, Greet, Socialize, Ping]