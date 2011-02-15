require 'rubygems'
require 'ramaze'

class WebApp < Ramaze::Controller
  def index
    tempfile, filename, @type =
      request[:file].values_at(:tempfile, :filename, :type)
#    send_file('/home/user/dev/eservice/mock-server/mockserver.rb', nil, 'Content-Disposition: attachment; filename=mockserver.rb')
    send_file(tempfile.path, @type,  "Content-Disposition: attachment; filename=#{filename}")
#    puts "hello"
  end
end

#class Upload < Ramaze::Controller
#  def index
#    return unless request.post?
#    @inspection = h(request.params.pretty_inspect)
#    tempfile, filename, @type =
#      request[:file].values_at(:tempfile, :filename, :type)
#    @extname, @basename = File.extname(filename), File.basename(filename)
#    @file_size = tempfile.size
#
#    options = Upload.options
#    dir = File.join(options.roots.first, options.publics.first)
#    file = File.expand_path(@basename, dir)
#    FileUtils.mkdir_p(dir)
#    FileUtils.cp(tempfile.path, file)
#
#    @is_image = @type.split('/').first == 'image'
#  end
#end


Ramaze.start