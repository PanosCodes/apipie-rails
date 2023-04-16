module ThemeIctinusHelper
  def http_method_color(http_method)
    colors = {
      get: :success,
      post: :warning,
      patch: :dark,
      delete: :danger,
      put: :primary
    }

    colors[http_method.downcase.to_sym] || :muted
  end

  def status_code_color(status_code)
    case status_code.to_s
    when /^2/
      :success
    when /^[45]/
      :danger
    else
      :dark
    end
  end

  def apipies?
    Apipie.configuration.layout == 'apipie/apipies'
  end

  # @param [Hash] param_description
  def param_description_id(param_description)
    return '' if param_description[:params].blank?

    param_description[:full_name].tr(' ', '-').tr('[', '-').delete(']')
  end

  def languages?
    @languages.present? && @languages.size > 1
  end

  def url_for_language(language)

  end

  def url_for_version(version)

  end

  def url_for_http_verb(resource_name, method, http_verb)
    apipie_http_verb_path(
      version: current_version,
      resource: resource_name,
      method: method,
      http_verb: http_verb
    )
  end

  def current_version
    params[:version] || Apipie.configuration.default_version
  end

  def sidebar_items
    items = []

    @doc[:resources].each do |resource_name, resource_description|
      children = []
      resource_description[:methods].each do |method_description|
        method_description[:apis].each do |api|
          url = url_for_http_verb(resource_name, method_description[:name], api[:http_method])

          children << {
            name: api[:api_url],
            url: url,
            badge_text: api[:http_method],
            selected: url == request.original_fullpath
          }
        end
      end

      items << {
        name: resource_name,
        url: resource_description[:doc_url],
        selected: true,
        children: children
      }
    end

    items
  end
end
