module Apipie
  class PagesController < ActionController::Base
    include ActionView::Context
    include ApipieHelper
    include ThemeIctinusHelper

    layout Apipie.configuration.layout

  end
end
