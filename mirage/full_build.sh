#!/bin/bash


if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then

  source "$HOME/.rvm/scripts/rvm"

elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then

  \# Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"

else
    echo -e "RVM must be installed to run this script. \n
             Until it is installed simply run the default rake target to test Mirage against your active version of Ruby and installed gems"
fi



source "$HOME/.rvm/scripts/rvm"

blue='\033[34m'
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
white='\033[37m'

message=""
result=true

reset_comandline_colours(){
    tput sgr0
}

run_build_for_ruby( ){
    echo -e "${green}Running build for: $1"
    reset_comandline_colours

    ruby_list=`rvm list`
    if [[ ${ruby_list} == *$1* ]]
    then
        rvm $1
        rvm --force gemset empty
        [ -f Gemfile.lock ] && rm Gemfile.lock
        gem install bundler
        bundle install
        rake

        if [ $? == 0 ]
        then
          message="${message}${blue}$1: ${green}pass\n"
        else
          message="${message}${blue}$1: ${red}fail\n"
          result=false
        fi
    else
        message="${message}${blue}$1: ${yellow}Not installed\n"
        result=false
    fi
}

if [ $1 ]
then
    run_build_for_ruby $1
else
    run_build_for_ruby 'ruby-1.8.2'
    run_build_for_ruby 'ruby-1.8.1'
    run_build_for_ruby 'ruby-1.9.2'
    run_build_for_ruby 'ruby-1.9.4'
    run_build_for_ruby 'jruby-1.5.4'
fi

echo -e "\n\n${message}"
echo -ne "${white}Result: "
[ ${result} == true ] && echo -e "${green}Pass\n" || echo -e "${red}Fail\n"
reset_comandline_colours
echo ""

