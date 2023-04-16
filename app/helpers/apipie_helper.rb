module ApipieHelper
  include ActionView::Helpers::TagHelper

  def heading(title, level = 1)
    content_tag("h#{level}") do
      title
    end
  end

  def theme_path
    if Apipie.configuration.layout == 'apipie/ictinus'
      'apipie/ictinus'
    else
      'apipie/apipies'
    end
  end

  def apipies?
    Apipie.configuration.layout == 'apipie/apipies'
  end
end
