task :start do
  `RACK_ENV='development' && ruby ./bin/mirage start`
end

task :stop do
  `RACK_ENV='development' && ruby ./bin/mirage stop`
end
