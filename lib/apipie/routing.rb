module Apipie
  module Routing
    module MapperExtensions
      def apipie(options = {})
        namespace "apipie", path: Apipie.configuration.doc_base_url do
          get 'apipie_checksum', to: "apipies#apipie_checksum", format: "json"

          get '/:version/:resource/:method/:http_verb',
              to: 'apipies#http_verb',
              constraints: {
                version: /[^\/]+/,
                resource: /[^\/]+/,
                method: /[^\/]+/,
                http_verb: /[^\/]+/
              },
              as: :http_verb

          get '/:version/:resource/:method',
              to: 'apipies#method',
              constraints: { version: /[^\/]+/, resource: /[^\/]+/, method: /[^\/]+/ },
              as: :method

          get '/:version/:resource',
              to: 'apipies#resource',
              constraints: { version: /[^\/]+/, resource: /[^\/]+/ },
              as: :resource

          get '/:version', to: 'apipies#index', constraints: { version: /[^\/]+/ }

          # constraints(:version => /[^\/]+/, :resource => /[^\/]+/, :method => /[^\/]+/) do
          #   get options.reverse_merge("(:version)/(:resource)/(:method)" => "apipies#index", :as => :apipie)
          # end
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, Apipie::Routing::MapperExtensions
