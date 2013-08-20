require 'mirage/client'

Mirage.start.put('greeting', 'hello') do
  content_type "text/html"
end