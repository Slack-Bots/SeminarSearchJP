'use strict'

async = require 'async'
fs    = require 'fs'
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
  url = 'http://api.atnd.org/events/'

  constructor: (debug = false) ->

  getJson: (dateStr, keywords) ->


module.exports = (robot) ->

  date = new Date
  today = date.getFullYear().toString() + ('0' + (date.getMonth() + 1).toString()).slice(-2) + ('0' + date.getDate().toString()).slice(-2)

  mySetting = new setLocalData today

  # search event
  # keywords

  # date
  ###
  robot.respond /today/i, (msg) ->
    if localKeywords.length is 0
      cat = new accessApi()
      msg.reply cat.getJson()
      # msg.reply cat.todayEvent()
    # option keywords
    #msg.reply today
  ###

  # select date
  robot.respond /date (.*)$/i, (msg) ->
    # msg.reply mySetting.localData.today
    msg.reply 'test'

  # help
  robot.respond /help$/i, (msg) ->
    msg.reply ':)'

  # bebug  
  robot.respond /d$/i, (msg) ->
    msg.send mySetting.getLocalData().keywords.length + ' ' +  mySetting.getLocalData().keywords