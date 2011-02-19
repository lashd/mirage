require 'ramaze'
require 'ramaze/helper/send_file'

class MockResponse
  @@id_count = 0
  attr_reader :response_id, :delay, :name, :pattern
  attr_accessor :response_id

  def initialize name, value, pattern=nil, delay=0
    @name, @value, @pattern, @response_id, @delay = name, value, pattern, @@id_count+=1, delay
  end

  def self.reset_count
    @@id_count = 0
  end



  def value(body='', request_parameters={},query_string='')
    value = @value
    value.scan(/\${(.*)?\}/).flatten.each do |pattern|

      if (parameter_match = request_parameters[pattern])
        value = value.gsub("${#{pattern}}", parameter_match)
      end

      [body, query_string].each do |string|
        if (string_match = find_match(string, pattern))
          value = value.gsub("${#{pattern}}", string_match)
        end
      end

    end
    value
  end

  private
  def find_match(string, regex)
    string.scan(/#{regex}/).flatten.first
  end
end

class MockFileResponse < MockResponse
  attr_accessor :file

  def initialize name, file, pattern=nil, delay=0
    super(name, '', pattern, delay)
    @file = file
  end
end

class MockServerCore < Ramaze::Controller
  include Ramaze::Helper::SendFile
  map '/mockserver'
  RESPONSES, REQUESTS, SNAPSHOT= {}, {}, {}

  def peek response_id
    peeked_response = nil
    RESPONSES.values.each do |responses|
      peeked_response = responses.default if responses.default && responses.default.response_id == response_id.to_i
      peeked_response = responses.values.find { |response| response.response_id == response_id.to_i } if peeked_response.nil?
      break unless peeked_response.nil?
    end
    respond("Can not peek reponse, id:#{response_id} does not exist}", 404) unless peeked_response
    if peeked_response.is_a? MockFileResponse
      tempfile, filename, type = peeked_response.file.values_at(:tempfile, :filename, :type)
      send_file(tempfile.path, type, "Content-Disposition: attachment; filename=#{filename}")
    else
      peeked_response.value
    end

  end

  def set name, *args
    pattern, delay =request['pattern'], (request['delay']||0)

    name = "#{name}/#{args.join('/')}" unless args.empty?

    stored_response = stored_responses(name)

    if request[:file]
      response = MockFileResponse.new(name, request[:file], pattern, delay.to_f)
    else
      response = MockResponse.new(name, response_value, pattern, delay.to_f)
    end

    case pattern
      when nil then
        old_response = stored_response.default
        stored_response.default = response
      else
        old_response = stored_response[/#{pattern}/] unless stored_response.empty?
        stored_response[/#{pattern}/] = response
    end

    response.response_id = old_response.response_id if old_response

    response.response_id
  end

  def get name, * args
    body, query_string, record = Rack::Utils.unescape(request.body.read.to_s), request.env['QUERY_STRING'], nil


    stored_response = stored_responses(name)

    unless (args.empty?)
      other_response = stored_responses("#{name}/#{args.join('/')}")
      if other_response.default || !other_response.empty?
        stored_response = other_response
      end
    end

    stored_response.each { |pattern, mock_response| record = mock_response and puts "matched pattern: #{pattern.source}" and break if body =~ pattern || query_string =~ pattern }
    record = stored_response.default unless record

    respond('Response not found', 404) unless record
    sleep record.delay
    REQUESTS[record.response_id] = body.empty? ? query_string : body

    if record.is_a? MockFileResponse
      tempfile, filename, type = record.file.values_at(:tempfile, :filename, :type)
      send_file(tempfile.path, type, "Content-Disposition: attachment; filename=#{filename}")
    else
      return record.value(body, request, query_string)
    end
  end

  def clear datatype=nil, name=nil
    case datatype
      when 'requests' then
        REQUESTS.delete(name) if name or REQUESTS.clear
      when 'responses' then
        RESPONSES.delete(name) if name or RESPONSES.clear and MockResponse.reset_count
      else
        [REQUESTS, RESPONSES].each { |map| map.delete(name) if name or map.clear }
        MockResponse.reset_count
    end
  end

  def check id
    REQUESTS[id.to_i] || respond("Nothing stored for: #{id}", 404)
  end

  def snapshot
    SNAPSHOT.clear and SNAPSHOT.replace(Marshal.load(Marshal.dump(RESPONSES)))
  end

  def rollback
    RESPONSES.clear and RESPONSES.replace(Marshal.load(Marshal.dump(SNAPSHOT)))
  end

  private
  def response_value
    return request['response'] unless request['response'].nil?
    respond('response required', 500)
  end

  def stored_responses (name)
    RESPONSES[name]||={}
  end
end
