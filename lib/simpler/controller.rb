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
      get_params

      send(action)

      write_response

      @response.finish
    end

    private

    def get_params
      params.merge!(@request.env['params_stash'])
    end

    def set_custom_headers(headers)
      headers.each do |header|
        @response[header.first] = header.last
      end
    end

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
        @response['Content-Type'] = 'html'
      elsif options.first.keys.first.class.to_s == "Symbol"
        @request.env['simpler.render_type'] = options.first.keys.first
        @request.env['simpler.render_type_options'] = options.first.values.first
        @response['Content-Type'] = 'text'
      end
    end

    def status(status_code)
      @response.status = status_code
    end

  end
end
