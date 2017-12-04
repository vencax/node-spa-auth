
should = require('should')
request = require('request').defaults({timeout: 50000})
jwt = require 'jsonwebtoken'


module.exports = (g) ->

  describe "login", ->

    beforeEach = (done)->
      g.sentemails = []
      done()

    it "must return only desired user attrs in token", (done) ->
      request
        url: "#{g.baseurl}/login?scope=username,gid,email"
        body:
          username: g.account.username
          password: g.account.password
        json: true
        method: 'post'
      , (err, res, body) ->
        return done(err) if err
        res.statusCode.should.eql 200
        body.token.should.be.ok
        jwt.verify body.token, process.env.SERVER_SECRET, (err, decoded) ->
          done(err) if err
          Object.keys(decoded).length.should.eql 5
          decoded.username.should.eql g.account.username
          decoded.gid.should.eql parseInt(process.env.DEFAULT_GID)
          decoded.email.should.eql g.account.email
          should.not.exist(decoded.password)
          should.not.exist(decoded.name)
          done()
