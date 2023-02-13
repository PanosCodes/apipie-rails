# frozen_string_literal: true

# ok
class RequestLanguageService
  def initialize(request)
    @request = request
  end
  private_class_method :new

  # @@return [Hash, nil] request
  def self.call(request)
    new(request).call
  end

  # @return [Hash, nil]
  def call
    return unless Apipie.configuration.translate

    language = Apipie.configuration.default_locale
    param_found = nil

    [:resource, :method, :version, :http_verb].each do |url_param|
      next if params[url_param].blank? || language_from_param(url_param).blank?

      language_from_param = language_from_param(url_param)

      if language_from_param.present?
        language = language_from_param
        param_found = url_param
      end
    end

    { param: param_found, language: language }.compact
  end

  private

  # @return [Hash]
  def params
    @params ||= @request.params
  end

  # @param [Symbol] url_param
  #
  # @return [String, nil]
  def language_from_param(url_param)
    language = params[url_param].split('.').reverse[1]

    language if valid_languages.include?(language)
  end

  # @return [Array<String>]
  def valid_languages
    Apipie.configuration.languages + [Apipie.configuration.default_locale]
  end
end
