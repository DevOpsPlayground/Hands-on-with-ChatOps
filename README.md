# Devops-Playground-Chatops-Intro

##Installation
###Pre-requisite
#### Using a Virtual Machine
If you have been provided a VM, it will need to be imported into your Virtualization tools (VirtualBox, VMWare, etc.)
To use the VM  ( on VirtualBox, VMWare workstation, VMWare fusion, VMWare player ) you will have to **(file>)import the .ova file**.

The operations already performed on the VM are :
```
	sudo apt-get install build-essential git-core libssl-dev redis-server libexpat1-dev
	curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
	sudo apt install nodejs
	npm --version
	sudo npm install -g hubot coffee-script yo generator-hubot
	sudo mkdir /opt/chatops 
	sudo chown ubuntu /opt/chatops
```
Note : Since npm is a part of the nodejs package, `npm --version` allows us to confirm its successful installation.

####Using a Vagrant Box
Using the Vagrantfile provided in a dedicated directory:
```
	vagrant up
	vagrant ssh
```

###Slack Team
 Since Instant Messaging is the core of all this, a Slack team needs to be created.
 [Go to the Slack home page](https://slack.com/)
You will need to provide a valid email address, and choose a unique team name.

Your new slack team is now reachable at YourTeamName.slack.com

###Hubot 
In your VM, to generate a Hubot bot we use the scaffolding tool `yo`

`cd /opt/chatops/ && yo hubot`
Fill in the details and specify `slack` as the adapter
**Hubot is now installed.**


![Yo-Hubot](screenshots/yoHubot.png?raw=true "YoHubot")
The last step is to link it to your slack team.

Get your Hubot_Slack_Token at  YourTeamName.slack.com/apps
`export Hubot_Slack_Token=YOUR_TOKEN`
	
To run Hubot : 
`/opt/chatops/bin/hubot -a slack`

Hubot should now be online as an user in your slack instance.
To test it, in slack :  
![Ping-Pong Hubot](screenshots/ping.png?raw=true "PINGPONG")

##Scripting a custom feature
**Note: coffee-script is indentation-sensitive. Therefore, a 2 spaces indentation has been chosen for this work.**
To develop features for Hubot,  our scripts have to be located in /opt/chatops/scripts
*example.coffee* should already be here to help us.

`cd /opt/chatops/scripts`
`cp example.coffee playground.coffee`
###STEP 1:
The first feature described in the example.coffee. Uncommenting it will allow us to test it.

```
module.exports = (robot) ->
  robot.hear /badger/i, (res) ->
    res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  
```

![Badger Hubot](screenshots/badger.png?raw=true "BADGER")  

**In the code, "badger" can be replace by any regex.**

Restart hubot to test this feature.

###STEP 2:
To push the scripting further, let's see if we can retrieve some parameters from slack.
Our new module should look like : 
```
# Description:
#   Generates help commands for Hubot.
#
# Commands:
#   Repeat what is said to hubot
#
# Notes:
#   These commands are grabbed from comment blocks at the top of each file.
module.exports = (robot) ->
  robot.respond /(.*)/i, (msg) ->
    text = escape(msg.match[1])
    msg.send "#{text}"
```

Here, we tell the bot to retrieve all the message matching the regex (.*), which describes *everything*.
Then the module store the data into a variable *text* `text = escape(msg.match[1])`
Finally, the bot resend the content of the variable to slack `msg.send "#{text}"`


After restarting hubot, test this new feature in slack:
```
	you: @hubot hello
	hubot: hello
```
###STEP 3:

Now that we understand how hubot works, we will implement a more complex feature : Google Maps Distance feature.

An HTTP request to this API looks like :
`https://maps.googleapis.com/maps/api/distancematrix/json?origins=PARIS&destinations=LONDON&mode=bicycling&language=fr-FR&key:YOUR_API_KEY`

And the response in JSON looks like :
```
	{
	  "destination_addresses" : [ "Paris, France" ],
	  "origin_addresses" : [ "Londres, Royaume-Uni" ],
	  "rows" : [
		 {
			"elements" : [
			   {
				  "distance" : {
					 "text" : "465 km",
					 "value" : 465364
				  },
				  "duration" : {
					 "text" : "23 heures 31 minutes",
					 "value" : 84642
				  },
				  "status" : "OK"
			   }
			]
		 }
	  ],
	  "status" : "OK"
	}
```

Thanks to step 1, we know how to  capture a message with a regex, and how to reuse it as a variable.
We want to capture an Origin city and a Destination 

Beforehand, you can manually test your REST call using curl, playing with the parameters.  
`curl -sL "https://maps.googleapis.com/maps/api/distancematrix/json?origins=PARIS&destinations=LONDON&mode=driving&language=fr-FR&key=YOUR_API_KEY"`

Our updated module will then look like this : 
```
# Description:
#   Generates help commands for Hubot.
#
# Commands:
#   hubot distance between X and Y - Call Google Map API to find out time and distance between two cities..
#
# Notes:
#   These commands are grabbed from comment blocks at the top of each file.
module.exports = (robot) ->
  robot.respond /distance between (.*) and (.*)/i, (msg) ->
    origin = escape(msg.match[1])
    destination = escape(msg.match[2])
    msg.http("https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{origin}&destinations=#{destination}&mode=bicycling&language=en-GB&key=YOUR_API_KEY")
      .get() (error, res, body) ->
        msg.send "#{body}"
        json=JSON.parse(body)
        msg.send "Between #{json.origin_addresses} and #{json.destination_addresses} \n Distance: 	#{json.rows[0].elements[0].distance.text}\n Duration: #{json.rows[0].elements[0].duration.text}\n"
```

This script:   
1. Listens for a message structured like `distance between (.*) and (.*)`.  
2. Captures the content of `(*)` into the variables *origin* and *destination*.  
3. Constructs and calls the Google Map API `msg.http` using these variables.  
4. Gets the response JSON `.get() (error, res, body)`  and displays it `msg.send "#{body}`.  
5. Parses it `json=JSON.parse(body)` and display the information requested nicely.  

![Distance Hubot](screenshots/distance.png?raw=true "Distance Matrix")  
**Make sure to check out the full playground.coffee file in the repository.**
Finally, restart Hubot and try your new feature in Slack.

##What to do next ?
The previous example gave you enough knowledge to understand chatops and its basic implementation.
To improve this work, you could :

	1.Add the transportation mode as a variable in your module
	
	2.Catch the potential error
	
	3.Integrate with another more complex API
	
	4.Implement chatops into your devops practices

##Reading Materials
* [Hubot documentation](https://hubot.github.com/docs/)
* [Google Maps Distance Matrix API documentation](https://developers.google.com/maps/documentation/distance-matrix/intro)
* [Read our blog post :-)](http://www.forest-technologies.co.uk/blog/how-chatops-is-redefining-enterprise-and-open-source-devops)
