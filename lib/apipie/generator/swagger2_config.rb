require 'singleton'

module Apipie
  module Generator
    class Swagger2Config
      include Singleton

      CONFIG_ATTRIBUTES = [:include_warning_tags, :content_type_input,
        :json_input_uses_refs, :suppress_warnings, :api_host,
        :generate_x_computed_id_field, :allow_additional_properties_in_response,
        :responses_use_refs, :schemes, :security_definitions, :global_security]

      attr_accessor *CONFIG_ATTRIBUTES

      CONFIG_ATTRIBUTES.each do |attribute|
        old_setter_method = "swagger_#{attribute}="
        define_method(old_setter_method) do |value|
          ActiveSupport::Deprecation.warn(
            <<~HEREDOC
              #{old_setter_method}#{value} is deprecated. 
              Use `Apipie.configuration.swagger2.#{attribute} instead.
            HEREDOC
          )

          self.send("#{attribute}=", value)
        end

        define_method("swagger_#{attribute}") do
          ActiveSupport::Deprecation.warn(
            <<~HEREDOC
              #{old_setter_method} is deprecated.
              Use `Apipie.configuration.swagger2.#{attribute} instead.
            HEREDOC
          )

          self.send(attribute)
        end
      end

      alias_method :include_warning_tags?, :include_warning_tags
      alias_method :json_input_uses_refs?, :json_input_uses_refs
      alias_method :responses_use_refs?, :responses_use_refs
      alias_method :generate_x_computed_id_field?, :generate_x_computed_id_field
      alias_method :swagger_include_warning_tags?, :swagger_include_warning_tags
      alias_method :swagger_json_input_uses_refs?, :swagger_json_input_uses_refs
      alias_method :swagger_responses_use_refs?, :swagger_responses_use_refs
      alias_method :swagger_generate_x_computed_id_field?, :swagger_generate_x_computed_id_field

      def initialize
        @content_type_input = :form_data # this can be :json or :form_data
        @json_input_uses_refs = false
        @include_warning_tags = false
        @suppress_warnings = false #[105,100,102]
        @api_host = "localhost:3000"
        @generate_x_computed_id_field = false
        @allow_additional_properties_in_response = false
        @responses_use_refs = true
        @schemes = [:https]
        @security_definitions = {}
        @global_security = []
      end

      def to_hash
        {
          content_type_input: @content_type_input,
          json_input_uses_refs: @json_input_uses_refs,
          include_warning_tags: @include_warning_tags,
          suppress_warnings: @suppress_warnings,
          api_host: @api_host,
          generate_x_computed_id_field: @generate_x_computed_id_field,
          allow_additional_properties_in_response: @allow_additional_properties_in_response,
          responses_use_refs: @responses_use_refs,
          schemes: @schemes,
          security_definitions: @security_definitions,
          global_security: @global_security
        }
      end
    end
  end
end
