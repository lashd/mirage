$LOAD_PATH.unshift "/home/team/Projects/mirage/lib"
require 'mirage/client'

Mirage.start :port => 7001
Mirage.stop :port => 7001