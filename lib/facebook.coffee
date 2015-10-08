FacebookStrategy = require('passport-facebook').Strategy

module.exports = (app, usermanip, passport, postAuthFunc) ->

  passport.use new FacebookStrategy
    clientID: process.env.FBCLIENTID
    clientSecret: process.env.FBCLIENTSECRET
    callbackURL: process.env.AUTH_URL + '/facebook/callback'
  , (accessToken, refreshToken, profile, done) ->
    email = profile.username + '@facebook.com'
    usermanip.find email, (err, user) ->
      return done(err) if err

      if !user
        user = usermanip.build
          email: email
          name: profile.displayName
          state: 1
      usermanip.save user, (err, user) ->
        done null, user

  app.get '/facebook', passport.authenticate('facebook')
  app.get '/facebook/callback', passport.authenticate('facebook', session: false), postAuthFunc
