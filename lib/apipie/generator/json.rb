module Apipie
  module Generator
    class Json
      def initialize(apipie)
        @apipie = apipie
      end

      def generate(version, resource_name, lang)
        url_args = Apipie.configuration.version_in_url ? version : ''

        resources = @apipie.
          resource_descriptions.
          generatable(version, resource_name)

        {
          :docs => {
            :name => Apipie.configuration.app_name,
            :info => Apipie.app_info(version, lang),
            :copyright => Apipie.configuration.copyright,
            :doc_url => Apipie.full_url(url_args),
            :api_url => Apipie.api_base_url(version),
            :resources => resources
          }
        }
      end
    end
  end
end
