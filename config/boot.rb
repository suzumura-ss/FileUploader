ENV['RACK_ENV'] ||= 'development'

require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

Dir[File.expand_path('../../app/models/*.rb', __FILE__)].each{|f| require f }

module FileUploader
  class AppLogger < Rack::CommonLogger
    def initialize(app, logger)
      super
    end

    def call(env)
      env["app.logger"] = @logger
      super
    end
  end
end
$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
$LOAD_PATH.unshift(File.expand_path("../../app", __FILE__))
$LOAD_PATH.unshift(File.expand_path("../../app/apis", __FILE__))
require 'file_uploader_api'
require_relative 'environment'
