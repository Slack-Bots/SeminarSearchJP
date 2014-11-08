'use strict'

async      = require 'async'
fs         = require 'fs'
httpClient = require 'scoped-http-client'

# debug
util  = require 'util'

# localdata
class setLocalData
  localData = {}
  localFilePath = '../info.json'

  constructor: (today) ->  
    localData.today = today
    @loadLocalFile()

  # return data
  getLocalData: ->
    return localData

  # file load
  # maybe fs will delete and use redis 
  loadLocalFile: ->
    try
      json = require localFilePath
      localData.keywords = json.keywords
    catch e
      fs.openSync localFilePath 'w'
      localData.keywords = []

  writeLocalFile: ->
    fs.open localFilePath, 'w'
    # parse


class accessApi
  # API
  url = 'http://api.atnd.org/events/?format=json'

  #constructor: () ->

  getJson: (conditions, callback) ->
    console.log(conditions)
    httpClient.create(url).get() (err , res, body) =>
      try
        callback(JSON.parse(body))
      catch e
        callback('e')


module.exports = (robot) ->

  date = new Date
  today = date.getFullYear().toString() + ('0' + (date.getMonth() + 1).toString()).slice(-2) + ('0' + date.getDate().toString()).slice(-2)

  mySetting = new setLocalData today
  api = new accessApi()

  # start searching
  robot.respond /s|search$/i, (msg) ->
    # test of paragraph at slack
    msg.send "ok :) Please input a conditions.\npiyopiyo"
    robot.respond /(.*)/i, (msg) ->
      # msg.send msg.message.text
      conditionsArray = msg.message.text.split ' '
      # check syntax 
      ###
      ###
      parseConditionsArray = []
      # index 0 is bot-name
      for i in [1..conditionsArray.length-1]
        obj = {}
        # const words
        if conditionsArray[i] is 'today'
          obj.key = 'ymd'
          obj.value = mySetting.getLocalData().today
        else
          obj.key = conditionsArray[i].split(':')[0]
          obj.value = conditionsArray[i].split(':')[1]
        parseConditionsArray.push obj

      #console.log(parseConditionsArray)

      async.waterfall [
        (callback)->
          api.getJson(parseConditionsArray, (json) ->
            if(json == 'e')
              msg.send 'Error :('
            else
              msg.reply json["results_returned"]
          )
      ]

  robot.respond /t$/i, (msg) ->
    async.waterfall [
      (callback)->
        api.getJson((json) ->
          if(json == 'e')
            msg.send 'Error :('
          else
            msg.reply json["results_returned"]
        )
    ]


  robot.respond /help$/i, (msg) ->
    msg.reply ':)'

  # debug  
  robot.respond /d$/i, (msg) ->
    msg.send mySetting.getLocalData().keywords.length + ' ' +  mySetting.getLocalData().keywords