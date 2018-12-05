require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers
      send(action)
      set_status
      write_response
      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.params
    end

    def render(*options)
      if options.first.class.to_s == "String"
        @request.env['simpler.template'] = options.first
      elsif options.first.keys.first.class.to_s == "Symbol"
        @request.env['simpler.render_type'] = options.first.keys.first
        @request.env['simpler.render_type_options'] = options.first.values.first
      end
    end

    def set_status
      @response.status = @request.env['simpler.status_code'] || 200
    end

    def status(status_code)
      @request.env['simpler.status_code'] = status_code
    end

  end
end
