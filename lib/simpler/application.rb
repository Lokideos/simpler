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
      controller = route.controller.new(env)
      action = route.action

      @application_logger.log_handler(controller, action)

      make_response(controller, action)

    rescue NoMethodError => e
        [
          404, 
          {"Content-Type" => "text/html"}, 
          ["Couldn't connect to the desired URL.\nMessage is the following:\n'#{e.message}'\n"]
        ]
    end

    private

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
