require 'erb'

module Simpler
  class View

    VIEW_BASE_PATH = 'app/views'.freeze

    def initialize(env)
      @env = env
    end

    def render(binding)
      return send render_type.downcase.to_sym, render_type_options if render_type

      template = File.read(template_path)

      ERB.new(template).result(binding)
    end

    private

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
      @env['simpler.render_type']
    end

    def render_type_options
      @env['simpler.render_type_options'] if render_type
    end

    def template_path
      path = template || [controller.name, action].join('/')
      @env['simpler.template_path'] = "#{path}.html.erb"

      Simpler.root.join(VIEW_BASE_PATH, "#{path}.html.erb")
    end

    def plain(text)
      text
    end

  end
end
