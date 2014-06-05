require 'spec_helper'
require 'helpers/http_headers'
describe Mirage::Server::Helpers::HttpHeaders do
  describe '#extract_http_headers' do
    it 'returns content-type' do
      helpers = Object.new
      helpers.extend(described_class)
      expected = {'CONTENT_TYPE' => 'application/json'}
      expect(helpers.extract_http_headers(expected)['Content-Type']).to eq('application/json')
    end

  end
end