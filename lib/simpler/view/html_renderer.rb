require 'erb'

module Simpler
  class View
    class HTMLRenderer

      def initialize(env, *options)
        @env = env
      end

      def render
        template = File.read(template_path)

        ERB.new(template).result(binding)
      end

      def template_path
        path = template || [controller.name, action].join('/')
        @env['simpler.template_path'] = "#{path}.html.erb"

        Simpler.root.join(Simpler::View::VIEW_BASE_PATH, "#{path}.html.erb")
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

    end
  end
end

