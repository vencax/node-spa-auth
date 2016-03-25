jwt = require 'jsonwebtoken'
passport = require 'passport'
_ = require 'underscore'

tokenExpiresIn = parseInt(process.env.TOKEN_VALIDITY_IN_MINS) * 60 || 24* 60 * 60
console.log "token validity interval: #{tokenExpiresIn} secs"

_getToken = (req) ->
  """
  req.query.scope can contain comma-separated user attrnames that shall be in token
  """
  user = JSON.parse(JSON.stringify(req.user))
  if req.query.scope
    tokencontent = _.pick(user, req.query.scope.split(','))
  else
    tokencontent = user
  return jwt.sign(tokencontent,
    process.env.SERVER_SECRET,
    expiresIn: tokenExpiresIn
  )

module.exports = (app, usermanip, bodyParser, sendMail) ->
  app.use passport.initialize()
  app.use bodyParser.json()

  Local = require('./lib/local')
  Local(app, usermanip, passport, _getToken)

  Registartion = require('./lib/registration')
  Registartion(app, usermanip, sendMail)

  app.use (err, req, res, next) ->
    if err.name and err.name == 'AuthenticationError'
      return res.status(401).json(code: 1, message: 'invalid credentials')
    next(err)
