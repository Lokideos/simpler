require 'logger'

class ApplicationLogger
  def initialize(app, **options)
    @logger = Logger.new(options[:logdev] || STDOUT)
    @app = app
  end

  def call(env)
    compile_information(env)
    @app.call(env)
  end

  def compile_information(env)
    @logger.info("Request: #{env["REQUEST_METHOD"]} #{env["PATH_INFO"]}")
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
