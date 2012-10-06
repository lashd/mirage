SimpleCov.start do
  command_name "spec:#{ENV['coverage']}"
  add_filter "/spec/"
  add_group "Server", "server"
  add_group "Client", "lib"
end