var TwitterStrategy = require('passport-twitter').Strategy;


module.exports = function(app, usermanip, passport, postAuthFunc) {

  passport.use(new TwitterStrategy({
    consumerKey: process.env.TWITTERCONSUMERKEY,
    consumerSecret: process.env.TWITTERCONSUMERSECRET,
    callbackURL: process.env.AUTH_URL + "/twitter/callback"
  }, function(accessToken, refreshToken, profile, done) {
    email = profile.username + '@twitter.com';
    usermanip.find(email, function(err, user) {
      if (!user) {
        user = usermanip.build({
          email: email, name: profile.displayName, state: 1
        });
      }
      usermanip.save(user, function(err, user) {
        return done(null, user);
      });
    });
  }));

  var session = require('express-session');
  app.use(session({
    secret: 'keyboard cat', saveUninitialized: true, resave: true
  }));

  app.get('/twitter', passport.authenticate('twitter'));

  app.get('/twitter/callback',
    passport.authenticate('twitter', {session: false}),
    postAuthFunc
  );

};
