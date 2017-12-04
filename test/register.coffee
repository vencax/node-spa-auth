
should = require('should')
request = require('request').defaults({timeout: 50000})


module.exports = (g) ->

  addr = g.baseurl + '/register'

  g.account =
    username: 'aborova'
    name: 'Alenka Borova'
    email: 'notyet@dasda.cz'
    password: 'fkdjsfjs'

  it "must register a new local user", (done) ->
    request
      url: "#{g.baseurl}/register/"
      body: g.account
      json: true
      method: 'post'
    , (err, res, body) ->
      return done err if err
      res.statusCode.should.eql 201
      g.sentemails.length.should.eql 1
      g.verifyLink = g.sentemails[0].text.match(/http(s?):[^\n]+/)[0]
      g.sentemails = []
      done()

  it "fail register already registered user", (done) ->
    request
      url: "#{g.baseurl}/register/"
      body: g.account
      json: true
      method: 'post'
    , (err, res, body) ->
      return done err if err
      res.statusCode.should.eql 400
      g.sentemails.length.should.eql 0
      done()

  it "must not login with unverified user", (done) ->
    request
      url: "#{g.baseurl}/login"
      body:
        username: g.account.username
        password: g.account.password
      json: true
      method: 'post'
    , (err, res, body) ->
      return done(err) if err
      res.statusCode.should.eql 401
      done()

  it "must verify user through link from email", (done) ->
    request.get g.verifyLink, (err, res, body) ->
      return done(err) if err
      console.log body
      if process.env.SET_PWD_AFTER_VERIFICATION
        body.indexOf('/changepwd?sptoken').should.be.above(0)
      else
        body.indexOf('/login').should.be.above(0)
      done()

  it "must not login with wrong credentials", (done) ->
    request
      url: "#{g.baseurl}/login"
      body:
        username: g.account.username
        password: 'incorrect'
      json: true
      method: 'post'
    , (err, res, body) ->
      return done(err) if err
      res.statusCode.should.eql 401
      should.not.exist(body.token)
      done()

  it "must login with good credentials", (done) ->
    request
      url: "#{g.baseurl}/login"
      body:
        username: g.account.username
        password: g.account.password
      json: true
      method: 'post'
    , (err, res, body) ->
      return done(err) if err
      res.statusCode.should.eql 200
      body.token.should.be.ok
      g.manip.find {"username": body.user.username}
      .then (found) ->
        body.user.id.should.not.be.below 0
        body.user.username.should.eql found.username
        body.user.name.should.eql found.name
        body.user.email.should.eql found.email
        body.user.status.should.eql 'enabled'
        done()
      .catch(done)

  it "must login with email as username", (done) ->
    request
      url: "#{g.baseurl}/login"
      body:
        username: g.account.email
        password: g.account.password
      json: true
      method: 'post'
    , (err, res, body) ->
      return done(err) if err
      res.statusCode.should.eql 200
      body.token.should.be.ok
      should.not.exist(body.user.password)
      body.user.username.should.eql g.account.username
      body.user.name.should.eql g.account.name
      body.user.email.should.eql g.account.email
      done()
