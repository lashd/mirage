Mirage
======
Mirage aids testing of your applications by hosting mock responses so that your applications do not have to talk to real endpoints. It's accessible via HTTP and has a RESTful interface.    

Any ideas/improvements or feedback you have are greatly appreciated.  
  
Information on how to use Mirage can be found [here](https://github.com/lashd/mirage/wiki).  
  
I hope you find it useful,  

Leon

P.s. Mirage runs on Linux,MacOSX and Windows; Rubies 1.9.3+ and JRuby.

Installation
------------
    gem install mirage 
    
What's New?
-----------
### 3.0.0
------------------------------
3.0.0 is now out the following is a description of what's new.

A full description of the functionality is also available in the projects [feature files](https://www.relishapp.com/lashd/mirage/docs) hosted on Relish. A lot of effort has gone in to trying to make these tests readable so if something is missing or unclear drop me a line.


#### What's new in the Server:
##### 1: Mirage uses JSON as its communucations medium
Mirage is now configured using JSON. JSON is also used as the output format for Mirage's other operations.
##### 2: Wildcards are now supported in the URI.
You can now specify wild cards in the URI matcher. This means that a url such as '/*/world' would match '/hello/world' :)
##### 3: Full Request Data now tracked
You can now retrieve all data associated with a request that triggers a response. Previously only the the request body/query string was tracked.
Now the full request, including HTTP headers are returned when querying '/requests/template_id'

##### 4. Parameters and body content matchers are now specified seperately
Now you can specify as many parameter and body matchers as you want. These can be both litteral strings or Regex's
  
Previously, it was only possible to specify a single matcher and this would be applied against both the querystring and the request body.
##### 5. HTTP Header matchers
You can now also specify matchers against HTTP headers.
##### 6. More advanced template resolution.
Templates are now scored to find the most appropriate template when finding a match for a particular request. Previously the first potential match was returned even
if there was a more appropriate template.

Litteral matchers are worth more in the scoring process than regex based ones for example.
##### 7. The url has changed
Mirage is now accessible via: http://localhost:7001. I.e. 'mirage' has been removed from all resources 

e.g. responses are now under http://localhost:7001/responses
##### 8. Default responses directory renamed to mirage
Default templates used to be stored in a directory named 'responses'. The term 'response' was the incorrect word to describe what is now called a 'template'. Rather than rename this directory to templates, which is a directory name that may already be in use in your project, the default name for this directory has been changed to 'mirage'.  
  
The old directory name can still be used if you use the client or command line interface to overide where the responses are loaded from

#### What's new in the Client:
##### 1. Template Models
Perhaps the biggest addition to the client. Simply mixin Mirage::Template::Model in to a class, give it a method called body and there you have it... a class that can be used to put objects straight on to Mirage.
 
* All the methods you find on a standard response can then be used at the class level to set defaults. 
 
* Add builder methods to your class using the builder_methods class method.
 
**Example Usage:** (See rdoc for full details)  

    class UserProfile
      extend Mirage::Template::Model
      
      endpoint '/users'
      http_method :get
      status 200
      content_type 'application/json'
      
      builder_methods :firstname, :lastname, :age
      
      def body
        {firstname: firstname, lastname: lastname, age: age}.to_json
      end
    end
    
    
    Mirage::Client.new.put UserProfile.new.firstname('Joe').lastname('blogs')
    
##### Client interface
The client interface has been overhauled to make it more usable. It supports a couple of different ways of specifying a template
to let to specify templates in the style that best suites your code. The block in the examples is executed in the scope of the template
object itself so any method in it can be called. The template is also passed in to the block if you prefer to to call the methods
on a variable.

**Example Usage:** (See rdoc for full details)  

    mirage = Mirage::Client.new
    mirage.put('/users') do
      status 201
      http_method :put
      body 'response'
      
      required_body_content << 'Abracadabra'
      required_headers['Header'] = 'value'
      
      delay 1.5
    end
    
    # Template Model classes can be customised in exactly the same way
    
    mirage.put UserProfile.new do
      status 404
      required_parameters[:name] = /joe.*/
    end
#### What you don't get
A better UI :) it's on its way though!

### 2.4.0
---------
#### What do I get?
##### 1: Configure your client with defaults for each of your responses
Remove the repetition of setting things like the content-type each to time you put a response on to Mirage

**Example Usage:** (See rdoc for full details)  

    client = Mirage::Client.new do |defaults|
      defaults.content_type = "text/xml"
      defaults.delay = 0.5
    end  
    
    client.put("greeting", "hello") -> template put on to Mirage with a delay of 0.5 seconds and content-type text/xml configured
#### What do I have to do to upgrade?
Nothing, this is a new feature. Let me know if you have any problems :)
    
    


### 2.3.0
---------
#### What do I get?
##### 1: Run more than one instance of Mirage per machine.
##### 2: Programmatic interface for starting and stopping Mirage
The client API now includes the ability to start and stop Mirage locally. No more calling out to the command line.  

**Example Usage:** (See rdoc for full details)  

    mirage_client = Mirage.start :port => 9001 #with out args start mirage on 7001 by default
    Mirage.stop # stops the current running instance as long as only one is running  
    
##### 3: Updated command line interface
Now powered by the mighty Thor, the stop subcommand has been enhanced.  
**Usage:**  

    mirage stop -> As it always did, stops the current instances of Mirage as long as there is only one running instance.  
    mirage stop -p port -> stops Mirage on a given port.    
    mirage stop -p port1, port2... -> stop multiple instances of Mirage.  
    mirage stop -p all -> stop all instances of mirage.  
#### What do I have to do to upgrade?
You shouldn't have to do anything to move from the last version of Mirage to this one. Let me know if something stops working!
