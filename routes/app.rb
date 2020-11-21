require 'sinatra'
require 'pry'
require 'thin'
require_relative '../models/message_list'

module ApplicationHelper
  NOT_FOUND_MSG = "Message was not found, sorry! Please enter a valid sha of the message."
  INVALID_INPUT_MSG = "Invalid Message Input. Please provide a valid message in the POST body."
  INVALID_SHA_INPUT = "Invalid SHA input. Please enter a valid sha in the URL of the GET request."
  EMPTY_BODY = "You must provide a valid BODY."
  
  def handle_error(status, error_message)
    halt status, {"error": error_message}.to_json
  end
end

class App < Sinatra::Base
  helpers ApplicationHelper

  # This is a feature in Sinatra's DSL. I could've used a Ruby class variable here too (self.message_list)
  # I'll simply be using the settings object. Not great, but this is a work around data persistence and a global variable.
  set :message_list, MessageList.new
  set :exceptions, false
  set :server, "thin"

  get '/' do
    'Hello World! Use POST /messages or GET /messages to begin. See #README.md for more details.'
  end

  get '/all-messages' do 
    redirect to '/messages'
  end

  get '/messages' do
    settings.message_list.digest_list
  end

  # Returns the original message given the sha input in the url
  get '/messages/:sha' do
    sha = params['sha'] 
    handle_error(404, INVALID_SHA_INPUT) if sha.nil? || sha.empty?

    if settings.message_list.contains?(sha)
      settings.message_list.sha_lookup(sha)
    else
      handle_error(404, NOT_FOUND_MSG)
    end
  end

  post '/messages' do
    json_body = request.body.read
    handle_error(400, EMPTY_BODY) if json_body.empty?

    message = JSON.parse(json_body)['message']

    if message
      [201, settings.message_list.calculate_digest(message)]
    else
      handle_error(400, INVALID_INPUT_MSG)
    end
  end
end
