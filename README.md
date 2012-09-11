Mirage
======
Mirage aids testing of your applications by hosting mock responses so that your applications do not have to talk to real endpoints. It's accessible via HTTP and has a RESTful interface.    

Any ideas/improvements or feedback you have are greatly appreciated.  
  
Information on how to use Mirage can be found [here](https://github.com/lashd/mirage/wiki).  
  
I hope you find it useful,  

Leon

P.s. Mirage runs on Linux,MacOSX and Windows; Rubies 1.8.7, 1.9 and JRuby.

Installation
------------
    gem install mirage 
    
What's New?
----------- 
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
