require 'spec_helper'
require 'mirage/client'

include Mirage
describe 'Requests' do
  it 'should delete all request data' do
    base_url = "base_url"
    Requests.should_receive(:delete).with(base_url)
    Requests.new(base_url).delete_all
  end
end