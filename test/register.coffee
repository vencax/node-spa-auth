
should = require('should')


module.exports = (ctx, addr, request) ->

  account =
    name: 'Alenka Borova'
    email: 'notyet@dasda.cz'
    passwd: 'fkdjsfjs'

  it "must register a new local user", (done) ->

    request.post "#{addr}/register", form: account, (err, res, body) ->
      return done err if err

      res.statusCode.should.eql 201
      body.should.eql 'VERIFYCATION_PWD_MAIL_SENT'
      done()


  it "must not login with wrong credentials", (done) ->
    request.post "#{addr}/login", form:
      username: account.email
      password: 'incorrect'
    , (err, res, body) ->
      return done(err) if err

      res.statusCode.should.eql 400
      body.should.eql 'CREDENTIALS_NOT_VALID'
      done()


  it "must login with good credentials", (done) ->

    request.post "#{addr}/login", form:
      username: account.email
      password: account.passwd
    , (err, res, body) ->
      return done(err) if err

      body = JSON.parse(body)
      body.token.should.be.ok
      user = body.user

      ctx.manip.find user.email, (err, found) ->
        return done(err) if err

        user.id.should.not.be.below 0
        user.name.should.eql found.name
        user.email.should.eql found.email
        user.state.should.eql 0
        done()
