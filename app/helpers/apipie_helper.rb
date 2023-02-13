module ApipieHelper
  include ActionView::Helpers::TagHelper

  def heading(title, level = 1)
    content_tag("h#{level}") do
      title
    end
  end

  def theme_path
    if Apipie.configuration.layout == 'apipie/ictinus'
      'apipie/apipies/ictinus'
    else
      'apipie/apipies'
    end
  end

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

  def ictinus?
    Apipie.configuration.layout == 'apipie/ictinus'
  end

  def apipies?
    Apipie.configuration.layout == 'apipie/apipies'
  end

  # @param [Apipie::ParamDescription] param_description
  def param_description_id(param_description)
    return  '' if param_description[:params].blank?
    param_description[:full_name].tr(' ', '-').tr('[', '-').delete(']')
  end
end
