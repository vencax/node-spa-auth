
should = require('should')
http = require('http')
request = require('request').defaults({timeout: 5000})
fs = require('fs')
bodyParser = require('body-parser')
express = require('express')

process.env.SERVER_SECRET = 'fhdsakjhfkjal'
port = process.env.PORT || 3333
sentemails = []
sendMail = (mail, cb) ->
  sentemails.push mail
  cb()

# entry ...
describe "app", ->

  apiMod = require(__dirname + '/../index')
  g = {}
  ctx = {}
  db =
    Sequelize: require('sequelize')

  before (done) ->
    # init server
    app = express()

    db.sequelize = new db.Sequelize('database', 'username', 'password',
      # sqlite! now!
      dialect: 'sqlite'
    )
    # register models
    mdlsMod = require(__dirname + '/../models.js')
    mdls = mdlsMod.sequelize(db.sequelize, db.Sequelize)
    for mdlname, mdl of mdls
      db[mdlname] = mdl

    db.sequelize.sync().then () ->

      api = express()
      api.use(bodyParser.urlencoded({ extended: false }))
      api.use(bodyParser.json())

      manip = ctx.manip = apiMod.manips.sequelize(db)
      apiMod.init api, manip, bodyParser, sendMail

      app.use('/auth', api)

      g.server = app.listen port, (err) ->
        return done(err) if err
        setTimeout () ->
          done()
        , 1500

      g.app = app

  after (done) ->
    g.server.close()
    done()

  it "should exist", (done) ->
    should.exist g.app
    done()

  # run the rest of tests
  baseurl = "http://localhost:#{port}/auth"

  require('./register')(ctx, baseurl, request)
