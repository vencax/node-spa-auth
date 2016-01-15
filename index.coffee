pbkdf2 = require 'pbkdf2-sha256'
jwt = require 'jsonwebtoken'
passport = require 'passport'

tokenExpiresIn = parseInt(process.env.TOKEN_VALIDITY_IN_MINS) * 60 || 24* 60 * 60
console.log "token validity interval: #{tokenExpiresIn} secs"

_getToken = (user) ->
  return jwt.sign(
    JSON.parse(JSON.stringify(user)),
    process.env.SERVER_SECRET,
    expiresIn: tokenExpiresIn
  )

_pingFrontend = (req, res) ->
  token = jwt.sign(
    req.user,
    process.env.SERVER_SECRET,
    expiresIn: process.env.EMAIL_VALIDATION_TOKEN_DURATION || 24 * 60 * 60
  )
  res.cookie 'sptoken', token,
    maxAge: 60 * 60 * 1000
    httpOnly: true
    secure: if process.env.NODE_ENV == 'development' then false else true
  # function _clientHost() {
  #   return req.headers.referer.match(/https?:\/\/[^\/]{2,256}/)[0];
  # }
  return res.redirect (process.env.CLIENTAPPURL or '') + '/_socialcallback'


module.exports = (app, usermanip, bodyParser, sendMail) ->
  app.use passport.initialize()
  app.use bodyParser.json()

  Local = require('./lib/local')
  Local(app, usermanip, passport, _getToken)

  Registartion = require('./lib/registration')
  Registartion(app, usermanip, sendMail)

  _initUserInfoRoute = false

  if 'FBCLIENTID' of process.env
    Facebook = require('./lib/facebook')
    Facebook(app, usermanip, passport, _pingFrontend)
    _initUserInfoRoute = true

  if 'TWITTERCONSUMERKEY' of process.env
    Twitter = require('./lib/twitter')
    Twitter(app, usermanip, passport, _pingFrontend)
    _initUserInfoRoute = true

  # var GithubStrategy = require('passport-github').Strategy;

  if 'GOOGLECLIENTID' of process.env
    Google = require('./lib/google')
    Google(app, usermanip, passport, _pingFrontend)
    _initUserInfoRoute = true

  if _initUserInfoRoute
    cookieParser = require('cookie-parser')
    app.use cookieParser()
    app.get '/userinfo', (req, res) ->
      token = req.cookies.sptoken
      jwt.verify token, process.env.SERVER_SECRET, (err, decoded) ->
        if err
          res.status(404).send 'TOKEN_NOT_VALID'
        else
          res.send
            user: decoded
            token: _getToken(decoded)

  app.use (err, req, res, next) ->
    if err.name and err.name == 'AuthenticationError'
      return res.status(401).send('CREDENTIALS_NOT_VALID')
    next(err)
