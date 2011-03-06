#!/bin/bash
blue='\033[34m'
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
white='\033[37m'
bold='\033[1m'
reset='\033[0m'

println(){
    echo -e "$1${reset}"
}

print(){
    echo -ne "$1${reset}"
}



usage(){
    println "${bold}Usage:\n"
    println "./full_build.sh [ruby_version]\n"
    println "When running with out a ruby version, the full build is run for ruby versions:"
    println "1.8.6\n1.8.7\n1.9.1\n1.9.2\njruby\n"
    println "Else specify a particular ruby version to run the build against\n"
}


if [ -f "$HOME/.rvm/scripts/rvm" ]
then
  source "$HOME/.rvm/scripts/rvm"
elif [ -f "/usr/local/rvm/scripts/rvm" ]
then
  source "/usr/local/rvm/scripts/rvm"
else
    println "${bold}RVM Not found"
    println "I looked in $HOME/.rvm/scripts/rvm and /usr/local/rvm/scripts/rvm"
    println "RVM must be installed to run this script. It's great! find out more: here ${bold}http://rvm.beginrescueend.com/"
    println "Until it is installed simply run the default rake target to test Mirage against your active version of Ruby and installed gems"
    exit 1
fi

while getopts ":h" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    \?)
      println "Invalid option: -$OPTARG"
      usage
      exit 1
      ;;
  esac
done

message=""
result=true

run_build_for_ruby( ){
    println "${green}Running build for: $1"

    ruby_list=`rvm list`
    if [[ ${ruby_list} == *$1* ]]
    then
        rvm --create $1@mirage
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
    run_build_for_ruby 'ruby-1.8.6'
    run_build_for_ruby 'ruby-1.8.7'
    run_build_for_ruby 'ruby-1.9.1'
    run_build_for_ruby 'ruby-1.9.2'
    run_build_for_ruby 'jruby'
fi

println "\n\n${message}"
print "${white}Result: "
[ ${result} == true ] && println "${green}Pass\n" || println "${red}Fail\n"

