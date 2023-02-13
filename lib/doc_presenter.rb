# frozen_string_literal: true

#ok
class DocPresenter
  # @param [Hash] doc
  def initialize(doc)
    @doc = doc
  end

  def resource(resource_name)
    if @doc[:resources].is_a?(Array)
      'ok'
    else
      @doc[:resources][resource_name]
    end
  end

  def action(resource_name, method_name)
    resource(resource_name)[:methods].find { |method| method[:name] == method_name }
  end

  def api(resource_name, method_name, http_verb)
    action(resource_name, method_name)[:apis].find { |api| api[:http_method].downcase == http_verb.downcase }
  end

  def examples()

  end
end
