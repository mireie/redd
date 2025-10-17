# frozen_string_literal: true

require 'webrick'
require_relative 'web_auth_templates'

module Redd
  # WebAuthServer handles the web server setup for Reddit authentication
  class WebAuthServer
    def initialize(redd_file_path)
      @redd_file_path = redd_file_path
    end

    def start
      server = create_web_server
      setup_server_routes(server)
      start_server(server)
    end

    private

    def create_web_server
      WEBrick::HTTPServer.new(
        Port: 8000,
        BindAddress: '0.0.0.0',
        Logger: WEBrick::Log.new(File.open(File::NULL, 'w')),
        AccessLog: []
      )
    end

    def setup_server_routes(server)
      setup_home_route(server)
      setup_authenticate_route(server)
      setup_redirect_route(server)
    end

    def setup_home_route(server)
      server.mount_proc '/' do |_, res|
        res.body = WebAuthTemplates.home_page_html
      end
    end

    def setup_authenticate_route(server)
      server.mount_proc '/authenticate' do |_, res|
        res.set_redirect(
          WEBrick::HTTPStatus[302],
          Redd.url(
            client_id: 'P4txR-D6TzF8cg',
            response_type: 'code',
            state: '0',
            redirect_uri: 'http://localhost:8000/redirect',
            duration: 'permanent',
            scope: %w[
              account creddits edit flair history identity livemanage modconfig modcontributors
              modflair modlog modmail modothers modposts modself modwiki mysubreddits
              privatemessages read report save submit subscribe vote wikiedit wikiread
            ]
          )
        )
      end
    end

    def setup_redirect_route(server)
      server.mount_proc '/redirect' do |req, res|
        handle_redirect_request(req, res, server)
      end
    end

    def handle_redirect_request(req, res, server)
      err = req.query['error']
      should_exit = err.nil? || err == 'access_denied'
      res.body = WebAuthTemplates.redirect_page_html(should_exit, err)

      return if err

      server.stop
      session = create_reddit_session(req.query['code'])
      save_refresh_token(session)
      session
    end

    def start_server(server)
      puts "Listening at \e[34mhttp://localhost:8000\e[0m..."
      server.start
    rescue Interrupt
      server.shutdown
      exit
    end

    def create_reddit_session(code)
      Redd.it(
        user_agent: "Ruby:Redd-Quickstart:v#{Redd::VERSION} (by /u/Mustermind)",
        client_id: 'P4txR-D6TzF8cg',
        redirect_uri: 'http://localhost:8000/redirect',
        code: code,
        auto_refresh: true
      )
    end

    def save_refresh_token(session)
      File.open(@redd_file_path, 'w') do |f|
        f.write(session.client.access.refresh_token)
      end
    end
  end
end
