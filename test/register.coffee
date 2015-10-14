
should = require('should')


module.exports = (ctx, addr, request) ->

  account =
    uname: 'aborova'
    name: 'Alenka Borova'
    email: 'notyet@dasda.cz'
    passwd: 'fkdjsfjs'

  it "must return empty array on not existing email", (done) ->
    request.post "#{addr}/check", form:
      email: account.uname
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 200
      body.should.eql '[]'
      done()

  it "must register a new local user", (done) ->

    request.post "#{addr}/register", form: account, (err, res, body) ->
      return done err if err

      res.statusCode.should.eql 201
      body.should.eql 'VERIFYCATION_PWD_MAIL_SENT'
      done()


  it "must not login with wrong credentials", (done) ->
    request.post "#{addr}/login", form:
      username: account.uname
      password: 'incorrect'
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 400
      body.should.eql 'CREDENTIALS_NOT_VALID'
      done()


  it "must login with good credentials", (done) ->

    request.post "#{addr}/login", form:
      username: account.uname
      password: account.passwd
    , (err, res, body) ->
      return done(err) if err

      body = JSON.parse(body)
      body.token.should.be.ok
      user = body.user

      ctx.manip.find [{"uname": user.uname}], (err, found) ->
        return done(err) if err

        user.id.should.not.be.below 0
        user.uname.should.eql found.uname
        user.name.should.eql found.name
        user.email.should.eql found.email
        user.state.should.eql 0
        done()

  it "must login with email as username", (done) ->

    request.post "#{addr}/login", form:
      username: account.email
      password: account.passwd
    , (err, res, body) ->
      return done(err) if err

      body = JSON.parse(body)
      body.token.should.be.ok
      user = body.user
      user.uname.should.eql account.uname
      user.name.should.eql account.name
      user.email.should.eql account.email

      done()

  it "must return [0] on ALREADY existing email", (done) ->
    request.post "#{addr}/check", form:
      email: account.email
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 200
      body.should.eql '[0]'
      done()

  it "must return [0] on ALREADY existing uname", (done) ->
    request.post "#{addr}/check", form:
      uname: account.uname
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 200
      body.should.eql '[0]'
      done()
