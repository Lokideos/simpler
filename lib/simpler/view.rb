require_relative 'view/html_renderer'
require_relative 'view/plain_text_renderer'
require 'erb'

module Simpler
  class View

    VIEW_BASE_PATH = 'app/views'.freeze

    RENDER_TYPES = {
      plain: "PlainTextRenderer",
      html: "HTMLRenderer",
      default: "HTMLRenderer"
    }.freeze

    def initialize(env)
      @env = env
    end

    def render(binding)
      return eval(RENDER_TYPES[render_type.downcase.to_sym]).new(@env, render_type_options).render if render_type

      eval(RENDER_TYPES[:default]).new(@env).render
    end

    private

    def render_type
      @env['simpler.render_type']
    end

    def render_type_options
      @env['simpler.render_type_options'] if render_type
    end

  end
end
