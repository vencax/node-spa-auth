
should = require('should')
http = require('http')
request = require('request').defaults({timeout: 5000})
fs = require('fs')
bodyParser = require('body-parser')
express = require('express')

process.env.SERVER_SECRET = 'fhdsakjhfkjal'
# process.env.DATABASE_URL = 'sqlite://db.sqlite'
port = process.env.PORT || 3333
g =
  sentemails: []

sendMail = (mail, cb) ->
  g.sentemails.push mail
  cb()

# entry ...
describe "app", ->

  apiMod = require(__dirname + '/../index')

  Sequelize = require('sequelize')

  before (done) ->
    this.timeout(5000)
    # init server
    app = express()

    sequelize = new Sequelize process.env.DATABASE_URL || 'sqlite:',
      dialect: 'sqlite'  # sqlite! now!
    # register models
    mdlsMod = require(__dirname + '/models')
    mdlsMod(sequelize, Sequelize)

    sequelize.sync(logging: console.log).then () ->

      api = express()
      api.use(bodyParser.urlencoded({ extended: false }))
      api.use(bodyParser.json())

      manip = g.manip = require('./sequelize_manip')(sequelize)
      apiMod api, manip, bodyParser, sendMail

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
  g.baseurl = "http://localhost:#{port}"

  Register = require('./register')
  Register(g, "#{g.baseurl}/auth", request)
