#!/usr/bin/env ruby

require 'yaml'
require 'instapaper'
require 'highline'
require 'pp'

unless File.exist?('.secrets.yml')
  $stderr.puts 'Create a .secrets.yml config file with your Instapaper API credentials'
  exit
end

config = YAML.load_file('.secrets.yml')
cli = HighLine.new
client = nil
update_config = false

if config.has_key?(:consumer_key) && config.has_key?(:consumer_secret)
  client = Instapaper::Client.new do |client|
    client.consumer_key = config[:consumer_key]
    client.consumer_secret = config[:consumer_secret]
  end
  unless (config.has_key?(:oauth_token) && config.has_key?(:oauth_token_secret))
    $stderr.puts "Setting OAuth tokens using Instapaper login"
    username = cli.ask("Username: ")
    password = cli.ask("Password: ") { |q| q.echo = "x" }
    client = Instapaper::Client.new do |client|
      client.consumer_key = config[:consumer_key]
      client.consumer_secret = config[:consumer_secret]
    end
    token = client.access_token(username, password)
    config[:oauth_token] = token.oauth_token
    config[:oauth_token_secret] = token.oauth_token_secret
    update_config = true
  end
  client.oauth_token = config[:oauth_token]
  client.oauth_token_secret = config[:oauth_token_secret]
  client.verify_credentials

  if update_config
    File.open('.secrets.yml','w') do |f|
      f.write(config.to_yaml)
    end
    $stderr.puts "Config updated with OAuth tokens"
  end
else
  $stderr.puts "Instapaper API consumer key & secret not set, exiting!"
  exit
end

client.bookmarks(:limit => config[:bookmarks_limit]).each do |bookmark|
  if bookmark.url =~ /^https?:\/\/t\.co\//
    $stderr.puts bookmark.url
    real_url = `curl -s -L -I '#{bookmark.url}' | grep -i '^Location:' | tail -1 | cut -d' ' -f2`
    unless real_url.nil? || real_url.empty?
      $stderr.puts "Adding: #{real_url}"
      client.add_bookmark(real_url)
      $stderr.puts "Deleting: #{bookmark.url}"
      client.delete_bookmark(bookmark.bookmark_id)
    end
    $stderr.puts
  end
end
