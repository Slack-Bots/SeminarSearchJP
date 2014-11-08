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

  getJson: (callback) ->
    httpClient.create(url).get() (err,res,body) =>
      try
        callback(JSON.parse(body))
      catch e
        callback('e')

module.exports = (robot) ->

  date = new Date
  today = date.getFullYear().toString() + ('0' + (date.getMonth() + 1).toString()).slice(-2) + ('0' + date.getDate().toString()).slice(-2)

  mySetting = new setLocalData today

  # search event
  # keywords
  ###
  robot.respond /date (.*)$/i, (msg) ->
    # msg.reply mySetting.localData.today
    msg.reply 'test'
  ###
  api = new accessApi()

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