# Description:
#   Generates help commands for Hubot.
#
# Commands:
#   hubot distance between X and Y - Call Google Map API to find out time and distance between two cities..
#
# Notes:
#   These commands are grabbed from comment blocks at the top of each file.
module.exports = (robot) ->
  robot.respond /distance between (.*) and (.*)/i, (res) ->
    origin = res.match[1]
    destination = res.match[2]
    res.http("https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{origin}&destinations=#{destination}&mode=driving&language=en-GB&devops-key=YOUR_API_KEY")
      .get() (error, resp, body) ->
        res.send "#{body}"
        json=JSON.parse(body)
        res.send "Between #{json.origin_addresses} and #{json.destination_addresses} \n Distance: #{json.rows[0].elements[0].distance.text}\n Duration: #{json.rows[0].elements[0].duration.text}\n"

