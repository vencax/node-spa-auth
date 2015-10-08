LocalStrategy = require('passport-local').Strategy

module.exports = (app, usermanip, passport, getToken) ->

  passport.use new LocalStrategy (username, password, done) ->
    usermanip.find username, (err, user) ->
      return done(err) if err
      return done(null, false, message: 'Incorrect username.') if !user

      if !usermanip.validPassword(user, password)
        return done(null, false, message: 'Incorrect password.')
      done null, user

  app.post '/login',
  passport.authenticate('local', {session: false, failWithError: true}),
  (req, res) ->
    user = req.user.toJSON()
    delete user.passwd
    res.send
      user: user
      token: getToken(req.user)

  # ---------------------------------------------------------------------------

  app.post '/check', (req, res) ->
    usermanip.find req.body.email, (err, user) ->
      if user
        res.send [ 0 ]
      else
        res.send []
