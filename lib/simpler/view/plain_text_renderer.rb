module Simpler
  class View
    class PlainTextRenderer
      def initialize(env, text)
        @env = env
        @text = text
      end

      def render
        template_path

        render_text
      end

      def render_text
        @text
      end

      def template_path
        @env['simpler.template_path'] = "no template"
      end
    end
  end
end