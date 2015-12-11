#!/usr/bin/env rackup
require File.expand_path("../config/boot", __FILE__)

require "active_support"
logger = ActiveSupport::Logger.new("log/#{ENV["RACK_ENV"]}.log", "daily")
logger.level = ENV["RACK_ENV"] == "production" ? Logger::INFO : Logger::DEBUG
use FileUploader::AppLogger, logger

ActiveRecord::Base.logger = logger
ActiveRecord::Base.schema_format = :sql
use ActiveRecord::ConnectionAdapters::ConnectionManagement
run FileUploader::API
