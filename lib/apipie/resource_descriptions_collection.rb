class Apipie::ResourceDescriptionsCollection < SimpleDelegator
  def initialize
    super(HashWithIndifferentAccess.new { |h, version| h[version] = {} })
  end

  # @return [Hash]
  def generatable(version, resource_name = nil)
    # If resource_name is blank, take just resources which have some methods
    # because we dont want to show eg ApplicationController as resource.
    if resource_name.present?
      with_resource_name(version, resource_name)
    else
      with_actions(version)
    end
  end

  private

  # @return [Hash{String->Apipie::ResourceDescription}]
  def with_resource_name(version, resource_name)
    {
      resource_name => self[version][resource_name]
    }
  end

  # @return [Hash{String->Apipie::ResourceDescription}]
  def with_actions(version)
    self[version].inject({}) do |result, (k, v)|
      result[k] = v if v._methods.present?
      result
    end
  end
end
