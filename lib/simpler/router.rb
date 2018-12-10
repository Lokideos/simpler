require_relative 'router/route'

module Simpler
  class Router
    COMPLEX_PATH = /^\/[a-z]+\/\w+/
    COMPLEX_ROUTE = /^\/[a-z]+\/:{1}\w+/
    PARAM_TYPE_REGEXP = /^\/\w+\/\w+/

    def initialize
      @routes = []
    end

    def get(path, route_point)
      add_route(:get, path, route_point)
    end

    def post(path, route_point)
      add_route(:post, path, route_point)
    end

    def route_for(env)
      method = env['REQUEST_METHOD'].downcase.to_sym
      path = get_path(env['PATH_INFO'])
      env['params_stash'] = {}
      get_params(env)

      @routes.find { |route| route.match?(method, path) }
    end

    private

    def get_params(env)
      path = env['PATH_INFO']

      while path.match?(PARAM_TYPE_REGEXP) do 
        params = path.match(PARAM_TYPE_REGEXP).to_s[1..-1].split("/")
        add_parameters_to_params_stash(params[0], params[1], env)
        path.gsub!(PARAM_TYPE_REGEXP, "")
      end
    end

    def add_parameters_to_params_stash(param_type, param, env)
      env['params_stash'][param_type[0..-2]] = param
    end

    def get_path(path)
      return path unless path.match?(COMPLEX_PATH)

      path_resources = path[1..-1].split("/")
      path_resources = path_resources.delete_if { |elem| path_resources.index(elem).odd? }
      complex_routes = @routes.select { |route| route.path =~ COMPLEX_ROUTE }

      complex_routes.each do |route|
        route_resources = route.path[1..-1].split("/")
        route_resources = route_resources.delete_if { |elem| route_resources.index(elem).odd? }

        return route.path if route_resources == path_resources
      end
    end

    def add_route(method, path, route_point)
      route_point = route_point.split('#')
      controller = controller_from_string(route_point[0])
      action = route_point[1]
      route = Route.new(method, path, controller, action)

      @routes.push(route)
    end

    def controller_from_string(controller_name)
      Object.const_get("#{controller_name.capitalize}Controller")
    end

  end
end
