require 'logger'

class ApplicationLogger
  def initialize(app, **options)
    @logger = Logger.new(options[:logdev] || STDOUT)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)    
    @logger.info(format_message(env))
    [status, headers, body]
  end

  def format_message(env)
    @logger.info("\nRequest: #{env['REQUEST_METHOD']} " +
                 "#{env["simpler.controller"].request.env['REQUEST_PATH']}\n" +
                 "Handler: #{env['simpler.controller'].class}##{env['simpler.action']}\n" +
                 "Parameters: #{env["simpler.controller"].request.params}\n" +
                 "Response: #{env["simpler.controller"].response.status} " +
                 "[#{env["simpler.controller"].response.header['Content-Type']}] " +
                 "#{env['simpler.template_path']}")
  end

  def log_handler(handler, action)
    @logger.info("Handler: #{handler.class}##{action}")
  end

  def log_params(params)
    @logger.info("Parameters: #{params}")
  end

  def log_response(response)
    @logger.info("Response: status #{response.status} " +
                           "response-type #{response.header["Content-Type"]} ")
  end

  def log_response_body(body)
    @logger.info("Response: response-body #{body}")
  end
end
