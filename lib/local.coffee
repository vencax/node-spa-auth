LocalStrategy = require('passport-local').Strategy

module.exports = (app, usermanip, passport, getToken) ->

  passport.use new LocalStrategy (username, password, done) ->
    usermanip.find [{uname: username}, {email: username}], (err, user) ->
      return done(err) if err
      return done(null, false, message: 'Incorrect username.') if !user

      if !usermanip.validPassword(user, password)
        return done(null, false, message: 'Incorrect password.')
      done null, user

  app.post '/login',
  passport.authenticate('local', {session: false, failWithError: true}),
  (req, res) ->
    user = req.user.toJSON()
    res.send
      user: user
      token: getToken(req.user)

  # ---------------------------------------------------------------------------

  app.post '/check', (req, res) ->
    if req.body.email
      cond = [{email: req.body.email}]
    else
      cond = [{uname: req.body.uname || ''}]

    usermanip.find cond, (err, user) ->
      return res.json([ 0 ]) if user
      return res.json([])
