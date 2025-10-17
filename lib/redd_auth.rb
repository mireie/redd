# frozen_string_literal: true

require 'openssl'

# Disable SSL certificate verification for development
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:verify_mode] = OpenSSL::SSL::VERIFY_NONE

require_relative '../lib/redd'
require_relative 'redd/web_auth_server'

# ReddAuth provides methods for authenticating a Reddit session either from an existing token file
# or through an interactive web authentication flow.
module ReddAuth
  class << self
    def authenticate_or_exit
      redd_file_path = File.join(Dir.home, '.redd.key')

      if File.exist?(redd_file_path)
        authenticate_from_file(redd_file_path)
      else
        puts "No authentication file found at #{redd_file_path}"
        puts "Please run 'bin/console' first to authenticate."
        exit 1
      end
    end

    def authenticate_interactive
      redd_file_path = File.join(Dir.home, '.redd.key')

      if File.exist?(redd_file_path)
        authenticate_from_file(redd_file_path)
      else
        start_web_server_for_auth(redd_file_path)
      end
    end

    private

    def authenticate_from_file(redd_file_path)
      auth = Redd::AuthStrategies::Web.new(
        client_id: 'P4txR-D6TzF8cg',
        redirect_uri: 'http://localhost:8000/redirect'
      )
      access = Redd::Models::Access.new(refresh_token: File.read(redd_file_path))
      client = Redd::APIClient.new(
        auth,
        user_agent: "Ruby:Redd-Quickstart:v#{Redd::VERSION} (by /u/Mustermind)"
      )
      client.access = auth.refresh(access)
      Redd::Models::Session.new(client)
    end

    def start_web_server_for_auth(redd_file_path)
      Redd::WebAuthServer.new(redd_file_path).start
    end
  end
end
