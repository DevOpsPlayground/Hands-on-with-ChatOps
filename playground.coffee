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
    msg.http("https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{origin}&destinations=#{destination}&mode=bicycling&language=en-GB&devops-key=AIzaSyBD5q-eaDPqYX835JQhbgoG5Cuk7Tc1v7E")
      .get() (error, res, body) ->
        msg.send "#{body}"
        json=JSON.parse(body)
        msg.send "Between #{json.origin_addresses} and #{json.destination_addresses} \n Distance: #{json.rows[0].elements[0].distance.text}\n Duration: #{json.rows[0].elements[0].duration.text}\n"

