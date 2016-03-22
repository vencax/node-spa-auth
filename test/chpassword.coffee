
should = require('should')
request = require('request').defaults({timeout: 50000})


module.exports = (g) ->

  addr = g.baseurl + '/auth'

  describe "chage password", ->

    beforeEach = (done)->
      g.sentemails = []
      done()

    it "not found on notexisting user", (done) ->
      request
        url: "#{addr}/requestforgotten"
        body: email: "idontexist@fsfsfs.cz"
        json: true
        method: 'post'
      , (err, res, body) ->
        return done(err) if err
        res.statusCode.should.eql 404
        g.sentemails.length.should.eql 0
        done()

    it "send email to existing user", (done) ->
      request
        url: "#{addr}/requestforgotten"
        body: email: g.account.email
        json: true
        method: 'post'
      , (err, res, body) ->
        return done(err) if err
        res.statusCode.should.eql 200
        g.sentemails.length.should.eql 1
        g.changeToken = g.sentemails[0].text.match(/sptoken=[^\n]+/)[0].substring(8)
        done()

    it "fail with wrong token", (done) ->
      wrongToken = 'lksjfksajfoafjpaWRONG'
      request
        url: "#{addr}/setpasswd?sptoken=#{wrongToken}"
        body: password: 'some new pass'
        json: true
        method: 'post'
      , (err, res, body) ->
        return done(err) if err
        res.statusCode.should.eql 401
        # try orig
        request
          url: "#{addr}/login"
          body:
            username: g.account.username
            password: g.account.password
          json: true
          method: 'post'
        , (err, res, body) ->
          return done(err) if err
          res.statusCode.should.eql 200
          body.token.should.be.ok
          done()

    it "succeed with right token", (done) ->
      newPwd = 'trolololo'
      request
        url: "#{addr}/setpasswd?sptoken=#{g.changeToken}"
        body: password: newPwd
        json: true
        method: 'post'
      , (err, res, body) ->
        return done(err) if err
        console.log body
        res.statusCode.should.eql 200
        # try orig pwd
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
          # try new one
          request
            url: "#{addr}/login"
            body:
              username: g.account.username
              password: newPwd
            json: true
            method: 'post'
          , (err, res, body) ->
            return done(err) if err
            res.statusCode.should.eql 200
            body.user.should.be.ok
            body.token.should.be.ok
            done()
