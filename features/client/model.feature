Feature: Template Models

  Use Models to for an object oriented approach to defining Templates.

  The Mirage client provides the Mirage::Template::Model module that can be used to define your own model classes.

  Having extended this module you must provide a 'body' method to customise the body of the response

  The Model module provides class level methods for:

  * Defaulting characteristics such as HTTP status code and Content-type

  * Defining instance level methods that can set and get values.

  Instances of classes that extend this module will also have all of the standard methods of a Mirage Template and hence you can also set your request requirements directly on them too.

  Any defaults set using methods provided  can be overridden after instances are created and when the client is used to add them as Templates to Mirage. See below for examples.


  Background:
    Given the following require statements are needed:
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
          "Joe Blogs"
        end
      end

      Mirage::Client.new.put '/profiles', UserProfile.new do
        status 202
      end
    """
    When GET is sent to '/responses/profiles'
    Then 'Joe Blogs' should be returned
    And a 202 should be returned



