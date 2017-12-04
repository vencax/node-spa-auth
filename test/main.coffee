
should = require('should')
request = require('request').defaults({timeout: 50000})

process.env.SERVER_SECRET = 'fhdsakjhfkjal'
process.env.DEFAULT_GID = '2'
port = process.env.PORT || 3333
g =
  sentemails: []

sendMail = (mail) ->
  return new Promise (resolve, reject) ->
    g.sentemails.push mail
    resolve(mail)
g.sendMail = sendMail
g.createError = (status, message) ->
  return {message: message, status: status}

# entry ...
describe "app", ->

  before (done) ->
    this.timeout(5000)

    # init server
    App = require('./app')
    App(g)
    .then (app) ->
      g.server = app.listen port, (err) ->
        return done(err) if err
        done()
      g.app = app
    .catch(done)
    return

  after (done) ->
    g.server.close()
    done()

  it "should exist", (done) ->
    should.exist g.app
    done()

  # run the rest of tests
  g.baseurl = "http://localhost:#{port}"

  submodules = [
    './register'
    './login'
    './chpassword'
  ]
  for i in submodules
    E = require(i)
    E(g)
