require 'spec_helper'

RSpec.describe "routes", type: :routing do
  let(:resource) { :pets }
  let(:version) { 1 }

  describe '#resource' do
    subject { get("apipie/#{version}/#{resource}") }

    # before do
    #   binding.pry
    #
    # end

    it { is_expected.to route_to('apipie/apipies#resource') }
  end
end
