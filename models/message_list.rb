require 'json'
require 'digest'
require 'pry'

class MessageList
  def initialize
    # Use a hash data structure to hold sha : messages
    @messages = {}
  end

  def digest_list
    message_list = { "digestList": @messages.keys }
    message_list.to_json
  end

  def contains?(key)
    @messages.key?(key)
  end

  def sha_lookup(key)
    {"message": @messages[key]}.to_json
  end

  def calculate_digest(message)
    message_to_sha = Digest::SHA256.hexdigest(message)
  
    @messages[message_to_sha] = message
    { "digest": message_to_sha }.to_json
  end
end