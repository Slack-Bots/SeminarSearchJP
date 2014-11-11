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
  # http://api.atnd.org/events/?keyword_or=google,cloud&format=atom
  getJson: (conditions, callback) ->
    console.log conditions
    for i in [0 ... conditions.length]
      url += '&'
      url += (conditions[i].key + '=' + conditions[i].value)

    console.log url
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
      for i in [1 ... conditionsArray.length]
        obj = {}
        # const words
        if conditionsArray[i] is 'today'
          obj.key = 'ymd'
          obj.value = mySetting.getLocalData().today

        else
          obj.key = conditionsArray[i].split(':')[0]
          obj.value = conditionsArray[i].split(':')[1]

          switch obj.key
            when 'keyword','k'
              # 'and' or 'or' 
              if obj.key is 'k'
                obj.key = 'keyword'
              if obj.value.indexOf('|') isnt -1 and obj.value.indexOf('&') is -1
                obj.key = 'keyword_or'
                obj.value = obj.value.replace '|',','
              else
                obj.value = obj.value.replace '&',','

            when 'date'
              obj.key = 'ymd'
            when 'name'
              obj.key = 'nickname'
            when 'twitter'
              obj.key = 'twitter_id'
            when 'oname'
              obj.key = 'owner_nickname'
            when 'otwitter'
              obj.key = 'owner_twitter_id'
            else
              msg.send 'Syntax Error :('
              return

        parseConditionsArray.push obj

      #console.log(parseConditionsArray)

      async.waterfall [
        (callback)->
          api.getJson(parseConditionsArray, (json) ->
            if(json == 'e')
              msg.send 'Error :('
            else
              eventsArray = json["events"]
              msgStr = ""
              for i in [0 ... eventsArray.length]
                if eventsArray[i].event.limit is null
                   eventsArray[i].event.limit = 'unset'

                line1 = "<#{eventsArray[i].event.event_url}|#{eventsArray[i].event.title}>\n"
                line2 = "#{eventsArray[i].event.started_at} ~ #{eventsArray[i].event.ended_at}\n"
                line3 = "#{eventsArray[i].event.catch}\n"
                if line3 is "\n"
                  line3 = ""
                line4 = "capacity:#{eventsArray[i].event.limit}  participants:#{eventsArray[i].event.accepted}\n"
                line5 = "place:#{eventsArray[i].event.place}\n"
                msgStr += (line1 + line2 + line3 + line4 + line5 + "\n") 
              msgStr = msgStr.replace /\s+$/, ''
              msg.send msgStr
          )
      ]

  robot.respond /help$/i, (msg) ->
    msg.reply ':)'

  # debug  
  robot.respond /d$/i, (msg) ->
    msg.send mySetting.getLocalData().keywords.length + ' ' +  mySetting.getLocalData().keywords