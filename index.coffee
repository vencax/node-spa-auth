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

module.exports = (app, usermanip, bodyParser, sendMail) ->
  app.use passport.initialize()
  app.use bodyParser.json()

  Local = require('./lib/local')
  Local(app, usermanip, passport, _getToken)

  Registartion = require('./lib/registration')
  Registartion(app, usermanip, sendMail)

  app.use (err, req, res, next) ->
    if err.name and err.name == 'AuthenticationError'
      return res.status(401).json(message: 'CREDENTIALS_NOT_VALID')
    next(err)
