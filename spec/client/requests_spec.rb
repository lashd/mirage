require 'spec_helper'

describe Requests do
  it 'should delete all request data' do
    base_url = "base_url"
    Requests.should_receive(:delete).with("#{base_url}/requests")
    Requests.new(base_url).delete_all
  end
end