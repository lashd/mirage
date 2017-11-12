# require 'spec_helper'
# require 'extensions/object'
# require 'extensions/hash'
# require 'mock_response'
#
# describe Mirage::MockResponse do
#
#   before :each do
#     MockResponse.delete_all
#   end
#
#   describe 'initialisation' do
#     it 'should find binary data' do
#       string="string"
#       response_spec = convert_keys_to_strings({:response => {:body => string}})
#       expect(BinaryDataChecker).to receive(:contains_binary_data?).with(string).and_return(true)
#       expect(MockResponse.new("greeting", response_spec).binary?).to eq(true)
#     end
#
#     it 'should not find binary data' do
#       string="string"
#       response_spec = convert_keys_to_strings({:response => {:body => string}})
#       expect(BinaryDataChecker).to receive(:contains_binary_data?).with(string).and_return(false)
#       expect(MockResponse.new("greeting", response_spec).binary?).to eq(false)
#     end
#   end
#
#   describe 'defaults' do
#     describe 'request' do
#       it 'should default http_method' do
#         expect(MockResponse.new("greeting", {}).request_spec['http_method']).to eq("get")
#       end
#     end
#
#     describe 'response' do
#
#       it 'should default content_type' do
#         expect(MockResponse.new("greeting", {}).response_spec['content_type']).to eq("text/plain")
#       end
#
#       it 'should default status code' do
#         expect(MockResponse.new("greeting", {}).response_spec['status']).to eq(200)
#       end
#       it 'should default delay' do
#         expect(MockResponse.new("greeting", {}).response_spec['delay']).to eq(0)
#       end
#
#       it 'should default default' do
#         expect(MockResponse.new("greeting", {}).response_spec['default']).to eq(false)
#       end
#     end
#   end
#
#   describe 'saving state' do
#     it 'should store the current set of responses' do
#       greeting = MockResponse.new("greeting")
#       farewell = MockResponse.new("farewell")
#
#       MockResponse.backup
#       MockResponse.new("farewell", "cheerio")
#       MockResponse.revert
#
#       expect(MockResponse.all).to eq([greeting, farewell])
#     end
#   end
#
#   describe "response values" do
#
#     it 'should return any headers set' do
#       headers = {
#           'header' => 'value'
#       }
#       response_spec = convert_keys_to_strings({:response => {:headers => headers}})
#       expect(MockResponse.new("greeting", response_spec).headers).to eq(headers)
#     end
#
#     it 'should return the response value' do
#       response_spec = convert_keys_to_strings({:response => {:body => Base64.encode64("hello")}})
#       expect(MockResponse.new("greeting", response_spec).value).to eq("hello")
#     end
#
#     it 'should return if the value contains binary data' do
#       response_spec = convert_keys_to_strings({:response => {:body => Base64.encode64("hello ${name}")}})
#       expect(BinaryDataChecker).to receive(:contains_binary_data?).and_return(true)
#       response = MockResponse.new("greeting", response_spec)
#
#       expect(response.value("", {"name" => "leon"})).to eq("hello ${name}")
#     end
#
#     it 'should replace patterns with values found in request parameters' do
#       response_spec = convert_keys_to_strings({:response => {:body => Base64.encode64("hello ${name}")}})
#       expect(MockResponse.new("greeting", response_spec).value("", {"name" => "leon"})).to eq("hello leon")
#     end
#
#     it 'should base64 decode values' do
#       response_spec = convert_keys_to_strings({:response => {:body => "encoded value"}})
#       expect(Base64).to receive(:decode64).and_return("decoded value")
#       MockResponse.new("greeting", response_spec).value("")
#     end
#
#     it 'should replace patterns with values found in the body' do
#       response_spec = convert_keys_to_strings({:response => {:body => Base64.encode64("hello ${name>(.*?)<}")}})
#       expect(MockResponse.new("greeting", response_spec).value("<name>leon</name>")).to eq("hello leon")
#     end
#   end
#
#   describe "Matching http method" do
#     it 'should find the response with the correct http method' do
#       response_spec = convert_keys_to_strings({:request => {:http_method => "post"}})
#       response = MockResponse.new("greeting", response_spec)
#
#       options = {:body => "", :params => {}, :endpoint => "greeting", :http_method => "post", :headers => {}}
#       expect(MockResponse.find(options)).to eq(response)
#       options[:http_method] = "get"
#       expect { MockResponse.find(options) }.to raise_error(ServerResponseNotFound)
#     end
#   end
#
#   describe 'Finding by id' do
#     it 'should find a response given its id' do
#       response1 = MockResponse.new("greeting", "hello")
#       MockResponse.new("farewell", "goodbye")
#       expect(MockResponse.find_by_id(response1.response_id)).to eq(response1)
#     end
#   end
#
#   describe 'deleting' do
#
#     it 'should delete a response given its id' do
#       response1 = MockResponse.new("greeting", "hello")
#       MockResponse.delete(response1.response_id)
#       expect { MockResponse.find_by_id(response1.response_id) }.to raise_error(ServerResponseNotFound)
#     end
#
#     it 'should delete all responses' do
#       MockResponse.new("greeting", "hello")
#       MockResponse.new("farewell", "goodbye")
#       MockResponse.delete_all
#       expect(MockResponse.all.size).to eq(0)
#     end
#
#   end
#
#   describe 'matching' do
#     it 'should convert requirements in to strings before matching' do
#       requirement = 1234
#       spec = convert_keys_to_strings(
#           {
#               :request => {
#                   :parameters => {:number => requirement},
#                   :body_content => [requirement],
#                   :headers => {:number => requirement}
#               },
#               :response => {
#                   :body => 'response'
#               }
#
#           }
#       )
#
#       MockResponse.new("greeting", spec)
#       options = {:headers => {'number' => '1234'},
#                  :params => {'number' => "1234"},
#                  :endpoint => "greeting",
#                  :http_method => "get",
#                  :body => "1234", }
#
#       expect { MockResponse.find(options) }.to_not raise_error
#     end
#
#     describe "matching on request parameters" do
#       it 'should find the response if all required parameters are present' do
#         get_spec = convert_keys_to_strings(
#             {
#                 :request => {
#                     :http_method => "get",
#                     :parameters => {
#                         :firstname => "leon"
#                     }
#                 },
#                 :response => {
#                     :body => Base64.encode64("get response")
#                 }
#             }
#         )
#
#         post_spec = convert_keys_to_strings(
#             {
#                 :request => {
#                     :http_method => "post",
#                     :parameters => {
#                         :firstname => "leon"
#                     }
#                 },
#                 :response => {
#                     :body => Base64.encode64("post response")
#                 }
#             }
#         )
#         get_response = MockResponse.new("greeting", get_spec)
#         post_response = MockResponse.new("greeting", post_spec)
#
#         options = {:body => "", :params => {"firstname" => "leon"}, :endpoint => "greeting", :http_method => "post", :headers => {}}
#
#         expect(MockResponse.find(options)).to eq(post_response)
#         expect(MockResponse.find(options.merge(:http_method => "get"))).to eq(get_response)
#       end
#
#       it 'should match request parameter values using regexps' do
#         response_spec = convert_keys_to_strings(
#             {
#                 :request => {
#                     :parameters => {:firstname => "%r{leon.*}"}
#                 },
#                 :response => {
#                     :body => 'response'
#                 }
#
#             }
#         )
#         response = MockResponse.new("greeting", response_spec)
#
#         options = {:body => "", :params => {"firstname" => "leon"}, :endpoint => "greeting", :http_method => "get", :headers => {}}
#         expect(MockResponse.find(options)).to eq(response)
#         expect(MockResponse.find(options.merge(:params => {"firstname" => "leonard"}))).to eq(response)
#         expect { MockResponse.find(options.merge(:params => {"firstname" => "leo"})) }.to raise_error(ServerResponseNotFound)
#       end
#     end
#
#     describe 'matching request uri' do
#       it 'should match using wild cards' do
#         response_spec = convert_keys_to_strings(
#             {
#                 :response => {
#                     :body => 'response'
#                 }
#
#             }
#         )
#         response = MockResponse.new('greeting/*/ashley/*', response_spec)
#         expect(MockResponse.find(:params => {}, :headers => {}, :http_method => "get", endpoint: 'greeting/leon/ashley/davis')).to eq(response)
#       end
#     end
#
#     describe 'matching against request http_headers' do
#       it 'should match using literals' do
#         required_headers = {
#             'HEADER-1' => 'value1',
#             'HEADER-2' => 'value2'
#         }
#         spec = convert_keys_to_strings(
#             {
#                 :request => {
#                     :headers => required_headers
#                 },
#                 :response => {
#                     :body => 'response'
#                 }
#
#             }
#         )
#         response = MockResponse.new("greeting", spec)
#
#         options = {:body => "<name>leon</name>", :params => {}, :endpoint => "greeting", :http_method => "get", :headers => required_headers}
#         expect(MockResponse.find(options)).to eq(response)
#         expect { MockResponse.find(options.merge(:headers => {})) }.to raise_error(ServerResponseNotFound)
#
#       end
#
#       it 'should match using regex' do
#         required_headers = {
#             'CONTENT-TYPE' => '%r{.*/json}',
#         }
#         spec = convert_keys_to_strings(
#             {
#                 :request => {
#                     :headers => required_headers
#                 },
#                 :response => {
#                     :body => 'response'
#                 }
#
#             }
#         )
#         response = MockResponse.new("greeting", spec)
#
#         options = {:body => "<name>leon</name>", :params => {}, :endpoint => "greeting", :http_method => "get", :headers => {'CONTENT-TYPE' => 'application/json'}}
#         expect(MockResponse.find(options)).to eq(response)
#         expect { MockResponse.find(options.merge(:headers => {'CONTENT-TYPE' => 'text/xml'})) }.to raise_error(ServerResponseNotFound)
#
#       end
#     end
#
#     describe 'matching against the request body' do
#       it 'should match required fragments in the request body' do
#
#         response_spec = convert_keys_to_strings(
#             {
#                 :request => {
#                     :body_content => %w(leon)
#                 },
#                 :response => {
#                     :body => 'response'
#                 }
#
#             }
#         )
#
#         response = MockResponse.new("greeting", response_spec)
#
#         options = {:body => "<name>leon</name>", :params => {}, :endpoint => "greeting", :http_method => "get", :headers => {}}
#
#         expect(MockResponse.find(options)).to eq(response)
#         expect { MockResponse.find(options.merge(:body => "<name>jeff</name>")) }.to raise_error(ServerResponseNotFound)
#       end
#
#       it 'should use regexs to match required fragements in the request body' do
#         response_spec = convert_keys_to_strings(
#             {
#                 :request => {
#                     :body_content => %w(%r{leon.*})
#                 },
#                 :response => {
#                     :body => 'response'
#                 }
#
#             }
#         )
#
#         response = MockResponse.new("greeting", response_spec)
#
#
#         options = {:body => "<name>leon</name>", :params => {}, :endpoint => "greeting", :http_method => "get", :headers => {}}
#         expect(MockResponse.find(options)).to eq(response)
#         expect(MockResponse.find(options.merge(:body => "<name>leonard</name>"))).to eq(response)
#         expect { MockResponse.find(options.merge(:body => "<name>jeff</name>")) }.to raise_error(ServerResponseNotFound)
#       end
#     end
#   end
#
#   it 'should be equal to another response that is the same not including the response value' do
#
#     spec = convert_keys_to_strings({:response => {:body => "hello1",
#                                                   :content_type => "text/xml",
#                                                   :status => 202,
#                                                   :delay => 1.0,
#                                                   :default => true,
#                                                   :file => false}
#
#                                    })
#
#     response = MockResponse.new("greeting", spec)
#     expect(response).not_to eq(MockResponse.new("greeting", {}))
#     expect(response).to eq(MockResponse.new("greeting", spec))
#   end
#
#   describe "scoring to represent the specificity of a response" do
#
#     it 'should score an exact requirement match at 2' do
#       response_spec = convert_keys_to_strings(
#           {
#               :request => {
#                   :parameters => {:firstname => "leon"}
#               },
#               :response => {
#                   :body => 'response'
#               }
#
#           }
#       )
#       expect(MockResponse.new("greeting", response_spec).score).to eq(2)
#
#       response_spec = convert_keys_to_strings(
#           {
#               :request => {
#                   :body_content => %w(login)
#               },
#               :response => {
#                   :body => 'response'
#               }
#
#           }
#       )
#       expect(MockResponse.new("greeting", response_spec).score).to eq(2)
#
#       response_spec = convert_keys_to_strings(
#           {
#               :request => {
#                   :headers => {'header' => 'header'}
#               },
#               :response => {
#                   :body => 'response'
#               }
#
#           }
#       )
#       expect(MockResponse.new("greeting", response_spec).score).to eq(2)
#     end
#
#     it 'should score a match found by regexp at 1' do
#
#       response_spec = convert_keys_to_strings(
#           {
#               :request => {
#                   :parameters => {:firstname => "%r{leon.*}"}
#               },
#               :response => {
#                   :body => 'response'
#               }
#
#           }
#       )
#       expect(MockResponse.new("greeting", response_spec).score).to eq(1)
#
#       response_spec = convert_keys_to_strings(
#           {
#               :request => {
#                   :body_content => %w(%r{input|output})
#               },
#               :response => {
#                   :body => 'response'
#               }
#
#           }
#       )
#       expect(MockResponse.new("greeting", response_spec).score).to eq(1)
#
#       response_spec = convert_keys_to_strings(
#           {
#               :request => {
#                   :headers => {'header' => '%r{.*blah}'}
#               },
#               :response => {
#                   :body => 'response'
#               }
#
#           }
#       )
#       expect(MockResponse.new("greeting", response_spec).score).to eq(1)
#     end
#
#     it 'should find the most specific response' do
#       default_response_spec = convert_keys_to_strings(
#           {
#               :request => {
#                   :body_content => %w(login)
#               },
#               :response => {
#                   :body => 'default_response'
#               }
#
#           }
#       )
#
#       specific_response_spec = convert_keys_to_strings(
#           {
#               :request => {
#                   :body_content => %w(login),
#                   :parameters => {
#                       :name => "leon"
#                   }
#               },
#               :response => {
#                   :body => 'specific response'
#               }
#
#           }
#       )
#
#       MockResponse.new("greeting", default_response_spec)
#       expected_response = MockResponse.new("greeting", specific_response_spec)
#       options = {:body => "<action>login</action>", :params => {"name" => "leon"}, :endpoint => "greeting", :http_method => "get", :headers => {}}
#       expect(MockResponse.find(options)).to eq(expected_response)
#     end
#   end
#
#
#   it 'should all matching to be based on body content, request parameters and http method' do
#     response_spec = convert_keys_to_strings({
#                                                 :request => {
#                                                     :body_content => %w(login),
#                                                     :parameters => {
#                                                         :name => "leon"
#                                                     },
#                                                     :http_method => "post"
#                                                 },
#                                                 :response => {
#                                                     :body => "response"
#                                                 }
#                                             })
#
#
#     response = MockResponse.new("greeting", response_spec)
#     options = {:body => "<action>login</action>", :params => {"name" => "leon"}, :endpoint => "greeting", :http_method => "post", :headers => {}}
#     expect(MockResponse.find(options)).to eq(response)
#
#     options[:http_method] = 'get'
#     expect { MockResponse.find(options) }.to raise_error(ServerResponseNotFound)
#   end
#
#   it 'should recycle response ids' do
#     response_spec = convert_keys_to_strings({
#                                                 :request => {
#                                                     :body_content => %w(login),
#                                                     :parameters => {
#                                                         :name => "leon"
#                                                     },
#                                                     :http_method => "post"
#                                                 },
#                                                 :response => {
#                                                     :body => "response"
#                                                 }
#                                             })
#     response1 = MockResponse.new("greeting", response_spec)
#     response_spec['response']['body'] = 'response2'
#     response2 = MockResponse.new("greeting", response_spec)
#
#     expect(response1.response_id).not_to eq(nil)
#     expect(response1.response_id).to eq(response2.response_id)
#   end
#
#   it 'should raise an exception when a response is not found' do
#     expect { MockResponse.find(:body => "<action>login</action>", :params => {:name => "leon"}, :endpoint => "greeting", :http_method => "post", :headers => {}) }.to raise_error(ServerResponseNotFound)
#   end
#
#   it 'should return all responses' do
#     MockResponse.new("greeting", convert_keys_to_strings({:response => {:body => "hello"}}))
#     MockResponse.new("greeting", convert_keys_to_strings({:request => {:body_content => %w(leon)}, :response => {:body => "hello leon"}}))
#     MockResponse.new("greeting", convert_keys_to_strings({:request => {:body_content => %w(leon), :http_method => "post"}, :response => {:body => "hello leon"}}))
#     MockResponse.new("deposit", convert_keys_to_strings({:request => {:body_content => %w(amount), :http_method => "post"}, :response => {:body => "received"}}))
#     expect(MockResponse.all.size).to eq(4)
#   end
#
#   describe 'finding defaults' do
#     it 'most appropriate response under parent resource and same http method' do
#       level1_response = MockResponse.new("level1", convert_keys_to_strings({:response => {:body => "level1", :default => true}}))
#       MockResponse.new("level1/level2", convert_keys_to_strings({:response => {:body => "level2", :default => true}, :request => {:body_content => %w(body)}}))
#       expect(MockResponse.find_default(:body => "", :http_method => "get", :endpoint => "level1/level2/level3", :params => {}, :headers => {})).to eq(level1_response)
#     end
#   end
#
#   it 'should generate subdomains' do
#     expect(MockResponse.subdomains("1/2/3")).to eq(["1/2/3", '1/2', '1'])
#   end
#
#   it 'should generate a json representation of itself' do
#     endpoint = "greeting"
#     requests_url = "requests_url"
#     response_spec = convert_keys_to_strings({
#                                                 :id => 1,
#                                                 :endpoint => endpoint,
#                                                 :requests_url => requests_url,
#                                                 :request => {
#                                                     :body_content => %w(login),
#                                                     :parameters => {
#                                                         :name => "leon"
#                                                     },
#                                                     :headers => {
#                                                         :header => 'header'
#                                                     },
#                                                     :http_method => "post"
#                                                 },
#                                                 :response => {
#                                                     :body => "response",
#                                                     :delay => 0,
#                                                     :content_type => 'text/plain',
#                                                     :status => 200,
#                                                     :default => false
#                                                 }
#                                             })
#
#     mock_response = MockResponse.new(endpoint, response_spec)
#     mock_response.requests_url = requests_url
#     expect(JSON.parse(mock_response.raw)).to eq(response_spec)
#   end
#
# end