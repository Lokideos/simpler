require 'yaml'
require 'singleton'
require 'sequel'
require_relative 'router'
require_relative 'controller'

module Simpler
  class Application

    include Singleton

    attr_reader :db

    def initialize
      @router = Router.new
      @db = nil
    end

    def bootstrap!
      setup_database
      require_app
      require_routes
      setup_logger
    end

    def routes(&block)
      @router.instance_eval(&block)
    end

    def call(env)
      route = @router.route_for(env)

      return route_does_not_exist(env['PATH_INFO'][1..-2]) unless route

      controller = route.controller.new(env)
      action = route.action

      @application_logger.log_handler(controller, action)

      make_response(controller, action)
    end

    private

    def route_does_not_exist(resource_name)
      [
        404, 
        {"Content-Type" => "text/html"}, 
        ["Couldn't connect to the desired URL.\nResource '#{resource_name.upcase}' doesn't exist\n"]
      ]
    end

    def setup_logger
      Dir["#{Simpler.root}/middleware/*.rb"].each { |file| require file }
      @application_logger = ApplicationLogger.new(nil, logdev: File.expand_path("#{Simpler.root}/log/app.log", __dir__))
    end

    def require_app
      Dir["#{Simpler.root}/app/**/*.rb"].each { |file| require file }
    end

    def require_routes
      require Simpler.root.join('config/routes')
    end

    def setup_database
      database_config = YAML.load_file(Simpler.root.join('config/database.yml'))
      database_config['database'] = Simpler.root.join(database_config['database'])
      @db = Sequel.connect(database_config)
    end

    def make_response(controller, action)
      controller.make_response(action)
    end

  end
end
