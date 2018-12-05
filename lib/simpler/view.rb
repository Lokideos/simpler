require 'erb'

module Simpler
  class View

    VIEW_BASE_PATH = 'app/views'.freeze

    def initialize(env)
      @env = env
    end

    def render(binding)
      setup_logger

      if render_type
        @application_logger.log_response_body(render_type_options)
        return send render_type.downcase.to_sym, render_type_options 
      end

      template = File.read(template_path)

      ERB.new(template).result(binding)
    end

    private

    def setup_logger
      Dir["#{Simpler.root}/middleware/*.rb"].each { |file| require file }
      @application_logger = ApplicationLogger.new(nil, logdev: File.expand_path("#{Simpler.root}/log/app.log", __dir__))
    end

    def controller
      @env['simpler.controller']
    end

    def action
      @env['simpler.action']
    end

    def template
      @env['simpler.template']
    end

    def render_type
      @env ['simpler.render_type']
    end

    def render_type_options
      @env ['simpler.render_type_options'] if render_type
    end

    def template_path
      path = template || [controller.name, action].join('/')
      @application_logger.log_response_body(path + ".html.erb")

      Simpler.root.join(VIEW_BASE_PATH, "#{path}.html.erb")
    end

    def plain(text)
      text
    end

  end
end
