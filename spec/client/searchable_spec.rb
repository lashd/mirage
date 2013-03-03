require 'spec_helper'
require 'mirage/client'

include Mirage
describe Searchable do
  it 'should add a finder method to the Mirage module when included' do
    class TestClass
      include Searchable
    end

    id = 1
    TestClass.should_receive(:get).with("/#{id}")
    Mirage::TestClass(id)
  end
end