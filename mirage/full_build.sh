#!/bin/bash

source "$HOME/.rvm/scripts/rvm"
blue='\033[34m'
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
white='\033[37m'

message=""
result=true

run_build_for_ruby( ){
    ruby_list=`rvm list`
    if [[ ${ruby_list} == *$1* ]]
    then
        rvm $1
        rake

        if [ $? == 0 ]
        then
          message="${message}${blue}$1: ${green}pass\n"
        else
          message="${message}${blue}$1: ${red}fail\n"
          result=false
        fi
    else
        message="${blue}$1: ${yellow}Not installed"
    fi



}

run_build_for_ruby 'ruby-1.8.6'
run_build_for_ruby 'ruby-1.8.7'
run_build_for_ruby 'ruby-1.9.1'
run_build_for_ruby 'ruby-1.9.2'
run_build_for_ruby 'jruby-1.5.6'
#run_build_for_ruby 'jruby-something else'

echo -e ${message}

echo -ne "${white}Result: "
[ result == true ] && echo -e "${green}Pass" || echo -e "${red}Fail"
tput sgr0
