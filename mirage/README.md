Mirage
======
Mirage is a simple application for hosting responses to fool your applications into thinking that they are talking to real endpoints
whilst you are developing them. Its accessible via HTTP so it can be accessed via any language and has a restful interface so is easy to interact with.

Below are a few instructions telling you how to use Mirage. They are definately enough to get you up and running, but if you want to know everything you 
can do then have a look at the feature files for a complete low down. I know I know, it sounds a bit corney to say that a project's documentation is it's tests. But they are written using
cucumber and a lot of effort has been put in to try and make these things readable... promise!  

Installation & Running
----------------------
`gem install mirage`  
`mirage start`  
    
That's it, its running, your done... No seriously, go to http://localhost:7001/mirage and you see that its running.

There are also a [few options](https://github.com/Ladtech/sandbox/blob/master/mirage/features/setting_responses_with_a_delay.feature) that mirage can be started with as well.

Usage:
------
###Set
`example: http://localhost:7001/mirage/set/my_endpoint?response=hello`  

By hitting this url, you have just put a response on mirage. Your endpoint, the bit after 'mirage/set' can be anything you like for example 'anything/you/like'. In return for
  doing this Mirage will return you a response id. You can use this id to various things with this response.

###Get
How do I get my response back back?
  
`example: http://localhost:7001/mirage/get/my_endpoint`  
  
All you need to do is 'get/the/endpoint' and Mirage will serve which ever response has been set.  

When it comes to getting and setting responses, Mirage lets you do quite a lot:  

 * [Associate responses on an endpoint with a pattern](http://github.com/Ladtech/sandbox/blob/master/mirage/features/setting_responses_with_pattern_matching.feature ) - This lets you simulate different behaviour depending on the request that is sent to Mirage
 
 * [Introduce a delay](https://github.com/Ladtech/sandbox/blob/master/mirage/features/setting_responses_with_a_delay.feature) - Make things a bit more realistic and make your application wait.
   
 * [Templatise responses](https://github.com/Ladtech/sandbox/blob/master/mirage/features/setting_responses_with_a_delay.feature) - Substitute values found in a request back in to the response.
  
 * [Templatise responses](https://github.com/Ladtech/sandbox/blob/master/mirage/features/setting_responses_with_a_delay.feature) - Substitute values found in a request back in to the response.
   
 * [File hosting](https://github.com/Ladtech/sandbox/blob/master/mirage/features/setting_responses_with_a_delay.feature) - As well as text based responses, Mirage can also host files
 
###Check

###Peek  
If you want to see a what a response is set as then you can [peek](https://github.com/Ladtech/sandbox/blob/master/mirage/features/setting_responses_with_a_delay.feature) at it using the unique id you got when setting the response.
Peeking at response will return allow you to see what a response is set to without causing a request to be tracked.

`example: http://localhost:7001/mirage/peek/your_response_id`




 
 