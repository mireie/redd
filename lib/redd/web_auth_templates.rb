# frozen_string_literal: true

module Redd
  # WebAuthTemplates provides HTML templates for the web authentication flow
  module WebAuthTemplates
    def self.home_page_html
      <<-HTML
        <!doctype html>
        <title>Redd Quickstart</title>
        <style>
          html, body { margin: 0; height: 100vh; }
          .wrapper { padding-top: 30vh; text-align: center; font-family: sans-serif; }
          #btn { background-color: #3D9970; margin: 5px; border-radius: 5px; padding: 10px; color: #fff; text-decoration: none; }
        </style>
        <div class="wrapper">
          <h1>redd // quickstart</h1>
          <a href="/authenticate" target="_blank" id="btn">Start</a>
          <span>a new session in your terminal?</span>
        </div>
      HTML
    end

    def self.redirect_page_html(should_exit, err)
      <<-HTML
        <!doctype html>
        <title>Done!</title>
        #{should_exit ? '<script>window.close();</script>' : "<p>Uh oh, there was an error: #{err}</p>"}
      HTML
    end
  end
end
