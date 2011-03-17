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


  def value(body='', request_parameters={}, query_string='')
    value = @value
    value.scan(/\$\{(.*)?\}/).flatten.each do |pattern|

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

class MirageServer < Ramaze::Controller
  include Ramaze::Helper::SendFile
  map '/mirage'
  RESPONSES, REQUESTS, SNAPSHOT= {}, {}, {}

  def index
    @responses = {}

    RESPONSES.each do |name, responses|
      @responses[name]=responses.default unless responses.default.nil?

      responses.each do |pattern, response|
        @responses["#{name}: #{pattern}"] = response
      end
    end
  end

  def peek response_id
    peeked_response = nil
    RESPONSES.values.each do |responses|
      peeked_response = responses[:default] if responses[:default] && responses[:default].response_id == response_id.to_i
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

  def set *args
    delay = (request['delay']||0)
    pattern = request['pattern'] ? /#{request['pattern']}/ : :default
    name = args.join('/')

    if request[:file]
      response = MockFileResponse.new(name, request[:file], pattern, delay.to_f)
    else
      response = MockResponse.new(name, response_value, pattern, delay.to_f)
    end

    stored_responses = RESPONSES[name]||={}

    old_response = stored_responses[pattern]
    stored_responses[pattern] = response

    # Right not an the main id count goes up by one even if the id is not used because the old id is reused from another response
    response.response_id = old_response.response_id if old_response
    response.response_id
  end



  def get *args
    body, query_string = Rack::Utils.unescape(request.body.read.to_s), request.env['QUERY_STRING']


    name = args.join('/')
    stored_responses = RESPONSES[name]

    unless stored_responses
      stored_responses = root_response(name)
    end

    respond('Response not found', 404) unless stored_responses

    pattern_match = stored_responses.keys.find_all { |pattern| pattern != :default }.find{ |pattern| body =~ pattern || query_string =~ pattern }
    record = pattern_match ? stored_responses[pattern_match] : stored_responses[:default]

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

  def delete_response(response_id)
    RESPONSES.each do |name, response_set|
      response_set.each { |key, response| response_set.delete(key) if response.response_id == response_id }
    end
    REQUESTS.delete(response_id)
  end

  def clear datatype=nil, response_id=nil
    response_id = response_id.to_i
    case datatype
      when 'requests' then
        REQUESTS.clear
      when 'responses' then
        RESPONSES.clear and REQUESTS.clear and MockResponse.reset_count
      when /\d+/ then
        delete_response(datatype.to_i)
      when 'request'
        REQUESTS.delete(response_id)
      when nil
        [REQUESTS, RESPONSES].each { |map| map.clear }
        MockResponse.reset_count
    end
  end

  def query id
    REQUESTS[id.to_i] || respond("Nothing stored for: #{id}", 404)
  end

  def snapshot
    SNAPSHOT.clear and SNAPSHOT.replace(Marshal.load(Marshal.dump(RESPONSES)))
  end

  def rollback
    RESPONSES.clear and RESPONSES.replace(Marshal.load(Marshal.dump(SNAPSHOT)))
  end

  def load_defaults
    clear
    Dir["#{DEFAULT_RESPONSES_DIR}/**/*.rb"].each do |default|
      begin
        load default
      rescue Exception
        respond("Unable to load default responses from: #{default}", 500)
      end

    end
  end

  private
  def response_value
    return request['response'] unless request['response'].nil?
    respond('response or file parameter required', 500)
  end

  def root_response(name)
    matches = RESPONSES.keys.find_all { |key| name.index(key) == 0 }.sort { |a, b| b.length <=> a.length }
    stored_responses = RESPONSES[matches.first]
    stored_responses
  end

end

