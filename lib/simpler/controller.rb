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
      setup_logger
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers
      set_params

      @application_logger.log_params(@request.params)
      send(action)
      set_status

      @application_logger.log_response(response)
      write_response

      @response.finish
    end

    private

    def setup_logger
      Dir["#{Simpler.root}/middleware/*.rb"].each { |file| require file }
      @application_logger = ApplicationLogger.new(nil, logdev: File.expand_path("#{Simpler.root}/log/app.log", __dir__))
    end

    def set_params
      params.merge!(@request.env['id_stash'])
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
