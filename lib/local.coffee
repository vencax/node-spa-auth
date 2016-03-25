LocalStrategy = require('passport-local').Strategy

module.exports = (app, usermanip, passport, getToken) ->

  passport.use new LocalStrategy (username, password, done) ->
    usermanip.find {username: username, email: username}, (err, user) ->
      return done(err) if err
      return done(null, false, message: 'incorrect credentials') if !user
      if !usermanip.validPassword(user, password)
        return done(null, false, message: 'incorrect credentials')
      if user.status == 'disabled'
        return done(null, false, message: 'user disabled')
      done null, user

  app.post '/login',
  passport.authenticate('local', {session: false, failWithError: true}),
  (req, res) ->
    user = req.user.toJSON()
    delete user.password
    res.json
      user: user
      token: getToken(req)

  # ---------------------------------------------------------------------------

  app.post '/check', (req, res) ->
    usermanip.find req.body, (err, user) ->
      return res.json([ 0 ]) if user
      return res.json([])
