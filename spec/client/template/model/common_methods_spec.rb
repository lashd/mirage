require 'spec_helper'
describe 'CommonMethods' do
  let!(:model) do
    Class.new do
      include Template::Model::CommonMethods
    end
  end

  let!(:instance) do
    model.new
  end
  it 'should provide methods for customising the model' do
    instance.methods.should include(:content_type,
                                    :http_method,
                                    :default,
                                    :status,
                                    :delay,
                                    :required_parameters,
                                    :required_body_content,
                                    :required_headers,
                                    :endpoint,
                                    :headers,
                                    :body)
  end
end