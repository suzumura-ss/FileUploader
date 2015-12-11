require_relative 'files_api'
require 'logic/logic'

module FileUploader
  class AuthorizationRequired < ArgumentError; end
  class TooMenyRequests < RuntimeError; end
  class ResourceNotFound < RuntimeError; end

  class API < Grape::API
    format :json
    default_format :json

    helpers do
      def logger
        env['app.logger'] #API.logger
      end
    end

    rescue_from AuthorizationRequired do |e|
      error!({reason: "401 Unauthorized"}, 401)
    end

    rescue_from TooMenyRequests do |e|
      error!({reason: "429 Too Many Requests"}, 429)
    end

    rescue_from ActiveRecord::RecordNotFound, ResourceNotFound do |e|
      error_response(message: "404 Not Found", status: 404)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      rack_response({ error: "400 Bad Request", message: e.message }, 400)
    end

    rescue_from Grape::Exceptions::ValidationErrors, Grape::Exceptions::InvalidMessageBody do |e|
      rack_response({ error: "400 Bad Request", message: e.message }, 400)
    end

    rescue_from :all do |e|
      unless ENV["RACK_ENV"] == "production"
        raise e
      else
        error_response(message: "500 Internal Server Error", status: 500)
      end
    end

    get '/' do
      {state:'alive'}
    end

    # require_relative 'resources_api'
    mount FilesAPI
  end
end
