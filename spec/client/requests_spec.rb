require 'spec_helper'
require 'mirage/client'

describe 'Requests' do
  it 'should delete all request data' do
    base_url = "base_url"
    Mirage::Requests.should_receive(:delete).with("#{base_url}/requests")
    Mirage::Requests.new(base_url).delete_all
  end
end