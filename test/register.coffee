
should = require('should')


module.exports = (g, addr, request) ->

  g.account =
    username: 'aborova'
    name: 'Alenka Borova'
    email: 'notyet@dasda.cz'
    password: 'fkdjsfjs'

  it "must return empty array on not existing email", (done) ->
    request.post "#{addr}/check", form:
      email: g.account.username
    , (err, res, body) ->
      return done(err) if err
      res.statusCode.should.eql 200
      body.should.eql '[]'
      done()

  it "must register a new local user", (done) ->
    request.post "#{addr}/register", form: g.account, (err, res, body) ->
      return done err if err
      res.statusCode.should.eql 201
      g.sentemails.length.should.eql 1
      g.verifyLink = g.sentemails[0].text.match(/http(s?):[^\n]+/)[0]
      g.sentemails = []
      done()

  it "must not login with unverified user", (done) ->
    request
      url: "#{addr}/login"
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
      url: "#{addr}/login"
      body:
        username: g.account.username
        password: 'incorrect'
      json: true
      method: 'post'
    , (err, res, body) ->
      return done(err) if err
      res.statusCode.should.eql 401
      # body.should.eql 'CREDENTIALS_NOT_VALID'
      done()

  it "must login with good credentials", (done) ->
    request
      url: "#{addr}/login"
      body:
        username: g.account.username
        password: g.account.password
      json: true
      method: 'post'
    , (err, res, body) ->
      return done(err) if err
      console.log body
      res.statusCode.should.eql 200
      body.token.should.be.ok
      g.manip.find {"username": body.user.username}, (err, found) ->
        return done(err) if err
        body.user.id.should.not.be.below 0
        body.user.username.should.eql found.username
        body.user.name.should.eql found.name
        body.user.email.should.eql found.email
        body.user.status.should.eql 'enabled'
        done()

  it "must login with email as username", (done) ->
    request
      url: "#{addr}/login"
      body:
        username: g.account.email
        password: g.account.password
      json: true
      method: 'post'
    , (err, res, body) ->
      return done(err) if err
      res.statusCode.should.eql 200
      body.token.should.be.ok
      body.user.username.should.eql g.account.username
      body.user.name.should.eql g.account.name
      body.user.email.should.eql g.account.email
      done()

  it "must return [0] on ALREADY existing email", (done) ->
    request
      url: "#{addr}/check"
      body:
        email: g.account.email
      json: true
      method: 'post'
    , (err, res, body) ->
      return done(err) if err
      res.statusCode.should.eql 200
      body.should.eql [0]
      done()

  it "must return [0] on ALREADY existing uname", (done) ->
    request
      url: "#{addr}/check"
      body:
        username: g.account.username
      json: true
      method: 'post'
    , (err, res, body) ->
      return done(err) if err
      res.statusCode.should.eql 200
      body.should.eql [0]
      done()

  it "must return [] on not existing email or username", (done) ->
    request
      url: "#{addr}/check"
      body:
        email: 'notyet@jfdksfljs.cz'
        username: 'notyetgandalf'
      json: true
      method: 'post'
    , (err, res, body) ->
      return done(err) if err
      res.statusCode.should.eql 200
      body.should.eql []
      done()
