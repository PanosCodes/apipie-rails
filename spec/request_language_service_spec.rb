require 'spec_helper'

describe RequestLanguageService do
  let(:method_param) { 'create.html' }

  let(:request) do
    test_request = ActionDispatch::TestRequest.create({})
    test_request.path_parameters = {
      'controller' => 'apipie/apipies',
      'action' => 'index',
      'version' => '1',
      'resource' => 'tweets',
      'method' => method_param
    }
    test_request
  end

  describe '#call' do
    subject { described_class.call(request) }

    context 'when translations are disabled' do
      before { Apipie.configuration.translate = false }

      it { is_expected.to be_nil }
    end

    context 'when translations are enabled' do
      before { Apipie.configuration.translate = true }

      context 'when default locale is set' do
        let(:default_locale) { 'en' }

        before { Apipie.configuration.default_locale = default_locale }

        context 'when exists in param' do
          let(:method_param) { "create.#{default_locale}.html" }

          it { is_expected.to eq({ param: :method, language: default_locale }) }
        end
      end
    end
  end
end
