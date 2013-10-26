Feature: Models - an object oriented aproach to Templates.

  Use Models to for an object oriented approach to defining Templates.

  The Mirage client provides the Mirage::Template::Model module that can be used to make defining your own model classes easier.

  If you don't want to use this then objects that you pass to the client must simply have a body method in order to be compatible. This method should ultimately return the data you require the client to place on to mirage.

  The Model module provides class level methods for:

  * Defaulting characteristics such as HTTP status code and Content-type

  * Defining instance level methods that can set and get values.

  Instances of classes that extend this module will also have all of the standard methods of a Mirage Template and hence you can also set your request requirements directly on them too.

  Any defaults set using methods provided  can be overridden after instances are created and when the client is used to add them as Templates to Mirage. See below for examples.


  Background:
    Given the following gems are required to run the Mirage client test code:
    """
    require 'rubygems'
    require 'mirage/client'
    """


  Scenario: Defining a Model
    Given I run
    """
      class UserProfile
        extend Mirage::Template::Model

        endpoint '/users'
        http_method :get
        status 202
        content_type 'text/html'

        def body
          "Joe Blogs"
        end
      end

      Mirage::Client.new.put UserProfile.new
    """
    When GET is sent to '/responses/users'
    Then 'Joe Blogs' should be returned
    And a 202 should be returned
    And the content-type should be 'text/html'


  Scenario: Defining builder methods
    Given I run
    """
      class UserProfile
        extend Mirage::Template::Model
        endpoint '/users'

        builder_methods :firstname, :surname

        def body
          "#{firstname} #{surname}"
        end
      end

      Mirage::Client.new.put UserProfile.new.firstname('Joe').surname('Blogs')
    """
    When GET is sent to '/responses/users'
    Then 'Joe Blogs' should be returned

  Scenario: Overriding model defaults
    Given I run
    """
      class UserProfile
        extend Mirage::Template::Model
        endpoint '/users'

        builder_methods :firstname, :surname
        status '200'

        def body
          "#{firstname} #{surname}"
        end
      end

      Mirage::Client.new.put '/profiles', UserProfile.new.firstname('Joe').surname('Blogs') do
        status 202
      end
    """
    When GET is sent to '/responses/profiles'
    Then 'Joe Blogs' should be returned
    And a 202 should be returned



