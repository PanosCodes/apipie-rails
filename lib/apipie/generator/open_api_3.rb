class Apipie::Generator::OpenApi3
  # @param [Apipie::Application] apipie
  def initialize(apipie)
    @apipie = apipie
  end

  def generate(version:)
    {
      openapi: '3.0.0',
      info: info,
      servers: servers,
      paths: paths,
      components: components,
      security: security,
      tags: tags
    }
  end

  # @return [Hash]
  def info
    {
      title: @config.app_name,
      summary: @apipie.app_info[:summary],
      description: @apipie.app_info[:description],
      termsOfService: @apipie.app_info[:terms_of_service],
      contact: @apipie.app_info[:contact],
      license: @apipie.app_info[:license],
      version: @apipie.default_version
    }.compact
  end

  private

  def config
    @config ||= Apipie.configuration
  end

  def version

  end
end
