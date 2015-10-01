require "codic_caller/version"
require 'faraday'
require 'faraday_middleware'
require 'json'

module CodicCaller
  class Codic
    HOST = 'https://api.codic.jp'

    def initialize
      @token = ENV['CODIC']
    end

    def translate(text, casing: 'lower underscore')
      JSON.load(
        client.get {|req|
          req.url '/v1/engine/translate.json'
          req.params[:project_id] = project_id
          req.params[:casing] = casing
          req.params[:text] = text
          req.headers['Authorization'] = "Bearer #{@token}"
        }.body
      ).first['translated_text']
    end

    def project_id
      JSON.load(
        client.get {|req|
          req.url '/v1/user_projects.json'
          req.headers['Authorization'] = "Bearer #{@token}"
        }.body
      ).first['id']
    end

    private

    def client
      @client ||= Faraday.new(url: HOST) do |faraday|
        faraday.request :json
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
