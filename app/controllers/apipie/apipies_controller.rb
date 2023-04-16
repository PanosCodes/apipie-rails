module Apipie
  class ApipiesController < ActionController::Base
    include ActionView::Context
    include ApipieHelper
    include ThemeIctinusHelper

    layout Apipie.configuration.layout

    around_action :set_script_name
    around_action :swagger_warnings, if: :swagger?

    before_action :authenticate, :authorize, :set_language, :prepare_params!,
                  :set_format_from_extension, :set_version, :set_doc,
                  :set_versions, :set_languages
    before_action :set_resource, only: [:resource, :index]
    before_action :set_method, only: [:method, :index]
    before_action :set_api, only: [:http_verb]

    def index
      respond_to do |format|
        if Apipie.configuration.use_cache?
          render_from_cache
          return
        end

        format.json do
          if @doc
            render json: @doc
          else
            head :not_found
          end
        end

        format.html do
          render 'apipie_404', status: 404 and return if @doc.blank?
          render "getting_started" and return if @doc[:resources].blank?

          if @resource.present? && @method.present?
            return method
          elsif @resource
            return resource
          elsif params[:resource].present? || params[:method].present?
            render 'apipie_404', status: 404
          else
            render "#{theme_path}/index"
          end
        end
      end
    end

    def versions
      render "#{theme_path}/versions"
    end

    def resource
      render "#{theme_path}/resource"
    end

    def method
      render "#{theme_path}/method"
    end

    def http_verb
      render "#{theme_path}/http_verb"
    end

    def apipie_checksum
    end

    def swagger
      render json: @doc
    end

    private

    helper_method :heading

    def authorize
      if swagger? && Apipie.configuration.authorize
        head :forbidden
      end
    end

    def authenticate
      if Apipie.configuration.authenticate
        instance_eval(&Apipie.configuration.authenticate)
      end
    end

    def set_doc
      if Apipie.configuration.reload_controllers? || !Rails.application.config.eager_load
        Apipie.load_documentation
      end

      if swagger?
        @doc = Apipie.to_swagger_json(@version, params[:resource], params[:method], @language)
      else
        if apipies?
          @doc = Apipie.to_json(params[:version], params[:resource], params[:method], @language)
        else
          @doc = Apipie.to_json(params[:version], nil, nil, @language)
        end

        @doc = authorized_doc
      end

      @doc = @doc[:docs]
      @doc[:link_extension] = link_extension
    end

    def set_versions
      @versions = Apipie.available_versions
    end

    def set_languages
      @languages = Apipie.configuration.languages
    end

    def set_language
      @language = language_results[:language]

      I18n.locale = @language
    end

    def prepare_params!
      if language_results[:param].present?
        params[language_results[:param]].sub!(link_extension, '')
      end
    end

    def set_version
      params[:version] ||= Apipie.configuration.default_version
    end

    # @return [Hash]
    def language_results
      @language_results ||= RequestLanguageService.call(request) || {}
    end

    def set_resource
      @resource = doc_presenter.resource(params[:resource])
    end

    def set_method
      @resource = doc_presenter.resource(params[:resource])

      if params[:method].present?
        @method = doc_presenter.action(params[:resource], params[:method])
      end
    end

    def set_api
      @resource = doc_presenter.resource(params[:resource])
      @method = doc_presenter.action(params[:resource], params[:method])
      @api = doc_presenter.api(params[:resource], params[:method], params[:http_verb])

      examples_file = Rails.root.join(Apipie.configuration.doc_path, 'apipie_examples.json')

      if examples_file.exist?
        contents = Rails.root.join(Apipie.configuration.doc_path, 'apipie_examples.json').read
        api = "#{@resource[:id]}##{@method[:name]}".downcase
        @examples = (JSON.parse(contents) || {})[api]
      else
        @examples = []
      end
    end

    def swagger?
      params[:type].to_s == 'swagger' && params[:format].to_s == 'json'
    end

    def swagger_warnings
      prev_warning_value = Apipie.configuration.swagger_suppress_warnings

      begin
        Apipie.configuration.swagger_suppress_warnings = true
        yield
      ensure
        Apipie.configuration.swagger_suppress_warnings = prev_warning_value
      end
    end

    # @return [String]
    #   @example .en.html
    def link_extension
      language_part = @language ? ".#{@language}" : ''

      "#{language_part}#{Apipie.configuration.link_extension}"
    end

    def authorized_doc
      return if @doc.nil?
      return @doc unless Apipie.configuration.authorize

      new_doc = { :docs => @doc[:docs].clone }

      new_doc[:docs][:resources] = if @doc[:docs][:resources].kind_of?(Array)
                                     @doc[:docs][:resources].select do |resource|
                                       authorize_resource(resource)
                                     end
                                   else
                                     @doc[:docs][:resources].select do |_resource_id, resource|
                                       authorize_resource(resource)
                                     end
                                   end

      new_doc
    end

    def authorize_resource(resource)
      if instance_exec(resource[:id], nil, resource, &Apipie.configuration.authorize)
        resource[:methods] = resource[:methods].select do |m|
          instance_exec(resource[:id], m[:name], m, &Apipie.configuration.authorize)
        end
        true
      else
        false
      end
    end

    def set_format_from_extension
      [:resource, :method, :version].each do |par|
        next unless params[par]

        [:html, :json].each do |format|
          extension = ".#{format}"

          if params[par].include?(extension)
            params[par] = params[par].sub(extension, '')
            params[:format] = format
          end
        end
      end

      request.format = params[:format] if params[:format]
    end

    def render_from_cache
      path = Apipie.configuration.doc_base_url.dup
      # some params can contain dot, but only one in row
      if [:resource, :method, :format, :version].any? { |p| params[p].to_s.gsub(".", "") =~ /\W/ || params[p].to_s.include?('..') }
        head :bad_request and return
      end

      path << "/" << params[:version] if params[:version].present?
      path << "/" << params[:resource] if params[:resource].present?
      path << "/" << params[:method] if params[:method].present?
      if params[:format].present?
        path << ".#{params[:format]}"
      else
        path << ".html"
      end

      # we sanitize the params before so in ideal case, this condition
      # will be never satisfied. It's here for cases somebody adds new
      # param into the path later and forgets about sanitation.
      if path.include?('..')
        head :bad_request and return
      end

      cache_file = File.join(Apipie.configuration.cache_dir, path)
      if File.exist?(cache_file)
        content_type = case params[:format]
                       when "json" then "application/json"
                       else "text/html"
                       end
        send_file cache_file, :type => content_type, :disposition => "inline"
      else
        Rails.logger.error("API doc cache not found for '#{path}'. Perhaps you have forgot to run `rake apipie:cache`")
        head :not_found
      end
    end

    def set_script_name
      Apipie.request_script_name = request.env["SCRIPT_NAME"]
      yield
    ensure
      Apipie.request_script_name = nil
    end

    # @return [Apipie::DocPresenter]
    def doc_presenter
      @doc_presenter ||= Apipie::DocPresenter.new(@doc)
    end
  end
end
