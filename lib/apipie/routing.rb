module Apipie
  module Routing
    module MapperExtensions
      def apipie(options = {}, route_options: {})
        namespace 'apipie', path: Apipie.configuration.doc_base_url do
          root 'apipies#versions'

          get 'apipie_checksum',
            to: "apipies#apipie_checksum",
            format: :json,
            as: :checksum,
            **options.merge(route_options[:checksum] || {})

          get '/:version/:resource/:method/:http_verb',
            to: 'apipies#http_verb',
            constraints: {
              version: /[^\/]+/,
              resource: /[^\/]+/,
              method: /[^\/]+/,
              http_verb: /[^\/]+/
            },
            as: :http_verb,
            **options.merge(route_options[:http_verb] || {})

          get '/:version/:resource/:method',
            to: 'apipies#method',
            constraints: { version: /[^\/]+/, resource: /[^\/]+/, method: /[^\/]+/ },
            as: :method,
            **options.merge(route_options[:method] || {})

          get '/:version/:resource',
            to: 'apipies#resource',
            constraints: { version: /[^\/]+/, resource: /[^\/]+/ },
            as: :resource,
            **options.merge(route_options[:resource] || {})

          get '/:version',
            to: 'apipies#index',
            constraints: { version: /[^\/]+/ },
            **options.merge(route_options[:version] || {})
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, Apipie::Routing::MapperExtensions
