module ApipieHelper
  include ActionView::Helpers::TagHelper

  def heading(title, level = 1)
    content_tag("h#{level}") do
      title
    end
  end

  def theme_path
    'apipie/apipies'
  end

  def apipies?
    Apipie.configuration.layout == 'apipie/apipies'
  end
end
