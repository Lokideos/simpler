require_relative 'router/route'

module Simpler
  class Router

    ID_REGEXP = /\/[0-9]+/
    ID_TYPE_REGEXP = /^\/[a-z]+\/[0-9]+/

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
      env['id_stash'] = {}
      get_ids(env)

      @routes.find { |route| route.match?(method, path) }
    end

    private

    def get_ids(env)
      path = env['PATH_INFO']

      while path.match?(ID_TYPE_REGEXP) do 
        ids = path.match(ID_TYPE_REGEXP).to_s[1..-1].split("/")
        add_id_to_id_stash(ids[0], ids[1], env)
        path.gsub!(ID_TYPE_REGEXP, "")
      end
    end

    def add_id_to_id_stash(id_type, id, env)
      env['id_stash'][id_type[0..-2] + "_id"] = id
    end

    def get_path(path)
      return path unless path.match?(ID_REGEXP)

      id_path = path.gsub(ID_REGEXP, '/:id')
      id_path
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
